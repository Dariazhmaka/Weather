//
//  ContentView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var weatherManager: WeatherManager
    @State private var showingSearch = false
    
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
                Button(action: { showingSearch.toggle() }) {
                    Image(systemName: "magnifyingglass")
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(weatherManager: weatherManager)
                .environmentObject(weatherManager)
        }
        .onAppear {
            if weatherManager.currentWeather == nil {
                weatherManager.fetchWeather(for: "Москва")
            }
        }
    }
    
    private var welcomeView: some View {
        VStack {
            Text("Добро пожаловать в Погода")
                .font(.title)
            
            Button("Получить погоду", action: loadInitialData)
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadInitialData() {
        weatherManager.fetchWeather(for: "Москва")
    }
    
    private func retryLoading() {
        weatherManager.fetchWeather(for: "Москва")
    }

}
