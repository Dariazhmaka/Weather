//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var weatherManager = WeatherManager(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(weatherManager)
                .preferredColorScheme(.dark)
        }
    }
}
