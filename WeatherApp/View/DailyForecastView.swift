//
//  DailyForecastView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct DailyForecastView: View {
    var dailyData: [DailyForecast]
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale.current
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DAILY FORECAST")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 4)
            
            ForEach(dailyData, id: \.self) { day in
                dailyForecastRow(for: day)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func dailyForecastRow(for day: DailyForecast) -> some View {
        HStack(spacing: 12) {
            Text(dayName(for: day.date))
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            
            Image(systemName: day.icon ?? "questionmark")
                .symbolRenderingMode(.multicolor)
                .frame(width: 24)
            
            Spacer()
            
            Text("\(Int(day.lowTemp))°")
                .frame(width: 36, alignment: .trailing)
            
            temperatureRangeView(lowTemp: day.lowTemp, highTemp: day.highTemp)
                .frame(maxWidth: 100)
            
            Text("\(Int(day.highTemp))°")
                .frame(width: 36, alignment: .leading)
        }
        .foregroundColor(.white)
        .padding(.vertical, 6)
    }
    
    private func temperatureRangeView(lowTemp: Double, highTemp: Double) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(.white.opacity(0.3))
                
                let range = highTemp - lowTemp
                let normalizedRange = min(max(range / 30, 0), 1) 
                
                Capsule()
                    .frame(width: geometry.size.width * normalizedRange, height: 4)
                    .foregroundColor(.white)
                    .offset(x: geometry.size.width * (lowTemp / 30))
            }
        }
        .frame(height: 4)
    }
    
    private func dayName(for date: Date?) -> String {
        guard let date = date else { return "N/A" }
        return dayFormatter.string(from: date).capitalized
    }
}
