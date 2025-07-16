//
//  HomeView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct HomeView: View {
    var weather: WeatherDataModel
    var topEdge: CGFloat
    @State private var selectedDate = Date()
    @EnvironmentObject private var weatherManager: WeatherManager
    @State private var offset: CGFloat = 0
    @State private var showEffect = false
    @State private var isRefreshing = false
    
    private var effectType: WeatherEffectType {
        WeatherEffectManager.effectType(for: selectedDayWeatherCondition)
    }
    
    private var selectedDayWeatherCondition: String {
        if let selectedDay = weather.dailyForecast.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            return selectedDay.icon
        }
        return weather.condition
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            weatherBackground
                .ignoresSafeArea()
            
            WeatherEffectView(effectType: effectType, size: UIScreen.main.bounds.size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(showEffect ? 1 : 0)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                        .padding(.top, 50 + topEdge)
                    
                    weatherSummaryCard
                    
                    if !weather.hourlyForecast.isEmpty {
                        hourlyForecastSection
                    }
                    
                    weatherDetailsSection
                    
                    if !weather.dailyForecast.isEmpty {
                        weeklyForecastSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .coordinateSpace(name: "SCROLL")
            .overlay {
                if isRefreshing {
                    RefreshIndicator()
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            selectedDate = Date()
            if !weatherManager.isForecastLoaded && weather.hourlyForecast.isEmpty {
                weatherManager.fetchForecast(latitude: weather.latitude, longitude: weather.longitude) { _ in
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1)) {
                    showEffect = true
                }
            }
        }
        .onChange(of: weatherManager.isLoading) { newValue in
            withAnimation {
                isRefreshing = newValue
            }
        }
    }
        
    private var weatherBackground: some View {
        Group {
            switch effectType {
            case .rain, .thunderstorm:
                LinearGradient(colors: [
                    ColorManager.rainBackgroundTop,
                    ColorManager.rainBackgroundBottom
                ], startPoint: .top, endPoint: .bottom)
                
            case .snow:
                LinearGradient(colors: [
                    ColorManager.snowBackgroundTop,
                    ColorManager.snowBackgroundBottom
                ], startPoint: .top, endPoint: .bottom)
                
            case .sun:
                AngularGradient(
                    gradient: Gradient(colors: [
                        ColorManager.sunBackgroundTop,
                        ColorManager.sunBackgroundBottom
                    ]),
                    center: .topLeading,
                    angle: .degrees(45)
                )
            case .clouds, .fog:
                LinearGradient(colors: [
                    ColorManager.cloudsBackgroundTop,
                    ColorManager.cloudsBackgroundBottom
                ], startPoint: .top, endPoint: .bottom)
                
            default:
                LinearGradient(colors: [
                    ColorManager.defaultBackgroundTop,
                    ColorManager.defaultBackgroundBottom
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        .animation(.easeInOut(duration: 1), value: effectType)
    }
    
    private var headerSection: some View {
        VStack(spacing: 5) {
            Text(weather.city)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(ColorManager.textPrimary)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                .opacity(getTitleOpacity)
            
            Text("\(Int(weather.temperature))°")
                .font(.system(size: 72, weight: .thin))
                .foregroundColor(ColorManager.textPrimary)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                .opacity(getTempOpacity)
                .padding(.top, -10)
            
            Text(weather.condition.localizedCapitalized)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(ColorManager.textSecondary)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                .opacity(getConditionOpacity)
            
            HStack(spacing: 16) {
                Text("\(StringManager.maxTemp): \(Int(weather.highTemp))°")
                Text("\(StringManager.minTemp): \(Int(weather.lowTemp))°")
            }
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(ColorManager.textSecondary)
            .opacity(getHighLowOpacity)
        }
        .offset(y: -offset)
        .offset(y: offset > 0 ? (offset / UIScreen.main.bounds.width) * 100 : 0)
        .offset(y: getTitleOffset())
    }
    
    private var weatherSummaryCard: some View {
        VStack(spacing: 16) {
            Divider()
                .background(ColorManager.dividerColor)
            
            if let sunrise = weather.sunrise, let sunset = weather.sunset {
                HStack {
                    Image(systemName: "sunrise.fill")
                        .symbolRenderingMode(.multicolor)
                    Text(formatTime(sunrise))
                    Spacer()
                    Image(systemName: "sunset.fill")
                        .symbolRenderingMode(.multicolor)
                    Text(formatTime(sunset))
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ColorManager.textSecondary)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 16)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorManager.cardStroke, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private var hourlyForecastSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock")
                Text(StringManager.hourlyForecast)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .foregroundColor(ColorManager.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(filteredHourlyData.prefix(24)) { hour in
                        HourForecastItem(time: hour.time, temp: hour.temp, icon: hour.icon)
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 2)
            }
        }
        .padding(16)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorManager.cardStroke, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var weatherDetailsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                Text(StringManager.weatherDetails)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .foregroundColor(ColorManager.textPrimary)
            
            HStack(spacing: 16) {
                WeatherDetailItem(
                    icon: "humidity",
                    value: StringManager.humidityString(weather.humidity),
                    label: StringManager.humidity
                )
                
                WeatherDetailItem(
                    icon: "wind",
                    value: StringManager.windSpeedString(weather.windSpeed),
                    label: StringManager.wind
                )
                
                WeatherDetailItem(
                    icon: "thermometer",
                    value: StringManager.pressureString(weather.pressure ?? 1012),
                    label: StringManager.pressure
                )
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                if let feelsLike = weather.feelsLike {
                    WeatherDetailCard(
                        icon: "thermometer.sun.fill",
                        title: StringManager.feelsLike,
                        value: StringManager.temperatureString(feelsLike)
                    )
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
            
    private var weeklyForecastSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                Text(StringManager.weeklyForecast)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .foregroundColor(ColorManager.textSecondary)
            
            VStack(spacing: 12) {
                ForEach(weather.dailyForecast.prefix(7)) { day in
                    DailyForecastRow(day: day, isSelected: Calendar.current.isDate(day.date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedDate = day.date
                            }
                        }
                    
                    if day.id != weather.dailyForecast.prefix(7).last?.id {
                        Divider()
                            .background(ColorManager.dividerColor)
                    }
                }
            }
        }
        .padding(16)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorManager.cardStroke, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func getTitleOffset() -> CGFloat {
        if offset < 0 {
            let progress = -offset / 120
            let newOffset = (progress <= 1.0 ? progress : 1) * 20
            return -newOffset
        }
        return 0
    }
    
    private var filteredHourlyData: [HourlyForecastModel] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return weather.hourlyForecast.filter {
            $0.timeDate >= startOfDay && $0.timeDate < endOfDay
        }.sorted {
            $0.timeDate < $1.timeDate
        }
    }
    
    private var getTitleOpacity: Double {
        let titleOffset = -getTitleOffset()
        let progress = titleOffset / 20
        return Double(1 - progress)
    }
    
    private var getTempOpacity: Double {
        let progress = -offset / 50
        return Double(1 - progress)
    }
    
    private var getConditionOpacity: Double {
        let progress = -offset / 70
        return Double(1 - progress)
    }
    
    private var getHighLowOpacity: Double {
        let progress = -offset / 100
        return Double(1 - progress)
    }
}

struct HourForecastItem: View {
    let time: String
    let temp: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(time)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(ColorManager.textPrimary)
            
            Image(systemName: icon)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 22))
                .frame(height: 30)
            
            Text(StringManager.temperatureString(temp))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(ColorManager.textPrimary)
        }
        .frame(width: 60)
    }
}

struct DailyForecastRow: View {
    let day: DailyForecastModel
    let isSelected: Bool
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 16) {
            Text(dayName(for: day.date))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .frame(width: 100, alignment: .leading)
            
            Image(systemName: day.icon)
                .symbolRenderingMode(.multicolor)
                .frame(width: 24)
            
            Spacer()
            
            Text(StringManager.temperatureString(day.lowTemp))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .frame(width: 36, alignment: .trailing)
                .opacity(0.8)
            
            temperatureBar(low: day.lowTemp, high: day.highTemp)
                .frame(maxWidth: 100)
            
            Text(StringManager.temperatureString(day.highTemp))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .frame(width: 36, alignment: .leading)
        }
        .foregroundColor(isSelected ? ColorManager.textPrimary : ColorManager.textSecondary)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(isSelected ? ColorManager.selectedButtonBackground : Color.clear)
        .cornerRadius(12)
    }
    
    private func dayName(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return StringManager.today
        } else {
            return dayFormatter.string(from: date).capitalized
        }
    }
    
    private func temperatureBar(low: Double, high: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(ColorManager.dividerColor)
                
                let range = high - low
                let normalizedRange = min(max(range / 30, 0), 1)
                
                Capsule()
                    .frame(width: proxy.size.width * normalizedRange, height: 4)
                    .foregroundColor(.blue)
                    .offset(x: proxy.size.width * (low / 30))
            }
        }
        .frame(height: 4)
    }
}

