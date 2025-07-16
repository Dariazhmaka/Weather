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
    @State private var initialLoadDone = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            mainContent
            searchButton
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(weatherManager: weatherManager)
                .environmentObject(weatherManager)
                .environment(\.detailColors, DetailColors(
                    icon: .red,
                    title: .gray,
                    value: .black,
                    background: .yellow.opacity(0.1)
                )
        )}
        .onAppear {
            if weatherManager.currentWeather == nil {
                weatherManager.fetchWeather(for: "London") 
            }
        }
    }
}

private extension ContentView {
    var mainContent: some View {
        Group {
            switch (weatherManager.isLoading, weatherManager.error, weatherManager.currentWeather) {
            case (false, _, let weather?):
                HomeView(weather: weather, topEdge: 0)
                    .environmentObject(weatherManager)
                
            case (true, _, _):
                LoadingView()
                
            case (false, let error?, _):
                ErrorView(error: error, retryAction: retryLoading)
                
            default:
                welcomeView
            }
        }
    }
    
    var searchButton: some View {
        Button(action: toggleSearch) {
            Image(systemName: "magnifyingglass")
                .padding(10)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
        .padding()
    }
    
    var welcomeView: some View {
        VStack {
            Text("Welcome to WeatherApp")
                .font(.title)
            
            Button("Get Weather", action: loadInitialData)
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension ContentView {
    func handleInitialLoad() {
        guard !initialLoadDone else {
            return
        }
        loadInitialData()
    }
    
    func loadInitialData() {
        debugPrint("Starting initial load")
        initialLoadDone = true
        weatherManager.fetchWeather(for: "London")
    }
    
    func retryLoading() {
        debugPrint("Retrying load")
        weatherManager.fetchWeather(for: "London")
    }
    
    func toggleSearch() {
        showingSearch.toggle()
    }
}
