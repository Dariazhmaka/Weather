//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import CoreLocation
import CoreData

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let context = PersistenceController.shared.container.viewContext
    private let apiKey = "b943851aae3fcea77ee2b62c61d864db"
    private let baseUrl = "https://api.openweathermap.org/data/2.5"
    
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cityName: String = ""
    
    private let weatherDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            errorMessage = "Location access denied. Please enable in Settings."
        }
    }
    
    func fetchWeather(for city: String? = nil) {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        if let city = city?.trimmingCharacters(in: .whitespacesAndNewlines), !city.isEmpty {
            fetchCityWeather(city: city)
        } else {
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
                locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            } else {
                errorMessage = "Location services not enabled"
                isLoading = false
            }
        }
    }
    
    func reverseGeocode(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                self?.cityName = placemark.locality ?? placemark.country ?? "Unknown location"
            }
        }
    }
}

// MARK: - Networking
extension LocationManager {
    private func fetchCityWeather(city: String) {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            handleError("Invalid city name")
            return
        }
        
        let urlString = "\(baseUrl)/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=en"
        performRequest(urlString: urlString)
    }
    
    private func fetchCoordinateWeather(lat: Double, lon: Double) {
        let urlString = "\(baseUrl)/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=en"
        performRequest(urlString: urlString)
        reverseGeocode(latitude: lat, longitude: lon)
    }
    
    private func performRequest(urlString: String) {
        guard let url = URL(string: urlString) else {
            handleError("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.handleError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.handleError("Invalid server response")
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self?.handleError("Server returned status code \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data else {
                    self?.handleError("No data received")
                    return
                }
                
                self?.parseWeatherData(data)
            }
        }
        task.resume()
    }
    
    private func fetchForecast(lat: Double, lon: Double) {
        let urlString = "\(baseUrl)/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&cnt=40"
        
        guard let url = URL(string: urlString) else {
            handleError("Invalid forecast URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.handleError("Forecast error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self?.handleError("No forecast data")
                    return
                }
                
                self?.parseForecastData(data)
            }
        }.resume()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        fetchCoordinateWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError("Location error: \(error.localizedDescription)")
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocation()
    }
}


// MARK: - Data Processing
extension LocationManager {
    private func parseWeatherData(_ data: Data) {
        do {
            let response = try weatherDecoder.decode(WeatherAPIResponse.self, from: data)
            let weatherData = try updateOrCreateWeatherData(for: response)
            
            currentWeather = weatherData
            cityName = response.name
            
            fetchForecast(lat: response.coord.lat, lon: response.coord.lon)
        } catch {
            handleError("Failed to parse weather data: \(error.localizedDescription)")
        }
    }
    
    private func updateOrCreateWeatherData(for response: WeatherAPIResponse) throws -> WeatherData {
        let fetchRequest: NSFetchRequest<WeatherData> = WeatherData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city == %@", response.name)
        
        let weatherData: WeatherData
        if let existingData = try context.fetch(fetchRequest).first {
            weatherData = existingData
        } else {
            weatherData = WeatherData(context: context)
        }
        
        weatherData.city = response.name
        weatherData.temperature = response.main.temp
        weatherData.highTemp = response.main.tempMax
        weatherData.lowTemp = response.main.tempMin
        weatherData.condition = response.weather.first?.main ?? "Unknown"
        weatherData.conditionDescription = response.weather.first?.description ?? ""
        weatherData.humidity = Int16(response.main.humidity)
        weatherData.windSpeed = response.wind?.speed ?? 0
        weatherData.latitude = response.coord.lat
        weatherData.longitude = response.coord.lon
        weatherData.timestamp = Date()
        
        try context.save()
        return weatherData
    }
    
    private func parseForecastData(_ data: Data) {
        guard let weatherData = currentWeather else { return }
        
        do {
            let forecastResponse = try weatherDecoder.decode(ForecastAPIResponse.self, from: data)
            try updateHourlyForecasts(for: weatherData, with: forecastResponse)
        } catch {
            handleError("Failed to parse forecast: \(error.localizedDescription)")
        }
    }
    
    private func updateHourlyForecasts(for weatherData: WeatherData, with response: ForecastAPIResponse) throws {
        if let hourlyForecasts = weatherData.hourlyForecast as? Set<HourlyForecast> {
            hourlyForecasts.forEach { context.delete($0) }
        }
        
        // Add new forecasts (first 24 hours)
        for item in response.list.prefix(24) {
            let hourly = HourlyForecast(context: context)
            hourly.time = DateFormatter.hourFormatter.string(from: Date(timeIntervalSince1970: item.dt))
            hourly.temp = item.main.temp
            hourly.icon = WeatherIconManager.iconFor(item.weather.first?.main ?? "")
            weatherData.addToHourlyForecast(hourly)
        }
        
        try context.save()
    }
    
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = message
        }
    }
}

// MARK: - Data Models
extension LocationManager {
    struct WeatherAPIResponse: Codable {
        let coord: Coord
        let weather: [Weather]
        let main: Main
        let wind: Wind?
        let name: String
        
        struct Coord: Codable {
            let lon: Double
            let lat: Double
        }
        
        struct Weather: Codable {
            let main: String
            let description: String
        }
        
        struct Main: Codable {
            let temp: Double
            let tempMin: Double
            let tempMax: Double
            let humidity: Int
        }
        
        struct Wind: Codable {
            let speed: Double
        }
    }
    
    struct ForecastAPIResponse: Codable {
        let list: [ForecastItem]
        
        struct ForecastItem: Codable {
            let dt: TimeInterval
            let main: Main
            let weather: [Weather]
            
            struct Main: Codable {
                let temp: Double
            }
            
            struct Weather: Codable {
                let main: String
            }
        }
    }
}

// MARK: - Helpers
extension DateFormatter {
    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

enum WeatherIconManager {
    static func iconFor(_ condition: String) -> String {
        switch condition.lowercased() {
        case "clear": return "sun.max"
        case "clouds": return "cloud"
        case "rain": return "cloud.rain"
        case "snow": return "snow"
        case "thunderstorm": return "cloud.bolt.rain"
        default: return "questionmark"
        }
    }
}
