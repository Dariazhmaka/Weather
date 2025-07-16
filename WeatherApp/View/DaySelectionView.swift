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
        formatter.locale = Locale(identifier: "ru_RU")
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
                                .foregroundColor(
                                    Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                    ? ColorManager.Text.primary
                                    : ColorManager.Text.secondary
                                )
                            
                            if Calendar.current.isDate(date, inSameDayAs: Date()) {
                                Text(Strings.DaySelectionView.today)
                                    .font(.caption2)
                                    .foregroundColor(ColorManager.Text.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            ? ColorManager.UI.selectedItem
                            : ColorManager.UI.unselectedItem
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ColorManager.UI.cardStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DaySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let dates = (0..<7).map { Calendar.current.date(byAdding: .day, value: $0, to: Date())! }
        
        DaySelectionView(
            selectedDate: .constant(Date()),
            availableDates: dates
        )
        .preferredColorScheme(.dark)
    }
}
