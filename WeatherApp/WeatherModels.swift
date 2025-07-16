//
//  Models.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import Foundation
import SwiftUICore

struct WeatherDataModel {
    let city: String
    let temperature: Double
    let highTemp: Double
    let lowTemp: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let latitude: Double
    let longitude: Double
    var hourlyForecast: [HourlyForecastModel]
    var dailyForecast: [DailyForecastModel]
    
    init(city: String?,
         temperature: Double?,
         highTemp: Double?,
         lowTemp: Double?,
         condition: String?,
         humidity: Int?,
         windSpeed: Double?,
         latitude: Double?,
         longitude: Double?,
         hourlyForecast: [HourlyForecastModel],
         dailyForecast: [DailyForecastModel]
    ) {
        self.city = city ?? "Unknown City"
        self.temperature = temperature ?? 0.0
        self.highTemp = highTemp ?? temperature ?? 0.0
        self.lowTemp = lowTemp ?? temperature ?? 0.0
        self.condition = condition ?? "Unknown"
        self.humidity = humidity ?? 0
        self.windSpeed = windSpeed ?? 0.0
        self.latitude = latitude ?? 0.0
        self.longitude = longitude ?? 0.0
        self.hourlyForecast = hourlyForecast
        self.dailyForecast = dailyForecast
    }
}

struct HourlyForecastModel: Identifiable {
    let id = UUID()
    let time: String
    let timeDate: Date
    let temp: Double
    let icon: String
}

struct DailyForecastModel: Identifiable {
    let id = UUID()
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let icon: String
}

struct SavedCityModel: Identifiable, Codable {
    var id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
}

struct ForecastResponseModel {
    let hourly: [HourlyForecastModel]
    let daily: [DailyForecastModel]
}

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
            let tempMin: Double
            let tempMax: Double
            let humidity: Int
        }
        
        struct Weather: Codable {
            let main: String
            let description: String
        }
    }
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
