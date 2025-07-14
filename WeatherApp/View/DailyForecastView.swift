//
//  DailyForecastView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct DailyForecastView: View {
    var dailyData: [DailyForecastModel]
    @Binding var selectedDate: Date
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(dailyData.prefix(7)) { day in
                Button(action: {
                    selectedDate = day.date
                }) {
                    HStack(spacing: 15) {
                        Text(dayName(for: day.date))
                            .font(.subheadline)
                            .frame(width: 80, alignment: .leading)
                        
                        Image(systemName: day.icon)
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
                    .foregroundColor(Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? .white : .white.opacity(0.7))
                    .padding(.vertical, 5)
                }
                
                if day.id != dailyData.prefix(7).last?.id {
                    Divider()
                        .background(Color.white.opacity(0.5))
                }
            }
        }
    }
    
    private func temperatureRangeView(lowTemp: Double, highTemp: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(.white.opacity(0.3))
                
                let range = highTemp - lowTemp
                let normalizedRange = min(max(range / 30, 0), 1)
                
                Capsule()
                    .frame(width: proxy.size.width * normalizedRange, height: 4)
                    .foregroundColor(.white)
                    .offset(x: proxy.size.width * (lowTemp / 30))
            }
        }
        .frame(height: 4)
    }
    
    private func dayName(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else {
            return dayFormatter.string(from: date)
        }
    }
}
