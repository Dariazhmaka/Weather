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
            DetailRow(
                icon: "humidity",
                title: Strings.WeatherDetails.humidity,
                value: "\(weather.humidity)%"
            )
            
            Divider()
                .background(ColorManager.Divider.background)
            
            DetailRow(
                icon: "wind",
                title: Strings.WeatherDetails.wind,
                value: "\(String(format: "%.1f", weather.windSpeed)) \(Strings.WeatherDetails.windSpeedUnit)"
            )
            
            Divider()
                .background(ColorManager.Divider.background)
            
            DetailRow(
                icon: "thermometer",
                title: Strings.WeatherDetails.pressure,
                value: "\(weather.pressure ?? 1012) \(Strings.WeatherDetails.pressureUnit)"
            )
        }
        .padding()
        .background(ColorManager.Card.background)
        .cornerRadius(10)
    }
}
