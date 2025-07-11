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
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if weatherManager.isLoading {
                    LoadingView()
                } else if let error = weatherManager.error {
                    ErrorView(error: error) {
                        weatherManager.fetchWeather()
                    }
                } else if let weather = weatherManager.currentWeather {
                    HomeView(weather: weather, topEdge: 0)
                        .environmentObject(weatherManager)
                } else {
                    VStack {
                        Text("Welcome to WeatherApp")
                            .font(.title)
                        Button("Get Weather") {
                            weatherManager.fetchWeather()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .foregroundColor(.white)
                }
            }
            
            Button(action: { showingSearch = true }) {
                Image(systemName: "magnifyingglass")
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding()
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(weatherManager: weatherManager)
        }
        .onAppear {
            weatherManager.fetchWeather()
        }
    }
}
