//
//  CustomCorner.swift
//  WeatherApp
//
//  Created by Дарья on 09.07.2025.
//

import SwiftUI

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        if corners.contains(.topRight) {
            path.addLine(to: CGPoint(x: topRight.x - radius, y: topRight.y))
            path.addArc(
                center: CGPoint(x: topRight.x - radius, y: topRight.y + radius),
                radius: radius,
                startAngle: Angle(degrees: -90),
                endAngle: Angle(degrees: 0),
                clockwise: false
            )
        } else {
            path.addLine(to: topRight)
        }
        
        if corners.contains(.bottomRight) {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - radius))
            path.addArc(
                center: CGPoint(x: bottomRight.x - radius, y: bottomRight.y - radius),
                radius: radius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
        } else {
            path.addLine(to: bottomRight)
        }
        
        if corners.contains(.bottomLeft) {
            path.addLine(to: CGPoint(x: bottomLeft.x + radius, y: bottomLeft.y))
            path.addArc(
                center: CGPoint(x: bottomLeft.x + radius, y: bottomLeft.y - radius),
                radius: radius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
        } else {
            path.addLine(to: bottomLeft)
        }
        
        if corners.contains(.topLeft) {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + radius))
            path.addArc(
                center: CGPoint(x: topLeft.x + radius, y: topLeft.y + radius),
                radius: radius,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: 270),
                clockwise: false
            )
        } else {
            path.addLine(to: topLeft)
        }
        
        path.closeSubpath()
        return path
    }
}
