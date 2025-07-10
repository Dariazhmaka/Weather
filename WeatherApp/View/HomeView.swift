//
//  HomeView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI
import CoreData

struct HomeView: View {
    var weather: WeatherData
    var topEdge: CGFloat
    @State var offset: CGFloat = 0
    @State private var selectedDate = Date()
    @EnvironmentObject private var weatherManager: WeatherManager
    
    var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    weatherHeader
                
                    if !weatherManager.isForecastLoaded {
                                        ProgressView()
                                            .padding(.vertical, 10)
                                    }
                    else if !availableDates.isEmpty {
                                       DaySelectionView(selectedDate: $selectedDate, availableDates: availableDates)
                                   }
                
                CustomStackView {
                    Text("HOURLY FORECAST")
                } contentView: {
                    HourlyForecastView(hourlyData: filteredHourlyData)
                }
                
                CustomStackView {
                    Text("DAILY FORECAST")
                } contentView: {
                    DailyForecastView(dailyData: Array(weather.dailyForecast as? Set<DailyForecast> ?? []))
                }
                
                CustomStackView {
                    Text("WEATHER DETAILS")
                } contentView: {
                    WeatherDetailsView(weather: weather)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(backgroundGradient)
        .onAppear {
            selectedDate = Date() // Устанавливаем текущую дату по умолчанию
        }
    }
    
    private var filteredHourlyData: [HourlyForecast] {
        guard let hourly = weather.hourlyForecast as? Set<HourlyForecast> else { return [] }
        return hourly.filter {
            Calendar.current.isDate($0.timeDate ?? Date(), inSameDayAs: selectedDate)
        }.sorted {
            ($0.timeDate ?? Date.distantPast) < ($1.timeDate ?? Date.distantPast)
        }
    }
    
    private var availableDates: [Date] {
        guard let hourly = weather.hourlyForecast as? Set<HourlyForecast> else { return [] }
        
        let dates = hourly.compactMap { $0.timeDate }
        let uniqueDates = Array(Set(dates.map { Calendar.current.startOfDay(for: $0) }))
        return uniqueDates.sorted()
    }
    
    private var weatherHeader: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(weather.city ?? "Unknown City")
                .font(.title2)
                .fontWeight(.semibold)
                .opacity(getTitleOpacity())
            
            Text("\(Int(weather.temperature))°")
                .font(.system(size: 72, weight: .thin))
                .opacity(getTempOpacity())
            
            Text(weather.condition ?? "Unknown")
                .font(.title3)
                .opacity(getConditionOpacity())
            
            HStack(spacing: 16) {
                Text("H:\(Int(weather.highTemp))°")
                Text("L:\(Int(weather.lowTemp))°")
            }
            .font(.subheadline)
            .opacity(getHighLowOpacity())
        }
        .foregroundColor(.white)
        .padding(.top, 50 + topEdge)
        .padding(.bottom, 30)
        .offset(y: offset > 0 ? (offset / 1.5) : 0)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.3, blue: 0.7),
            Color(red: 0.3, green: 0.1, blue: 0.5)
        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
    
    private func getTitleOpacity() -> Double {
        let progress = -offset / 20
        return Double(1 - progress)
    }
    
    private func getTempOpacity() -> Double {
        let progress = -offset / 50
        return Double(1 - progress)
    }
    
    private func getConditionOpacity() -> Double {
        let progress = -offset / 70
        return Double(1 - progress)
    }
    
    private func getHighLowOpacity() -> Double {
        let progress = -offset / 100
        return Double(1 - progress)
    }
}
