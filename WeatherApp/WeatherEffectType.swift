//
//  WeatherEffectType.swift
//  WeatherApp
//
//  Created by Дарья on 14.07.2025.
//

import Foundation

enum WeatherEffectType {
    case none
    case rain
    case snow
    case fog
    case sun
    case clouds
    case thunderstorm
}

class WeatherEffectManager {
    static func effectType(for condition: String) -> WeatherEffectType {
        let lowercased = condition.lowercased()
        
        if lowercased.contains("rain") {
            return .rain
        } else if lowercased.contains("snow") {
            return .snow
        } else if lowercased.contains("fog") || lowercased.contains("mist") || lowercased.contains("haze") {
            return .fog
        } else if lowercased.contains("thunder") || lowercased.contains("storm") {
            return .thunderstorm
        } else if lowercased.contains("clear") || lowercased.contains("sun") {
            return .sun
        } else if lowercased.contains("cloud") {
            return .clouds
        }
        
        return .none
    }
}
