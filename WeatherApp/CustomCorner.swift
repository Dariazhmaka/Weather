//
//  CustomCorner.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct Corner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
