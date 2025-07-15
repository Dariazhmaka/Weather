//
//  SavedCitiesView.swift
//  WeatherApp
//
//  Created by Дарья on 15.07.2025.
//

import SwiftUI

struct SavedCitiesView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(weatherManager.savedCities) { city in
                    HStack {
                        Text(city.name)
                        Spacer()
                        if city.id == weatherManager.currentCity?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectCity(city)
                    }
                }
                .onDelete(perform: deleteCities)
            }
            .navigationTitle("Мои города")
            .navigationBarItems(
                leading: EditButton(),
                trailing: HStack {
                    Button(action: { showingAddAlert = true }) {
                        Image(systemName: "plus")
                    }
                    Button("Готово") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
            .alert(isPresented: $showingAddAlert) {
                Alert(
                    title: Text("Добавить город"),
                    message: Text("Добавить текущий город в список?"),
                    primaryButton: .default(Text("Добавить"), action: addCurrentCity),
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func addCurrentCity() {
        guard let weather = weatherManager.currentWeather else { return }
        let city = SavedCity(
            name: weather.city,
            latitude: weather.latitude,
            longitude: weather.longitude
        )
        weatherManager.addCity(city)
    }
    
    private func selectCity(_ city: SavedCity) {
        weatherManager.switchToCity(city)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteCities(at offsets: IndexSet) {
        weatherManager.removeCity(at: offsets)
    }
}
