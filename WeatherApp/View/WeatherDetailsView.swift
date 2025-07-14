//
//  WeatherDetailsView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct WeatherDetailsView: View {
    var weather: WeatherDataModel 
    
    var body: some View {
        VStack(spacing: 15) {
            DetailRow(icon: "humidity", title: "Влажность", value: "\(weather.humidity)%")
            Divider()
                .background(Color.white.opacity(0.5))
            DetailRow(icon: "wind", title: "Ветер", value: "\(String(format: "%.1f", weather.windSpeed)) м/с")
            Divider()
                .background(Color.white.opacity(0.5))
            DetailRow(icon: "thermometer", title: "Давление", value: "1012 Пa")
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}
