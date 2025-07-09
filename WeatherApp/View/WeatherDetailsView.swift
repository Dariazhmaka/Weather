//
//  WeatherDetailsView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

import SwiftUI

struct WeatherDetailsView: View {
    var weather: WeatherData
    
    var body: some View {
        VStack(spacing: 15) {
            DetailRow(icon: "humidity", title: "HUMIDITY", value: "\(weather.humidity)%")
            Divider()
                .background(Color.white.opacity(0.5))
            DetailRow(icon: "wind", title: "WIND", value: "\(String(format: "%.1f", weather.windSpeed)) mph")
            Divider()
                .background(Color.white.opacity(0.5))
            DetailRow(icon: "thermometer", title: "PRESSURE", value: "1012 hPa")
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}
