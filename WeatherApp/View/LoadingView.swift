//
//  LoadingView.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            Text("Загрузка...")
                .foregroundColor(.white)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.3, blue: 0.7),
                Color(red: 0.3, green: 0.1, blue: 0.5)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}
