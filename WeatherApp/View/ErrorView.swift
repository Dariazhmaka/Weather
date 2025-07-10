//
//  ErrorView.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    var retryAction: (() -> Void)?
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text("Error loading data")
                .font(.headline)
                .foregroundColor(.white)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
            if let retryAction = retryAction {
                Button("Try Again") {
                    retryAction()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}
