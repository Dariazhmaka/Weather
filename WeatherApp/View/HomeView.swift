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
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                weatherHeader
                
                CustomStackView {
                    Text("HOURLY FORECAST")
                } contentView: {
                    hourlyForecastView
                }
                
                CustomStackView {
                    Text("DAILY FORECAST")
                } contentView: {
                    dailyForecastView
                }
                
                CustomStackView {
                    Text("WEATHER DETAILS")
                } contentView: {
                    weatherDetailsView
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            .background(geometryReader)
        }
        .background(backgroundGradient)
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
    
    private var hourlyForecastView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(Array(weather.hourlyForecast as? Set<HourlyForecast> ?? []).prefix(12), id: \.self) { hour in
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
    
    private var dailyForecastView: some View {
        VStack(spacing: 15) {
            ForEach(Array(weather.dailyForecast as? Set<DailyForecast> ?? []).prefix(7), id: \.self) { day in
                HStack(spacing: 15) {
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
                .padding(.vertical, 5)
                
                if day != Array(weather.dailyForecast as? Set<DailyForecast> ?? []).prefix(7).last {
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
    
    private var weatherDetailsView: some View {
        VStack(spacing: 15) {
            DetailRow(icon: "humidity", title: "HUMIDITY", value: "\(weather.humidity)%")
            Divider()
                .background(Color.white.opacity(0.5))
            DetailRow(icon: "wind", title: "WIND", value: "\(String(format: "%.1f", weather.windSpeed)) mph")
            Divider()
                .background(Color.white.opacity(0.5))
            DetailRow(icon: "thermometer", title: "PRESSURE", value: "1012 hPa")
        }
        .padding(.vertical, 5)
    }
    
    private var geometryReader: some View {
        GeometryReader { proxy -> Color in
            let minY = proxy.frame(in: .global).minY
            
            DispatchQueue.main.async {
                self.offset = minY
            }
            
            return Color.clear
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.3, blue: 0.7),
            Color(red: 0.3, green: 0.1, blue: 0.5)
        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
    
    private func dayName(for date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale.current
        return formatter.string(from: date).capitalized
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
