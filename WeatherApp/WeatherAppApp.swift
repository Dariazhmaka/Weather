//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject private var weatherManager = WeatherManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weatherManager)
                .preferredColorScheme(.dark)
        }
    }
}
