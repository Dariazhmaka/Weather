//
//  ContentView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSearch = false
    
    var body: some View {
        ZStack {
            if let weather = locationManager.currentWeather {
                HomeView(weather: weather, topEdge: 0)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                LoadingView()
                    .onAppear {
                        locationManager.requestLocation()
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
            SearchView(locationManager: locationManager)
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
