//
//  WeatherAPIResponse.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import Foundation

struct WeatherAPIResponseDTO: Codable {
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
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
        }
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
}

struct ForecastAPIResponseDTO: Codable {
    let list: [ForecastItem]
    
    struct ForecastItem: Codable {
        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
        let dtTxt: String
        
        struct Main: Codable {
            let temp: Double
            let feelsLike: Double
            let tempMin: Double
            let tempMax: Double
            let pressure: Int
            let humidity: Int
            
            enum CodingKeys: String, CodingKey {
                case temp, pressure, humidity
                case feelsLike = "feels_like"
                case tempMin = "temp_min"
                case tempMax = "temp_max"
            }
        }
        
        struct Weather: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }
        
        enum CodingKeys: String, CodingKey {
            case dt, main, weather
            case dtTxt = "dt_txt"
        }
    }
}

enum WeatherIconHelper {
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
