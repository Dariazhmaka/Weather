//
//  HourlyForecastView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct HourlyForecastView: View {
    var hourlyData: [HourlyForecastModel]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(hourlyData) { hour in
                    VStack(spacing: 8) {
                        Text(hour.time)
                            .font(.caption)
                        Image(systemName: hour.icon)
                            .symbolRenderingMode(.multicolor)
                            .font(.title2)
                        Text("\(Int(hour.temp))°")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60)
                }
            }
            .padding(.vertical, 5)
        }
    }
}
