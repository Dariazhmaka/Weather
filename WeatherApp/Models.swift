//
//  Models.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import Foundation

struct WeatherResponse {
    let cityName: String
    let currentTemp: Double
    let currentCondition: String
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}

struct HourlyWeather: Identifiable {
    let id = UUID()
    let time: String
    let temperature: Double
    let icon: String
}

struct DailyWeather: Identifiable {
    let id = UUID()
    let day: String
    let high: Double
    let low: Double
    let icon: String
}
