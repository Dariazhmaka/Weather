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
        VStack(alignment: .leading) {
            headerView
            hourlyScrollView
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
    
    private var headerView: some View {
        Text("HOURLY FORECAST")
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
    }
    
    private var hourlyScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(hourlyData.prefix(12), id: \.self) { hour in
                    hourlyItemView(for: hour)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func hourlyItemView(for hour: HourlyForecast) -> some View {
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
