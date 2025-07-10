//
//  WeatherAPIService.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import Foundation
import CoreData

class WeatherAPIService {
    private let apiKey = "b943851aae3fcea77ee2b62c61d864db"
    private let baseUrl = "https://api.openweathermap.org/data/2.5"
    private let context: NSManagedObjectContext
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "\(baseUrl)/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric&lang=en"
        performRequest(urlString: urlString, completion: completion)
    }
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(APIError.invalidCityName))
            return
        }
        
        let urlString = "\(baseUrl)/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=en"
        performRequest(urlString: urlString, completion: completion)
    }
    
    func fetchForecast(latitude: Double, longitude: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseUrl)/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric&cnt=40"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let self = self else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let forecastResponse = try self.decoder.decode(ForecastAPIResponse.self, from: data)
                
                let fetchRequest: NSFetchRequest<WeatherData> = WeatherData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", latitude, longitude)
                
                if let weatherData = try self.context.fetch(fetchRequest).first {
                    try self.updateHourlyForecasts(for: weatherData, with: forecastResponse)
                    try self.updateDailyForecasts(for: weatherData, with: forecastResponse)
                    try self.context.save()
                }
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func performRequest(urlString: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard let data = data, let self = self else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let weatherData = try self.parseWeatherData(data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func parseWeatherData(_ data: Data) throws -> WeatherData {
        let response = try decoder.decode(WeatherAPIResponse.self, from: data)
        let weatherData = try updateOrCreateWeatherData(for: response)
        return weatherData
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
    
    private func updateHourlyForecasts(for weatherData: WeatherData, with response: ForecastAPIResponse) throws {
        if let hourlyForecasts = weatherData.hourlyForecast as? Set<HourlyForecast> {
            hourlyForecasts.forEach { context.delete($0) }
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        for item in response.list {
            let date = Date(timeIntervalSince1970: item.dt)
            if calendar.isDate(date, inSameDayAs: currentDate) {
                let hourly = HourlyForecast(context: context)
                hourly.time = DateFormatter.hourFormatter.string(from: date)
                hourly.timeDate = date
                hourly.temp = item.main.temp
                hourly.icon = WeatherIconManager.iconFor(item.weather.first?.main ?? "")
                weatherData.addToHourlyForecast(hourly)
            }
        }
        
        try context.save()
    }
    
    private func updateDailyForecasts(for weatherData: WeatherData, with response: ForecastAPIResponse) throws {
        if let dailyForecasts = weatherData.dailyForecast as? Set<DailyForecast> {
            dailyForecasts.forEach { context.delete($0) }
        }
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: response.list) { element -> Date in
            return calendar.startOfDay(for: Date(timeIntervalSince1970: element.dt))
        }
        
        for (date, forecasts) in grouped {
            guard let maxTempForecast = forecasts.max(by: { $0.main.tempMax < $1.main.tempMax }),
                  let minTempForecast = forecasts.min(by: { $0.main.tempMin < $1.main.tempMin }) else {
                continue
            }
            
            let daily = DailyForecast(context: context)
            daily.date = date
            daily.highTemp = maxTempForecast.main.tempMax
            daily.lowTemp = minTempForecast.main.tempMin
            daily.icon = WeatherIconManager.iconFor(maxTempForecast.weather.first?.main ?? "")
            weatherData.addToDailyForecast(daily)
        }
        
        try context.save()
    }
    
    enum APIError: Error {
        case invalidURL
        case invalidCityName
        case invalidResponse
        case noData
    }
}
