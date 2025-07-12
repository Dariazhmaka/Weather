//
//  WeatherAPIResponse.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import Foundation

struct WeatherResponse: Codable {
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let wind: Wind?
    let name: String
    let cod: Int?
    let message: String?
    
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
            case temp, pressure, humidity
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int?
    }
}

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
    
    struct ForecastItem: Codable {
        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
        let dtTxt: String?
        
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
    
    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coord
        let country: String
        let timezone: Int
        
        struct Coord: Codable {
            let lat: Double
            let lon: Double
        }
    }
}
