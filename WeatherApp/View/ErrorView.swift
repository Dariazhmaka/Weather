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
            Text(Strings.ErrorView.title)
                .font(.title)
            Text(error.localizedDescription)
                .padding()
            Button(Strings.ErrorView.retry, action: retryAction)
                .buttonStyle(.borderedProminent)
        }
    }
}
