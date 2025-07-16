//
//  WeatherEffectView.swift
//  WeatherApp
//
//  Created by Дарья on 14.07.2025.
//

import SwiftUI
import SpriteKit

struct WeatherEffectView: View {
    var effectType: WeatherEffectType
    var size: CGSize
    
    var body: some View {
        Group {
            switch effectType {
            case .rain:
                RainyView(size: size, withThunder: false)
            case .snow:
                SnowyView(size: size)
            case .fog:
                FoggyView(size: size)
            case .sun:
                SunnyView(size: size)
            case .clouds:
                CloudyView(size: size)
            case .thunderstorm:
                RainyView(size: size, withThunder: true)
            case .none:
                EmptyView()
            }
        }
        .frame(width: size.width, height: size.height)
        .ignoresSafeArea()
    }
}

struct SunnyView: View {
    let size: CGSize
    @State private var sunGlow = false
    @State private var rayRotation = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                ColorManager.sunBackgroundTop,
                ColorManager.sunBackgroundBottom
            ]), startPoint: .top, endPoint: .bottom)
            
            Circle()
                .fill(ColorManager.sunnyGradient)
                .frame(width: 120, height: 120)
                .position(x: size.width * 0.8, y: size.height * 0.2)
                .scaleEffect(sunGlow ? 1.1 : 1.0)
                .opacity(sunGlow ? 0.9 : 0.7)
                .animation(
                    Animation.easeInOut(duration: 2.0).repeatForever(),
                    value: sunGlow
                )
            
            SunRaysView()
                .frame(width: 300, height: 300)
                .position(x: size.width * 0.8, y: size.height * 0.2)
                .rotationEffect(.degrees(rayRotation))
                .onAppear {
                    withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                        rayRotation = 360
                    }
                }
            
            CloudsView(size: size, type: .light, opacityRange: 0.3...0.5)
        }
        .onAppear {
            sunGlow = true
        }
    }
}

struct SunRaysView: View {
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ColorManager.textPrimary.opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 80, height: 8)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
    }
}

// MARK: - Rainy Weather
struct RainyView: View {
    let size: CGSize
    let withThunder: Bool
    @State private var lightningFlash = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                ColorManager.rainBackgroundTop,
                ColorManager.rainBackgroundBottom
            ]), startPoint: .top, endPoint: .bottom)
            
            CloudsView(size: size, type: .dark, opacityRange: 0.7...0.9)
            
            RainView(size: size)
            
            if withThunder && lightningFlash {
                Rectangle()
                    .fill(ColorManager.textPrimary.opacity(0.3))
                    .ignoresSafeArea()
                    .animation(.easeOut(duration: 0.1), value: lightningFlash)
            }
        }
        .onAppear {
            if withThunder {
                startLightning()
            }
        }
    }
    
    private func startLightning() {
        let delay = Double.random(in: 5...15)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeIn(duration: 0.1)) {
                lightningFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.2)) {
                    lightningFlash = false
                }
                startLightning()
            }
        }
    }
}

struct RainView: View {
    let size: CGSize
    @State private var drops: [RainDrop] = []
    
    struct RainDrop: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var length: CGFloat
        var speed: CGFloat
    }
    
    init(size: CGSize) {
        self.size = size
        self._drops = State(initialValue: RainView.generateDrops(for: size))
    }
    
    var body: some View {
        ZStack {
            ForEach(drops) { drop in
                RainDropShape(length: drop.length)
                    .stroke(ColorManager.rainDropGradient, lineWidth: 1.5)
                    .position(x: drop.x, y: drop.y)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
                withAnimation(.linear(duration: 0.5)) {
                    drops = drops.map { drop in
                        var newDrop = drop
                        newDrop.y += drop.speed * 3
                        if newDrop.y > size.height {
                            newDrop.y = -drop.length
                            newDrop.x = CGFloat.random(in: 0..<size.width)
                        }
                        return newDrop
                    }
                }
            }
        }
    }
    
    static func generateDrops(for size: CGSize) -> [RainDrop] {
        (0..<150).map { _ in
            RainDrop(
                x: CGFloat.random(in: 0..<size.width),
                y: CGFloat.random(in: -size.height..<0),
                length: CGFloat.random(in: 15..<25),
                speed: CGFloat.random(in: 5..<10)
            )
        }
    }
}

