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
                            .foregroundColor(ColorManager.Text.primary)
                        Spacer()
                        if city.id == weatherManager.currentCity?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(ColorManager.Accent.primary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectCity(city)
                    }
                }
                .onDelete(perform: deleteCities)
            }
            .background(ColorManager.Background.primary)
            .navigationTitle(Strings.SavedCitiesView.title)
            .navigationBarItems(
                leading: Button(Strings.Common.edit) {
                },
                trailing: HStack {
                    Button(action: { showingAddAlert = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(ColorManager.Button.text)
                    }
                    Button(Strings.Common.done) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(ColorManager.Button.text)
                }
            )
            .alert(isPresented: $showingAddAlert) {
                Alert(
                    title: Text(Strings.SavedCitiesView.addCityTitle),
                    message: Text(Strings.SavedCitiesView.addCityMessage),
                    primaryButton: .default(Text(Strings.Common.add), action: addCurrentCity),
                    secondaryButton: .cancel(Text(Strings.Common.cancel))
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