struct WeatherDetailItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 20))
            
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .opacity(0.8)
        }
        .foregroundColor(ColorManager.textPrimary)
        .frame(maxWidth: .infinity)
    }
}

struct WeatherDetailCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .symbolRenderingMode(.multicolor)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
        .foregroundColor(ColorManager.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(ColorManager.buttonBackground)
        .cornerRadius(12)
    }
}

struct RefreshIndicator: View {
    @State private var isRotating = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(ColorManager.textPrimary)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(
                    .linear(duration: 1).repeatForever(autoreverses: false),
                    value: isRotating
                )
                .onAppear {
                    isRotating = true
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            Spacer()
                .frame(height: 30)
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleWeather = WeatherDataModel(
            city: "Москва",
            temperature: 23,
            highTemp: 26,
            lowTemp: 18,
            condition: "Cloudy",
            humidity: 65,
            windSpeed: 3.2,
            latitude: 55.7558,
            longitude: 37.6176,
            sunrise: Calendar.current.date(bySettingHour: 5, minute: 30, second: 0, of: Date())!,
            sunset: Calendar.current.date(bySettingHour: 20, minute: 45, second: 0, of: Date())!,
            hourlyForecast: [
                HourlyForecastModel(time: "Сейчас", timeDate: Date(), temp: 23, icon: "cloud.sun.fill"),
                HourlyForecastModel(time: "12:00", timeDate: Date().addingTimeInterval(3600), temp: 24, icon: "sun.max.fill"),
                HourlyForecastModel(time: "15:00", timeDate: Date().addingTimeInterval(7200), temp: 25, icon: "sun.max.fill")
            ],
            dailyForecast: [
                DailyForecastModel(date: Date(), highTemp: 26, lowTemp: 18, icon: "cloud.sun.fill"),
                DailyForecastModel(date: Date().addingTimeInterval(86400), highTemp: 28, lowTemp: 20, icon: "sun.max.fill"),
                DailyForecastModel(date: Date().addingTimeInterval(172800), highTemp: 24, lowTemp: 17, icon: "cloud.rain.fill")
            ]
        )
        
        HomeView(weather: sampleWeather, topEdge: 0)
            .preferredColorScheme(.dark)
            .environmentObject(WeatherManager())
    }
}
