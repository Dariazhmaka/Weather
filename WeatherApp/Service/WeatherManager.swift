//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import Foundation
import CoreLocation
import CoreData
import Combine

class WeatherManager: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isForecastLoaded = false
    
    private let apiService: WeatherAPIService
    private var cancellables = Set<AnyCancellable>()
    public let locationService = LocationService()
    
    init(context: NSManagedObjectContext) {
        self.apiService = WeatherAPIService(context: context)
        setupLocationUpdates()
    }
    
    func fetchWeather() {
        if let location = locationService.currentLocation {
            fetchWeather(latitude: location.coordinate.latitude,
                       longitude: location.coordinate.longitude)
        } else {
            fetchWeather(for: "London")
        }
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        resetState()
        isLoading = true
        
        apiService.fetchWeather(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleWeatherResult(result)
            }
        }
    }
    
    func fetchWeather(for city: String) {
        resetState()
        isLoading = true
        
        apiService.fetchWeather(for: city) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleWeatherResult(result)
            }
        }
    }
    
    private func resetState() {
        isLoading = true
        error = nil
        currentWeather = nil
        isForecastLoaded = false
    }
    
    private func handleWeatherResult(_ result: Result<WeatherData, Error>) {
        isLoading = false
        
        switch result {
        case .success(let weatherData):
            currentWeather = weatherData
            error = nil
            fetchForecast(for: weatherData)
        case .failure(let error):
            self.error = error
            currentWeather = nil
            isForecastLoaded = false
        }
    }
    
    private func fetchForecast(for weatherData: WeatherData) {
        apiService.fetchForecast(latitude: weatherData.latitude,
                               longitude: weatherData.longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.isForecastLoaded = true
                case .failure(let error):
                    self?.error = error
                    self?.isForecastLoaded = false
                }
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
        
        locationService.$authorizationStatus
            .sink { [weak self] status in
                if status == .denied || status == .restricted {
                    self?.error = NSError(domain: "Location permission denied", code: 0)
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
}
