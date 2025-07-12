//
//  WeatherAPIService.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import Foundation
import CoreLocation

class WeatherAPIService {
    private let apiKey = "b943851aae3fcea77ee2b62c61d864db"
    private let baseUrl = "https://api.openweathermap.org/data/2.5"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func fetchWeather(latitude: Double, longitude: Double,
                     completion: @escaping (Result<WeatherDataModel, WeatherError>) -> Void) {
        let urlString = "\(baseUrl)/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        performRequest(urlString: urlString, completion: completion)
    }
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherDataModel, WeatherError>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(baseUrl)/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        
        performRequest(urlString: urlString, completion: completion)
    }
    
    func fetchForecast(latitude: Double, longitude: Double,
                      completion: @escaping (Result<ForecastData, WeatherError>) -> Void) {
        let urlString = "\(baseUrl)/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
                
                let now = Date()
                let next24Hours = Calendar.current.date(byAdding: .hour, value: 24, to: now)!
                
                let hourlyForecast = response.list
                    .filter { Date(timeIntervalSince1970: $0.dt) <= next24Hours }
                    .map { item in
                        HourlyForecastModel(
                            time: self.dateFormatter.string(from: Date(timeIntervalSince1970: item.dt)),
                            timeDate: Date(timeIntervalSince1970: item.dt),
                            temp: item.main.temp,
                            icon: WeatherIconManager.iconFor(item.weather.first?.main ?? "")
                        )
                    }
                
                let dailyForecast = self.groupDailyForecast(from: response.list)
                
                completion(.success(ForecastData(hourly: hourlyForecast, daily: dailyForecast)))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    private func performRequest(urlString: String,
                              completion: @escaping (Result<WeatherDataModel, WeatherError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let weatherData = WeatherDataModel(
                    city: response.name,
                    temperature: response.main.temp,
                    highTemp: response.main.tempMax,
                    lowTemp: response.main.tempMin,
                    condition: response.weather.first?.main ?? "Unknown",
                    humidity: response.main.humidity,
                    windSpeed: response.wind?.speed ?? 0,
                    latitude: response.coord.lat,
                    longitude: response.coord.lon,
                    hourlyForecast: [],
                    dailyForecast: []
                )
                completion(.success(weatherData))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    private func groupDailyForecast(from list: [ForecastResponse.ForecastItem]) -> [DailyForecastModel] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: list) { item -> Date in
            calendar.startOfDay(for: Date(timeIntervalSince1970: item.dt))
        }
        
        return grouped.map { (date: Date, items: [ForecastResponse.ForecastItem]) -> DailyForecastModel in
            let temps = items.map { $0.main.temp }
            let highTemp = temps.max() ?? 0
            let lowTemp = temps.min() ?? 0
            let icon = items.sorted { $0.main.temp > $1.main.temp }.first?.weather.first?.main ?? ""
            
            return DailyForecastModel(
                date: date,
                highTemp: highTemp,
                lowTemp: lowTemp,
                icon: WeatherIconManager.iconFor(icon)
            )
        }.sorted { $0.date < $1.date }
    }
}

struct ForecastData {
    let hourly: [HourlyForecastModel]
    let daily: [DailyForecastModel]
}

enum WeatherError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case serverError(code: Int, message: String)
    case decodingError(Error)
    case networkError(Error)
    case locationUnavailable
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .invalidResponse: return "Invalid response"
        case .serverError(let code, let message):
            return "Server error \(code): \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .locationUnavailable:
            return "Location unavailable"
        }
    }
}
