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
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "\(baseUrl)/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        performWeatherRequest(urlString: urlString, completion: completion)
    }
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseUrl)/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        performWeatherRequest(urlString: urlString, completion: completion)
    }
    
    func fetchForecast(latitude: Double, longitude: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseUrl)/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ForecastAPIResponseDTO.self, from: data)
                try self?.processForecastResponse(response)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func performWeatherRequest(urlString: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(WeatherAPIResponseDTO.self, from: data)
                let weatherData = try self?.createOrUpdateWeatherData(from: response) ?? {
                    throw APIError.coreDataError
                }()
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func createOrUpdateWeatherData(from response: WeatherAPIResponseDTO) throws -> WeatherData {
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
        weatherData.humidity = Int16(response.main.humidity)
        weatherData.windSpeed = response.wind?.speed ?? 0
        weatherData.latitude = response.coord.lat
        weatherData.longitude = response.coord.lon
        weatherData.timestamp = Date()
        
        try context.save()
        return weatherData
    }
    
    private func processForecastResponse(_ response: ForecastAPIResponseDTO) throws {
        for item in response.list {
            let hourlyForecast = HourlyForecast(context: context)
            hourlyForecast.timeDate = Date(timeIntervalSince1970: item.dt)
            hourlyForecast.time = DateFormatter.hourFormatter.string(from: hourlyForecast.timeDate ?? Date())
            hourlyForecast.temp = item.main.temp
            hourlyForecast.icon = WeatherIconHelper.iconFor(item.weather.first?.main ?? "")
            
        }
        
        
        try context.save()
    }
    
    enum APIError: Error {
        case invalidURL
        case noData
        case coreDataError
        case decodingError
    }
}
