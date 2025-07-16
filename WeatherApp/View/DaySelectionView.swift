//
//  DaySelectionView.swift
//  WeatherApp
//
//  Created by Дарья on 10.07.2025.
//

import SwiftUI

struct DaySelectionView: View {
    @Binding var selectedDate: Date
    let availableDates: [Date]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d"
        return formatter
    }()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(availableDates, id: \.self) { date in
                    Button(action: {
                        selectedDate = date
                    }) {
                        VStack(spacing: 5) {
                            Text(dateFormatter.string(from: date))
                                .font(.subheadline)
                            if Calendar.current.isDate(date, inSameDayAs: Date()) {
                                Text(StringManager.today)
                                    .font(.caption2)
                            }
                        }
                        .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? ColorManager.textPrimary : ColorManager.textSecondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Calendar.current.isDate(date, inSameDayAs: selectedDate) ?
                            ColorManager.selectedButtonBackground : Color.clear
                        )
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
