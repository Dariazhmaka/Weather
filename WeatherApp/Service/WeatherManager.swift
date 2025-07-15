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
    @Published var savedCities: [SavedCity] = []
    @Published var currentCity: SavedCity?
    
    private let apiService = WeatherAPIService()
    public let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    private let citiesKey = "savedCities"
        
    init() {
        loadCities()
        setupLocationUpdates()
    }
    
    private func loadCities() {
        if let data = UserDefaults.standard.data(forKey: citiesKey),
           let decoded = try? JSONDecoder().decode([SavedCity].self, from: data) {
            savedCities = decoded
            currentCity = savedCities.first
        }
    }
        
    func addCity(_ city: SavedCity) {
        if !savedCities.contains(where: { $0.id == city.id }) {
            savedCities.append(city)
            saveCities()
        }
    }

    func removeCity(at offsets: IndexSet) {
        savedCities.remove(atOffsets: offsets)
        saveCities()
        if let current = currentCity, !savedCities.contains(where: { $0.id == current.id }) {
            currentCity = savedCities.first
            if let newCity = currentCity {
                switchToCity(newCity)
            }
        }
    }

    private func saveCities() {
        if let data = try? JSONEncoder().encode(savedCities) {
            UserDefaults.standard.set(data, forKey: citiesKey)
        }
    }
    
    func fetchForecast(latitude: Double, longitude: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        apiService.fetchForecast(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let forecastData):
                    self?.currentWeather?.hourlyForecast = forecastData.hourly
                    self?.currentWeather?.dailyForecast = forecastData.daily
                    self?.isForecastLoaded = true
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func switchToCity(_ city: SavedCity) {
        currentCity = city
        loadWeatherForCurrentCity()
    }
     
    private func loadWeatherForCurrentCity() {
        guard let city = currentCity else { return }
        
        isLoading = true
        error = nil
        
        let group = DispatchGroup()
        
        group.enter()
        apiService.fetchWeather(latitude: city.latitude, longitude: city.longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self?.currentWeather = weatherData
                case .failure(let error):
                    self?.error = error
                }
                group.leave()
            }
        }
        
        group.enter()
        apiService.fetchForecast(latitude: city.latitude, longitude: city.longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let forecastData):
                    self?.currentWeather?.hourlyForecast = forecastData.hourly
                    self?.currentWeather?.dailyForecast = forecastData.daily
                    self?.isForecastLoaded = true
                case .failure(let error):
                    self?.error = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
        }
    }
     
    func fetchWeather(for cityName: String) {
        isLoading = true
        error = nil
        
        apiService.fetchWeather(for: cityName) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let weather):
                    let city = SavedCity(
                        name: weather.city,
                        latitude: weather.latitude,
                        longitude: weather.longitude
                    )
                    self?.currentCity = city
                    self?.currentWeather = weather
                    self?.loadWeatherForCurrentCity()
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    private func setupLocationUpdates() {
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                let cityName = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
                self?.fetchWeather(for: cityName)
            }
            .store(in: &cancellables)
    }
}