struct RainDropShape: Shape {
    var length: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + length))
        return path
    }
}

// MARK: - Snowy Weather
struct SnowyView: View {
    let size: CGSize
    @State private var snowflakes: [Snowflake] = []
    
    struct Snowflake: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var speed: CGFloat
        var opacity: Double
        var rotation: Double
        var rotationSpeed: Double
    }
    
    init(size: CGSize) {
        self.size = size
        self._snowflakes = State(initialValue: SnowyView.generateSnowflakes(for: size))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                ColorManager.snowBackgroundTop,
                ColorManager.snowBackgroundBottom
            ]), startPoint: .top, endPoint: .bottom)
            
            CloudsView(size: size, type: .light, opacityRange: 0.4...0.6)
            
            ForEach(snowflakes) { flake in
                SnowflakeShape()
                    .fill(ColorManager.textPrimary.opacity(flake.opacity))
                    .frame(width: flake.size, height: flake.size)
                    .rotationEffect(.degrees(flake.rotation))
                    .position(x: flake.x, y: flake.y)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                withAnimation(.linear(duration: 2)) {
                    snowflakes = snowflakes.map { flake in
                        var newFlake = flake
                        newFlake.y += flake.speed
                        newFlake.rotation += flake.rotationSpeed
                        
                        if newFlake.y > size.height {
                            newFlake.y = -20
                            newFlake.x = CGFloat.random(in: 0..<size.width)
                        }
                        
                        return newFlake
                    }
                }
            }
        }
    }
    
    static func generateSnowflakes(for size: CGSize) -> [Snowflake] {
        (0..<60).map { _ in
            Snowflake(
                x: CGFloat.random(in: 0..<size.width),
                y: CGFloat.random(in: -size.height..<0),
                size: CGFloat.random(in: 2...8),
                speed: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.5...0.9),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: 0.1...0.5)
            )
        }
    }
}

struct SnowflakeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let tip = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            
            let branch1 = CGPoint(
                x: center.x + radius * 0.5 * cos(angle - .pi/6),
                y: center.y + radius * 0.5 * sin(angle - .pi/6)
            )
            
            let branch2 = CGPoint(
                x: center.x + radius * 0.5 * cos(angle + .pi/6),
                y: center.y + radius * 0.5 * sin(angle + .pi/6)
            )
            
            path.move(to: center)
            path.addLine(to: tip)
            path.move(to: tip)
            path.addLine(to: branch1)
            path.move(to: tip)
            path.addLine(to: branch2)
        }
        
        return path
    }
}

// MARK: - Cloudy Weather
struct CloudyView: View {
    let size: CGSize
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                ColorManager.cloudsBackgroundTop,
                ColorManager.cloudsBackgroundBottom
            ]), startPoint: .top, endPoint: .bottom)
            
            CloudsView(size: size, type: .medium, opacityRange: 0.5...0.8)
        }
    }
}

// MARK: - Foggy Weather
struct FoggyView: View {
    let size: CGSize
    @State private var fogOpacity: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                ColorManager.cloudsBackgroundTop,
                ColorManager.cloudsBackgroundBottom
            ]), startPoint: .top, endPoint: .bottom)
            
            ForEach(0..<3) { i in
                FogLayer(depth: Double(i) / 3)
                    .opacity(fogOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2)) {
                fogOpacity = 1
            }
        }
    }
}

struct FogLayer: View {
    let depth: Double
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(ColorManager.fogGradient)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(x: offset)
            .animation(
                Animation.linear(duration: 20 + Double.random(in: 0...10))
                    .repeatForever(autoreverses: false),
                value: offset
            )
            .onAppear {
                offset = CGFloat.random(in: -100...100)
            }
    }
}

// MARK: - Clouds Component
enum CloudType {
    case light
    case medium
    case dark
}

struct CloudsView: View {
    let size: CGSize
    let type: CloudType
    let opacityRange: ClosedRange<Double>
    @State private var clouds: [Cloud] = []
    
