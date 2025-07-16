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
                            .foregroundColor(Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? ColorManager.textPrimary : ColorManager.textSecondary)
                        
                        Image(systemName: day.icon)
                            .symbolRenderingMode(.multicolor)
                            .frame(width: 24)
                        
                        Spacer()
                        
                        Text(StringManager.temperatureString(day.lowTemp))
                            .frame(width: 36, alignment: .trailing)
                            .foregroundColor(ColorManager.textPrimary)
                        
                        temperatureRangeView(lowTemp: day.lowTemp, highTemp: day.highTemp)
                            .frame(maxWidth: 100)
                        
                        Text(StringManager.temperatureString(day.highTemp))
                            .frame(width: 36, alignment: .leading)
                            .foregroundColor(ColorManager.textPrimary)
                    }
                    .padding(.vertical, 5)
                }
                
                if day.id != dailyData.prefix(7).last?.id {
                    Divider()
                        .background(ColorManager.dividerColor)
                }
            }
        }
    }
    
    private func temperatureRangeView(lowTemp: Double, highTemp: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(ColorManager.dividerColor)
                
                let range = highTemp - lowTemp
                let normalizedRange = min(max(range / 30, 0), 1)
                
                Capsule()
                    .frame(width: proxy.size.width * normalizedRange, height: 4)
                    .foregroundColor(ColorManager.textPrimary)
                    .offset(x: proxy.size.width * (lowTemp / 30))
            }
        }
        .frame(height: 4)
    }
    
    private func dayName(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return StringManager.today
        } else {
            return dayFormatter.string(from: date)
        }
    }
}
