//
//  PersistenceController.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import Foundation

class Settings {
    static let shared = Settings()
    
    private init() {}
    
    var lastCity: String? {
        get { UserDefaults.standard.string(forKey: "lastCity") }
        set { UserDefaults.standard.set(newValue, forKey: "lastCity") }
    }
    
    var lastLocation: (lat: Double, lon: Double)? {
        get {
            let lat = UserDefaults.standard.double(forKey: "lastLat")
            let lon = UserDefaults.standard.double(forKey: "lastLon")
            return (lat, lon) 
        }
        set {
            UserDefaults.standard.set(newValue?.lat, forKey: "lastLat")
            UserDefaults.standard.set(newValue?.lon, forKey: "lastLon")
        }
    }
}
