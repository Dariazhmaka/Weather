//
//  SearchView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Search for a city")
                    .padding()
                List {
                    currentLocationButton
                    
                    ForEach(filteredCities, id: \.self) { city in
                        Button(action: {
                            selectCity(city)
                        }) {
                            Text(city)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var currentLocationButton: some View {
        Button(action: {
            locationManager.fetchWeather()
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "location.fill")
                Text("Use current location")
            }
        }
    }
    
    private func selectCity(_ city: String) {
        locationManager.fetchWeather(for: city)
        presentationMode.wrappedValue.dismiss()
    }
    
    private var filteredCities: [String] {
        if searchText.isEmpty {
            return sampleCities
        } else {
            return sampleCities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private let sampleCities = [
        "New York", "London", "Paris", "Tokyo", "Berlin",
        "Moscow", "Sydney", "Dubai", "Singapore", "Shanghai",
        "Rome", "Madrid", "Toronto", "Chicago", "Los Angeles"
    ]
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
        uiView.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
}
