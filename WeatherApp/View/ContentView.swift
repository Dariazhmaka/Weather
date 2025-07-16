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
    @State private var showingSettings = false
    @State private var initialLoadCompleted = false
    
    var body: some View {
        ZStack {
            if let weather = weatherManager.currentWeather {
                HomeView(topEdge: 0)
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
                                        Image(systemName: "list.bullet")
                                                .padding(10)
                                                .background(ColorManager.buttonBackground)
                                                .foregroundColor(ColorManager.buttonIconColor)
                                                .clipShape(Circle())
                                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                                }
                                                .padding(.leading)
                                                          
                        Spacer()
                                   
                                   HStack(spacing: 10) {
                                       Button(action: { showingSettings.toggle() }) {
                                           Image(systemName: "gearshape")
                                               .padding(10)
                                               .background(ColorManager.buttonBackground)
                                               .foregroundColor(ColorManager.buttonIconColor)
                                               .clipShape(Circle())
                                       }
                                       
                                       Button(action: { showingSearch.toggle() }) {
                                           Image(systemName: "magnifyingglass")
                                               .padding(10)
                                               .background(ColorManager.buttonBackground)
                                               .foregroundColor(ColorManager.buttonIconColor)
                                               .clipShape(Circle())
                                       }
                                   }
                                   .padding(.trailing)
                               }
                               .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                               
                               Spacer()
                           }
                       }
                   }
        .sheet(isPresented: $showingSettings) {
                    SettingsView()
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
