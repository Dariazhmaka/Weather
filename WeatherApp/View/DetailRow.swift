//
//  DetailRow.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct DetailColors {
    var icon: Color
    var title: Color
    var value: Color
    var background: Color
}

private struct DetailColorsKey: EnvironmentKey {
    static let defaultValue = DetailColors(
        icon: .blue.opacity(0.8),
        title: .primary.opacity(0.7),
        value: .primary,
        background: .clear
    )
}

extension EnvironmentValues {
    var detailColors: DetailColors {
        get { self[DetailColorsKey.self] }
        set { self[DetailColorsKey.self] = newValue }
    }
}

struct DetailRow: View {
    var icon: String
    var title: String
    var value: String
    
    @Environment(\.detailColors) private var colors
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(colors.icon)
            
            Text(title)
                .font(.caption)
                .foregroundColor(colors.title)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(colors.value)
        }
        .padding(.vertical, 5)
        .background(colors.background)
    }
}