    struct Cloud: Identifiable {
        let id = UUID()
        var position: CGPoint
        var size: CGFloat
        var speed: CGFloat
        var opacity: Double
        var style: Int
    }
    
    init(size: CGSize, type: CloudType, opacityRange: ClosedRange<Double>) {
        self.size = size
        self.type = type
        self.opacityRange = opacityRange
        self._clouds = State(initialValue: CloudsView.generateClouds(for: size, type: type, opacityRange: opacityRange))
    }
    
    var body: some View {
        ZStack {
            ForEach(clouds) { cloud in
                if cloud.style == 0 {
                    CloudShape1()
                        .fill(ColorManager.cloudColor(for: type).opacity(cloud.opacity))
                        .frame(width: cloud.size, height: cloud.size * 0.6)
                        .position(cloud.position)
                } else {
                    CloudShape2()
                        .fill(ColorManager.cloudColor(for: type).opacity(cloud.opacity))
                        .frame(width: cloud.size, height: cloud.size * 0.5)
                        .position(cloud.position)
                }
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                withAnimation(.linear(duration: 2)) {
                    clouds = clouds.map { cloud in
                        var newCloud = cloud
                        newCloud.position.x += cloud.speed
                        
                        if newCloud.position.x > size.width + cloud.size {
                            newCloud.position.x = -cloud.size
                            newCloud.position.y = CGFloat.random(in: 0..<(size.height/2))
                        }
                        
                        return newCloud
                    }
                }
            }
        }
    }
    
    static func generateClouds(for size: CGSize, type: CloudType, opacityRange: ClosedRange<Double>) -> [Cloud] {
        let cloudCount: Int
        let sizeRange: ClosedRange<CGFloat>
        let speedRange: ClosedRange<CGFloat>
        
        switch type {
        case .light:
            cloudCount = 4
            sizeRange = 80...180
            speedRange = 0.1...0.3
        case .medium:
            cloudCount = 6
            sizeRange = 100...220
            speedRange = 0.2...0.4
        case .dark:
            cloudCount = 8
            sizeRange = 120...250
            speedRange = 0.3...0.6
        }
        
        return (0..<cloudCount).map { _ in
            Cloud(
                position: CGPoint(
                    x: CGFloat.random(in: -size.width..<size.width),
                    y: CGFloat.random(in: 0..<(size.height/3))
                ),
                size: CGFloat.random(in: sizeRange),
                speed: CGFloat.random(in: speedRange),
                opacity: Double.random(in: opacityRange),
                style: Int.random(in: 0...1)
            )
        }
    }
}

struct CloudShape1: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.addEllipse(in: CGRect(x: width * 0.1, y: height * 0.3, width: width * 0.3, height: height * 0.5))
        path.addEllipse(in: CGRect(x: width * 0.3, y: height * 0.1, width: width * 0.5, height: height * 0.6))
        path.addEllipse(in: CGRect(x: width * 0.6, y: height * 0.2, width: width * 0.4, height: height * 0.5))
        
        return path
    }
}

struct CloudShape2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.addEllipse(in: CGRect(x: width * 0.2, y: height * 0.4, width: width * 0.6, height: height * 0.4))
        path.addEllipse(in: CGRect(x: width * 0.4, y: height * 0.2, width: width * 0.5, height: height * 0.5))
        path.addEllipse(in: CGRect(x: width * 0.1, y: height * 0.3, width: width * 0.4, height: height * 0.4))
        path.addEllipse(in: CGRect(x: width * 0.7, y: height * 0.3, width: width * 0.3, height: height * 0.3))
        
        return path
    }
}

extension WeatherEffectManager {
    static func conditionFromIcon(_ icon: String) -> String {
        if icon.contains("sun") {
            return "clear"
        } else if icon.contains("cloud") {
            return "clouds"
        } else if icon.contains("rain") {
            return "rain"
        } else if icon.contains("snow") {
            return "snow"
        } else if icon.contains("bolt") {
            return "thunderstorm"
        }
        return "clear"
    }
}
