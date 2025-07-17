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
    
    private let sampleCities = [
        "New York", "London", "Paris", "Tokyo", "Berlin",
        "Moscow", "Sydney", "Dubai", "Singapore", "Shanghai",
        "Rome", "Madrid", "Toronto", "Chicago", "Los Angeles"
    ]
    
    private var filteredCities: [String] {
        searchText.isEmpty ? sampleCities : sampleCities.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                SearchBar(text: $searchText, placeholder: StringManager.selectCity)
                    .padding(.horizontal)
                
                Button(action: useCurrentLocation) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text(StringManager.myLocation)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorManager.buttonBackground)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                   
                List {
                    Section(header: Text(StringManager.popularCities)) {
                        ForEach(filteredCities, id: \.self) { city in
                            Button(action: { searchByCity(city) }) {
                                Text(city)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Выбрать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(StringManager.close) {
                        presentationMode.wrappedValue.dismiss()
                    }
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
