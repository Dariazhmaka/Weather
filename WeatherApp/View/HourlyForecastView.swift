//
//  HourlyForecastView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct HourlyForecastView: View {
    var hourlyData: [HourlyForecast]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(sortedHourlyData, id: \.self) { hour in
                    VStack(spacing: 8) {
                        Text(hour.time ?? "--:--")
                            .font(.caption)
                        Image(systemName: hour.icon ?? "questionmark")
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
    
    private var sortedHourlyData: [HourlyForecast] {
        hourlyData.sorted {
            ($0.timeDate ?? Date.distantPast) < ($1.timeDate ?? Date.distantPast)
        }
    }
}
