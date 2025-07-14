//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import Foundation
import Combine

class WeatherManager: ObservableObject {
    @Published var currentWeather: WeatherDataModel?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isForecastLoaded = false
    
    private let apiService = WeatherAPIService()
    public let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupLocationUpdates()
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        resetState()
        isLoading = true
        
        apiService.fetchWeather(latitude: latitude, longitude: longitude) { [weak self] (result: Result<WeatherDataModel, WeatherError>) in
            DispatchQueue.main.async {
                self?.handleWeatherResult(result)
                if case .success(let weatherData) = result {
                    self?.fetchForecast(for: weatherData)
                }
            }
        }
    }
    
    func fetchWeather(for city: String) {
        resetState()
        isLoading = true
        
        apiService.fetchWeather(for: city) { [weak self] (result: Result<WeatherDataModel, WeatherError>) in
            DispatchQueue.main.async {
                self?.handleWeatherResult(result)
                if case .success(let weatherData) = result {
                    self?.fetchForecast(for: weatherData)
                }
            }
        }
    }
    
    
    func fetchForecast(for weatherData: WeatherDataModel) {
        apiService.fetchForecast(latitude: weatherData.latitude, longitude: weatherData.longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let forecastData):
                    self?.currentWeather?.hourlyForecast = forecastData.hourly
                    self?.currentWeather?.dailyForecast = forecastData.daily
                    self?.isForecastLoaded = true
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    private func resetState() {
        isLoading = true
        error = nil
        currentWeather = nil
        isForecastLoaded = false
    }
    
    private func handleWeatherResult(_ result: Result<WeatherDataModel, WeatherError>) {
        isLoading = false
        switch result {
        case .success(let weatherData):
            currentWeather = weatherData
            error = nil
        case .failure(let error):
            self.error = error
            currentWeather = nil
        }
    }
    
    private func setupLocationUpdates() {
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.fetchWeather(latitude: location.coordinate.latitude,
                                 longitude: location.coordinate.longitude)
            }
            .store(in: &cancellables)
    }
}
