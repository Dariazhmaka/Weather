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
                ZStack {
                    RainFallView(size: size)
                    RainSplashView(size: size)
                }
            case .snow:
                SnowFallView(size: size)
            case .sun:
                SunRayView()
                    .opacity(0.4)
            case .clouds:
                CloudsView(size: size)
                    .opacity(0.6)
            case .thunderstorm:
                ZStack {
                    RainFallView(size: size)
                    ThunderstormView(size: size)
                }
            case .fog:
                FogView(size: size)
            default:
                EmptyView()
            }
        }
    }
}

struct Raindrop: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var length: CGFloat
    var speed: CGFloat
}

struct RaindropView: View {
    let raindrop: Raindrop
    let size: CGSize
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: raindrop.x, y: raindrop.y))
            path.addLine(to: CGPoint(x: raindrop.x, y: raindrop.y + raindrop.length))
        }
        .stroke(Color.blue.opacity(0.6), lineWidth: 1)
    }
}

struct RainFallView: View {
    let size: CGSize
    @State private var raindrops: [Raindrop] = []
    
    init(size: CGSize) {
        self.size = size
        self._raindrops = State(initialValue: RainFallView.generateRaindrops(for: size))
    }
    
    var body: some View {
        ZStack {
            ForEach(raindrops) { raindrop in
                RaindropView(raindrop: raindrop, size: size)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                withAnimation(.linear(duration: 1.5)) {
                    raindrops = raindrops.map { raindrop in
                        var newDrop = raindrop
                        newDrop.y += 10
                        if newDrop.y > size.height {
                            newDrop.y = -20
                            newDrop.x = CGFloat.random(in: 0..<size.width)
                        }
                        return newDrop
                    }
                }
            }
        }
    }
    
    static func generateRaindrops(for size: CGSize) -> [Raindrop] {
        (0..<100).map { _ in
            Raindrop(
                id: UUID(),
                x: CGFloat.random(in: 0..<size.width),
                y: CGFloat.random(in: -size.height..<size.height),
                length: CGFloat.random(in: 10..<20),
                speed: CGFloat.random(in: 1..<3)
            )
        }
    }
}

struct RainSplashView: View {
    let size: CGSize
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.3))
            .frame(width: 2, height: 2)
            .position(x: CGFloat.random(in: 0..<size.width),
                     y: size.height - 10)
    }
}

struct SnowFallView: View {
    let size: CGSize
    
    var body: some View {
        ForEach(0..<50, id: \.self) { _ in
            Circle()
                .fill(Color.white)
                .frame(width: CGFloat.random(in: 2...5))
                .position(
                    x: CGFloat.random(in: 0..<size.width),
                    y: CGFloat.random(in: 0..<size.height)
                )
                .animation(
                    Animation.linear(duration: Double.random(in: 5...10))
                        .repeatForever(autoreverses: false),
                    value: UUID()
                )
        }
    }
}

struct CloudsView: View {
    let size: CGSize
    
    var body: some View {
        ForEach(0..<5, id: \.self) { _ in
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: CGFloat.random(in: 100...200))
                .position(
                    x: CGFloat.random(in: 0..<size.width),
                    y: CGFloat.random(in: 0..<size.height/3))
                
        }
    }
}

struct ThunderstormView: View {
    let size: CGSize
    @State private var isFlashing = false
    
    var body: some View {
        Rectangle()
            .fill(isFlashing ? Color.white.opacity(0.3) : Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                flashLightning()
            }
    }
    
    private func flashLightning() {
        let delay = Double.random(in: 3...8)
        Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                isFlashing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isFlashing = false
                }
            }
        }
    }
}

struct FogView: View {
    let size: CGSize
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SunRayView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .yellow.opacity(0.4),
                                .clear
                            ]),
                            center: .center,
                            startAngle: .degrees(Double(i) * 30),
                            endAngle: .degrees(Double(i) * 30 + 15)
                        )
                    )
                    .frame(width: 2, height: 300)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}
