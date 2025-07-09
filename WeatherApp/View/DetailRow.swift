//
//  DetailRow.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct DetailRow: View {
    var icon: String
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(title)
                .font(.caption)
            Spacer()
            Text(value)
                .font(.headline)
        }
        .foregroundColor(.white)
        .padding(.vertical, 5)
    }
}
