//
//  Models.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import Foundation

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
            
            enum CodingKeys: String, CodingKey {
                case temp
                case tempMin = "temp_min"
                case tempMax = "temp_max"
                case humidity
            }
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

extension DateFormatter {
    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
