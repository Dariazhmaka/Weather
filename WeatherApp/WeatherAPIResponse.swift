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

// Rename to ForecastAPIResponseDTO
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

// Rename to WeatherDataModel (or remove if you're using Core Data WeatherData)
struct WeatherDataModel {
    let city: String
    let temperature: Double
    let highTemp: Double
    let lowTemp: Double
    let condition: String
    let conditionDescription: String
    let humidity: Int
    let windSpeed: Double
    let latitude: Double
    let longitude: Double
    
    init(from response: WeatherAPIResponseDTO) {
        city = response.name
        temperature = response.main.temp
        highTemp = response.main.tempMax
        lowTemp = response.main.tempMin
        condition = response.weather.first?.main ?? "Unknown"
        conditionDescription = response.weather.first?.description ?? ""
        humidity = response.main.humidity
        windSpeed = response.wind?.speed ?? 0
        latitude = response.coord.lat
        longitude = response.coord.lon
    }
}

// Rename to HourlyForecastModel
struct HourlyForecastModel {
    let time: String
    let timeDate: Date
    let temp: Double
    let icon: String
    
    init(from item: ForecastAPIResponseDTO.ForecastItem) {
        timeDate = Date(timeIntervalSince1970: item.dt)
        time = DateFormatter.hourFormatter.string(from: timeDate)
        temp = item.main.temp
        icon = WeatherIconManager.iconFor(item.weather.first?.main ?? "")
    }
}

// Rename to DailyForecastModel
struct DailyForecastModel {
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let icon: String
    
    init(date: Date, highTemp: Double, lowTemp: Double, icon: String) {
        self.date = date
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.icon = icon
    }
}

// Rename to WeatherIconHelper
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
