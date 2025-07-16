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
                title: StringManager.humidity,
                value: StringManager.humidityString(weather.humidity)
            )
            
            Divider()
                .background(ColorManager.dividerColor)
            
            DetailRow(
                icon: "wind",
                title: StringManager.wind,
                value: StringManager.windSpeedString(weather.windSpeed)
            )
            
            Divider()
                .background(ColorManager.dividerColor)
            
            DetailRow(
                icon: "thermometer",
                title: StringManager.pressure,
                value: StringManager.pressureString(1012)
            )
        }
        .padding()
        .background(ColorManager.buttonBackground)
        .cornerRadius(10)
    }
}
