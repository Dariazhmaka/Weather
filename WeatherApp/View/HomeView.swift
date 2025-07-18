//
//  HomeView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    var topEdge: CGFloat
    @State private var selectedDate = Date()
    @State private var offset: CGFloat = 0
    @State private var showEffect = false
    @State private var isRefreshing = false
    
    @AppStorage("showSunset") private var showSunset = true
    @AppStorage("showHumidity") private var showHumidity = true
    @AppStorage("showFeelsLike") private var showFeelsLike = true
    @AppStorage("showPressure") private var showPressure = true
    @AppStorage("showWind") private var showWind = true
    
    private var weather: WeatherDataModel? {
        weatherManager.currentWeather
    }
    
    private var effectType: WeatherEffectType? {
        guard let condition = selectedDayWeatherCondition else { return nil }
        return WeatherEffectManager.effectType(for: condition)
    }
    
    private var selectedDayWeatherCondition: String? {
        guard let weather = weather else { return nil }
        
        if let selectedDay = weather.dailyForecast.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            return selectedDay.icon
        }
        return weather.condition
    }
    
    var body: some View {
        ZStack {
            if let weather = weather {
                weatherBackground
                    .ignoresSafeArea()
                
                if let effectType = effectType {
                    WeatherEffectView(effectType: effectType, size: UIScreen.main.bounds.size)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(showEffect ? 1 : 0)
                        .ignoresSafeArea()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                            .padding(.top, 50 + topEdge)
                        
                        if showSunset, let sunrise = weather.sunrise, let sunset = weather.sunset {
                            weatherSummaryCard(sunrise: sunrise, sunset: sunset)
                        }
                        
                        if !weather.hourlyForecast.isEmpty {
                            hourlyForecastSection
                        }
                        
                        if showHumidity || showWind || showPressure || showFeelsLike {
                            weatherDetailsSection
                        }
                        
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
            } else if weatherManager.isLoading {
                LoadingView()
            } else if let error = weatherManager.error {
                ErrorView(error: error, retryAction: retryLoading)
            } else {
                welcomeView
            }
        }
        .onAppear {
            selectedDate = Date()
            if let weather = weather, !weatherManager.isForecastLoaded && weather.hourlyForecast.isEmpty {
                weatherManager.fetchForecast(latitude: weather.latitude, longitude: weather.longitude) { _ in }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1)) {
                    showEffect = true
                }
            }
        }
        .onChange(of: weatherManager.currentWeather?.city) { _ in
            selectedDate = Date()
        }
    }
    
    private var weatherBackground: some View {
        Group {
            if let effectType = effectType {
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
                    
                case .none:
                    LinearGradient(colors: [
                        ColorManager.defaultBackgroundTop,
                        ColorManager.defaultBackgroundBottom
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            } else {
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
            if let weather = weather {
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
        }
        .offset(y: -offset)
        .offset(y: offset > 0 ? (offset / UIScreen.main.bounds.width) * 100 : 0)
        .offset(y: getTitleOffset())
    }
    
    private func weatherSummaryCard(sunrise: Date, sunset: Date) -> some View {
        VStack(spacing: 8) {
            HStack {
                HStack {
                    Image(systemName: "sunrise.fill")
                        .symbolRenderingMode(.multicolor)
                    Text(StringManager.sunrise)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "sunset.fill")
                        .symbolRenderingMode(.multicolor)
                    Text(StringManager.sunset)
                }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(ColorManager.textSecondary)
            .padding(.horizontal)
            
            Divider()
                .background(ColorManager.dividerColor)
            
            HStack {
                Text(formatTime(sunrise))
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                Text(formatTime(sunset))
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(ColorManager.textPrimary)
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
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
                if showHumidity, let weather = weather {
                    WeatherDetailItem(
                        icon: "humidity",
                        value: StringManager.humidityString(weather.humidity),
                        label: StringManager.humidity
                    )
                }
                
                if showWind, let weather = weather {
                    WeatherDetailItem(
                        icon: "wind",
                        value: StringManager.windSpeedString(weather.windSpeed),
                        label: StringManager.wind
                    )
                }
                
                if showPressure, let weather = weather {
                    WeatherDetailItem(
                        icon: "thermometer",
                        value: StringManager.pressureString(weather.pressure ?? 1012),
                        label: StringManager.pressure
                    )
                }
            }
            .frame(maxWidth: .infinity)
            
            if showFeelsLike, let weather = weather, let feelsLike = weather.feelsLike {
                WeatherDetailCard(
                    icon: "thermometer.sun.fill",
                    title: StringManager.feelsLike,
                    value: StringManager.temperatureString(feelsLike)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
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
                if let weather = weather {
                    ForEach(weather.dailyForecast.prefix(7)) { day in
                        DailyForecastRow(
                            day: day,
                            isSelected: Calendar.current.isDate(day.date, inSameDayAs: selectedDate)
                        )
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
        guard let weather = weather else { return [] }
        
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
    
    private var welcomeView: some View {
        VStack {
            Text(StringManager.welcomeTitle)
                .font(.title)
            
            Button(StringManager.getWeather, action: loadInitialData)
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
        }
        .foregroundColor(ColorManager.textPrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadInitialData() {
        weatherManager.fetchWeather(for: "Москва")
    }
    
    private func retryLoading() {
        weatherManager.fetchWeather(for: "Москва")
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
        formatter.dateFormat = "E"
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

