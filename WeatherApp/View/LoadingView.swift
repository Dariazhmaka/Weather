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
                .progressViewStyle(CircularProgressViewStyle(tint: ColorManager.textPrimary))
                .scaleEffect(1.5)
            Text(StringManager.loading)
                .foregroundColor(ColorManager.textPrimary)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [
                ColorManager.defaultBackgroundTop,
                ColorManager.defaultBackgroundBottom
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}
