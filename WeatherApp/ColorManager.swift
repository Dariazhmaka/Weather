//
//  ColorManager.swift
//  WeatherApp
//
//  Created by Дарья on 16.07.2025.
//

import SwiftUI

struct ColorManager {
    // Background colors
    static let rainBackgroundTop = Color(red: 0.1, green: 0.1, blue: 0.3)
    static let rainBackgroundBottom = Color(red: 0.2, green: 0.2, blue: 0.4)
    
    static let snowBackgroundTop = Color(red: 0.15, green: 0.2, blue: 0.3)
    static let snowBackgroundBottom = Color(red: 0.25, green: 0.3, blue: 0.4)
    
    static let sunBackgroundTop = Color(red: 0.3, green: 0.5, blue: 0.9)
    static let sunBackgroundBottom = Color(red: 0.5, green: 0.7, blue: 1.0)
    
    static let cloudsBackgroundTop = Color(red: 0.3, green: 0.3, blue: 0.4)
    static let cloudsBackgroundBottom = Color(red: 0.4, green: 0.4, blue: 0.5)
    
    static let defaultBackgroundTop = Color(red: 0.1, green: 0.2, blue: 0.4)
    static let defaultBackgroundBottom = Color(red: 0.2, green: 0.1, blue: 0.3)
    
    static let buttonBackground = Color.blue.opacity(0.2)
    static let selectedButtonBackground = Color.white.opacity(0.3)
    static let cardStroke = Color.white.opacity(0.1)
    static let dividerColor = Color.white.opacity(0.3)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    
    // Weather effect colors
    static let sunnyGradient = RadialGradient(
        gradient: Gradient(colors: [.white, .yellow.opacity(0.3), .clear]),
        center: .center,
        startRadius: 0,
        endRadius: 150
    )
    
    static let rainDropGradient = LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.white.opacity(0.8)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let fogGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.4)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static func cloudColor(for type: CloudType) -> Color {
        switch type {
        case .light: return .white
        case .medium: return Color(white: 0.8)
        case .dark: return Color(white: 0.6)
        }
    }
}
