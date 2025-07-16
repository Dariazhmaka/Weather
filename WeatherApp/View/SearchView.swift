//
//  SearchView.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var weatherManager: WeatherManager
    @State private var searchText = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @Environment(\.presentationMode) var presentationMode
    
    private var filteredCities: [String] {
        searchText.isEmpty ?
            Strings.SearchView.popularCities.components(separatedBy: ", ") :
            Strings.SearchView.popularCities.components(separatedBy: ", ").filter {
                $0.lowercased().contains(searchText.lowercased())
            }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                SearchBar(text: $searchText, placeholder: Strings.SearchView.searchCity)
                    .padding(.horizontal)
                
                Button(action: useCurrentLocation) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(ColorManager.Button.icon)
                        Text(Strings.Common.myLocation)
                            .foregroundColor(ColorManager.Button.text)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorManager.Button.background)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                VStack(spacing: 10) {
                    Text(Strings.SearchView.coordinatesPrompt)
                        .font(.caption)
                        .foregroundColor(ColorManager.Text.secondary)
                    
                    HStack {
                        TextField(Strings.SearchView.latitude, text: $latitude)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                            .colorScheme(.dark)
                        
                        TextField(Strings.SearchView.longitude, text: $longitude)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                            .colorScheme(.dark)
                    }
                    .padding(.horizontal)
                    
                    Button(action: searchByCoordinates) {
                        Text(Strings.SearchView.searchByCoordinates)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorManager.Accent.primary)
                            .foregroundColor(ColorManager.Button.text)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(latitude.isEmpty || longitude.isEmpty)
                }
                
                List {
                    Section(header:
                        Text(Strings.SearchView.popularCities)
                            .foregroundColor(ColorManager.Text.secondary)
                    ) {
                        ForEach(filteredCities, id: \.self) { city in
                            Button(action: { searchByCity(city) }) {
                                Text(city)
                                    .foregroundColor(ColorManager.Text.primary)
                            }
                        }
                    }
                }
                .background(ColorManager.Background.primary)
            }
            .background(ColorManager.Background.primary)
            .navigationTitle(Strings.SearchView.searchCity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Strings.Common.close) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(ColorManager.Button.text)
                }
            }
        }
    }
    
    private func useCurrentLocation() {
        weatherManager.locationService.requestLocation()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func searchByCity(_ city: String) {
        weatherManager.fetchWeather(for: city)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func searchByCoordinates() {
        if let lat = Double(latitude), let lon = Double(longitude) {
            weatherManager.fetchWeather(for: "\(lat),\(lon)")
            presentationMode.wrappedValue.dismiss()
        }
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
}
