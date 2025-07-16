//
//  ContentView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @State private var showingSearch = false
    @State private var showingCitiesList = false
    @State private var initialLoadCompleted = false
    
    var body: some View {
        ZStack {
            if let weather = weatherManager.currentWeather {
                HomeView(weather: weather, topEdge: 0)
                    .environmentObject(weatherManager)
            } else if weatherManager.isLoading {
                LoadingView()
            } else if let error = weatherManager.error {
                ErrorView(error: error, retryAction: retryLoading)
            } else {
                welcomeView
            }
            
            if weatherManager.currentWeather != nil {
                VStack {
                    HStack {
                        Button(action: { showingCitiesList.toggle() }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text(StringManager.myCities)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(ColorManager.buttonBackground)
                            .clipShape(Capsule())
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: { showingSearch.toggle() }) {
                            Image(systemName: "magnifyingglass")
                                .padding(10)
                                .background(ColorManager.buttonBackground)
                                .clipShape(Circle())
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(weatherManager: weatherManager)
                .environmentObject(weatherManager)
        }
        .sheet(isPresented: $showingCitiesList) {
            SavedCitiesView()
                .environmentObject(weatherManager)
        }
        .onAppear {
            guard !initialLoadCompleted else { return }
            initialLoadCompleted = true
            
            if let firstCity = weatherManager.savedCities.first {
                weatherManager.switchToCity(firstCity)
            } else {
                weatherManager.fetchWeather(for: "Москва")
            }
        }
    }
    
    var welcomeView: some View {
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
    
    func loadInitialData() {
        weatherManager.fetchWeather(for: "Москва")
    }
    
    func retryLoading() {
        weatherManager.fetchWeather(for: "Москва")
    }
}
