//
//  ContentView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject private var weatherManager: WeatherManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSearch = false
    
    var body: some View {
        ZStack {
            if let weather = weatherManager.currentWeather {
                HomeView(weather: weather, topEdge: 0)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                LoadingView()
                    .onAppear {
                        weatherManager.fetchWeather()
                    }
            }
            
            VStack {
                HStack {
                    Spacer()
                    searchButton
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(locationManager: weatherManager)
        }
        .onChange(of: weatherManager.currentWeather) { oldValue, newValue in
            weatherManager.isForecastLoaded = false
        }
    }
    
    private var searchButton: some View {
        Button(action: {
            showSearch.toggle()
        }) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
        .padding(.trailing)
        .padding(.top, 50)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            Text("Loading weather data...")
                .foregroundColor(.white)
                .padding(.top, 10)
        }
    }
}
