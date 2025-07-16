//
//  SettingsView.swift
//  WeatherApp
//
//  Created by Дарья on 16.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("showSunset") var showSunset = true
    @AppStorage("showHumidity") var showHumidity = true
    @AppStorage("showFeelsLike") var showFeelsLike = true
    @AppStorage("showPressure") var showPressure = true
    @AppStorage("showWind") var showWind = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Отображаемые элементы")) {
                    Toggle("Время заката/восхода", isOn: $showSunset)
                    Toggle("Влажность", isOn: $showHumidity)
                    Toggle("Ощущаемая температура", isOn: $showFeelsLike)
                    Toggle("Давление", isOn: $showPressure)
                    Toggle("Ветер", isOn: $showWind)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
