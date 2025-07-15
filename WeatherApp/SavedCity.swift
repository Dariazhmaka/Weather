//
//  SavedCity.swift
//  WeatherApp
//
//  Created by Дарья on 15.07.2025.
//

import Foundation

struct SavedCity: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.id = UUID().uuidString
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
