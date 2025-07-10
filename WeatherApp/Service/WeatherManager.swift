//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import Foundation
import CoreData

import Foundation
import CoreData
import CoreLocation
import Combine

class WeatherManager: ObservableObject {
    private let apiService: WeatherAPIService
    private let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentWeather: WeatherData?
    @Published var isForecastLoaded = false
    @Published var isLoading = false
    @Published var error: Error?
    
    init(context: NSManagedObjectContext) {
        self.apiService = WeatherAPIService(context: context)
        setupLocationUpdates()
    }
    
    func fetchWeather() {
        isLoading = true
        locationService.requestLocation()
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        isLoading = true
        apiService.fetchWeather(latitude: latitude, longitude: longitude) { [weak self] result in
            self?.handleWeatherResult(result)
            self?.fetchForecast(latitude: latitude, longitude: longitude)
        }
    }
    
    func fetchWeather(for city: String) {
        isLoading = true
        apiService.fetchWeather(for: city) { [weak self] result in
            if case .success(let weatherData) = result {
                self?.handleWeatherResult(result)
                self?.fetchForecast(latitude: weatherData.latitude, longitude: weatherData.longitude)
            } else {
                self?.handleWeatherResult(result)
            }
        }
    }
    
    func fetchForecast(latitude: Double, longitude: Double) {
        apiService.fetchForecast(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isForecastLoaded = true
                case .failure(let error):
                    self?.error = error
                }
                self?.isLoading = false
            }
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
    
    private func handleWeatherResult(_ result: Result<WeatherData, Error>) {
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let weatherData):
                    self?.currentWeather = weatherData
                    self?.error = nil
                    // Автоматически загружаем прогноз при успешном получении погоды
                    self?.fetchForecast(latitude: weatherData.latitude, longitude: weatherData.longitude)
                case .failure(let error):
                    self?.error = error
                    self?.currentWeather = nil
                }
                self?.isLoading = false
            }
        }
    }
