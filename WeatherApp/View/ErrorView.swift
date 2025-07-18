//
//  ErrorView.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Error occurred")
                .font(.title)
            Text(error.localizedDescription)
                .padding()
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
    }
}
