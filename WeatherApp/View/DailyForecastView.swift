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
        formatter.locale = Locale(identifier: "ru_RU")
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
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(
                                Calendar.current.isDate(day.date, inSameDayAs: selectedDate)
                                ? ColorManager.Text.primary
                                : ColorManager.Text.secondary
                            )
                        
                        Image(systemName: day.icon)
                            .symbolRenderingMode(.multicolor)
                            .frame(width: 24)
                        
                        Spacer()
                        
                        Text("\(Int(day.lowTemp))°")
                            .frame(width: 36, alignment: .trailing)
                            .foregroundColor(ColorManager.Text.secondary)
                        
                        temperatureRangeView(lowTemp: day.lowTemp, highTemp: day.highTemp)
                            .frame(maxWidth: 100)
                        
                        Text("\(Int(day.highTemp))°")
                            .frame(width: 36, alignment: .leading)
                            .foregroundColor(ColorManager.Text.primary)
                    }
                    .padding(.vertical, 8)
                    .background(
                        Calendar.current.isDate(day.date, inSameDayAs: selectedDate)
                        ? ColorManager.UI.selectedItem
                        : Color.clear
                    )
                    .cornerRadius(8)
                }
                
                if day.id != dailyData.prefix(7).last?.id {
                    Divider()
                        .background(ColorManager.Divider.background)
                }
            }
        }
        .padding(.vertical)
        .background(ColorManager.Card.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ColorManager.Card.border, lineWidth: 1)
        )
    }
    
    private func temperatureRangeView(lowTemp: Double, highTemp: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(ColorManager.TemperatureBar.background)
                
                let range = highTemp - lowTemp
                let normalizedRange = min(max(range / 30, 0), 1)
                
                Capsule()
                    .frame(width: proxy.size.width * normalizedRange, height: 4)
                    .foregroundColor(ColorManager.TemperatureBar.fill)
                    .offset(x: proxy.size.width * (lowTemp / 30))
            }
        }
        .frame(height: 4)
    }
    
    private func dayName(for date: Date) -> String {
        Calendar.current.isDateInToday(date)
        ? Strings.Common.today
        : dayFormatter.string(from: date).capitalized
    }
}

struct DailyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = [
            DailyForecastModel(date: Date(), highTemp: 25, lowTemp: 18, icon: "sun.max.fill"),
            DailyForecastModel(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            highTemp: 23, lowTemp: 16, icon: "cloud.sun.fill")
        ]
        
        DailyForecastView(
            dailyData: sampleData,
            selectedDate: .constant(Date())
        )
        .padding()
        .preferredColorScheme(.dark)
    }
}
