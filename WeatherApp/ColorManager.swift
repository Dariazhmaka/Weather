//
//  ColorManager.swift
//  WeatherApp
//
//  Created by Дарья on 16.07.2025.
//

import SwiftUI

struct ColorManager {

    struct Background {
        static let primary = Color("BackgroundPrimary")
        static let secondary = Color("BackgroundSecondary")
        
        static let sunnyTop = Color(red: 0.35, green: 0.78, blue: 0.98)
        static let sunnyBottom = Color(red: 0.45, green: 0.85, blue: 1.0)
        
        static let rainyTop = Color(red: 0.1, green: 0.1, blue: 0.3)
        static let rainyBottom = Color(red: 0.2, green: 0.2, blue: 0.4)
        
        static let snowyTop = Color(red: 0.15, green: 0.2, blue: 0.3)
        static let snowyBottom = Color(red: 0.25, green: 0.3, blue: 0.4)
        
        static let cloudyTop = Color(red: 0.3, green: 0.3, blue: 0.4)
        static let cloudyBottom = Color(red: 0.4, green: 0.4, blue: 0.5)
        
        static let foggyTop = Color(red: 0.4, green: 0.4, blue: 0.5)
        static let foggyBottom = Color(red: 0.5, green: 0.5, blue: 0.6)
        
        static let defaultTop = Color(red: 0.1, green: 0.2, blue: 0.4)
        static let defaultBottom = Color(red: 0.2, green: 0.1, blue: 0.3)
    }
    

    struct Text {
        static let primary = Color("TextPrimary")
        static let secondary = Color("TextSecondary")
        static let tertiary = Color("TextTertiary")
    }
    

    struct Card {
        static let background = Color("CardBackground")
        static let border = Color("CardBorder")
    }
    

    struct Button {
        static let background = Color("ButtonBackground")
        static let text = Color("ButtonText")
        static let icon = Color("ButtonIcon")
    }
    

    struct Accent {
        static let primary = Color("AccentPrimary")
        static let secondary = Color("AccentSecondary")
    }
    

    struct Divider {
        static let background = Color("DividerBackground")
    }
    

    struct TemperatureBar {
        static let background = Color("TemperatureBarBackground")
        static let fill = Color("TemperatureBarFill")
    }
    

    struct Icon {
        static let primary = Color("IconPrimary")
        static let secondary = Color("IconSecondary")
    }
    

    struct UI {
        static let cardBackground = Color.white.opacity(0.2)
        static let cardStroke = Color.white.opacity(0.1)
        static let divider = Color.white.opacity(0.3)
        
        static let selectedItem = Color.white.opacity(0.2)
        static let unselectedItem = Color.clear
        
        static let buttonPrimary = Color.blue
        static let buttonSecondary = Color.blue.opacity(0.2)
        
        static let progressBarBackground = Color.white.opacity(0.3)
        static let progressBarFill = Color.blue
    }
    

    struct Effects {
        static let sun = Color.yellow
        static let sunGlow = Color.yellow.opacity(0.3)
        static let rain = Color.blue
        static let snow = Color.white
        static let cloudLight = Color.white
        static let cloudMedium = Color(white: 0.8)
        static let cloudDark = Color(white: 0.6)
        static let fog = Color.white
    }
    

    static func backgroundGradient(for effectType: WeatherEffectType) -> LinearGradient {
        switch effectType {
        case .sun:
            return LinearGradient(
                gradient: Gradient(colors: [Background.sunnyTop, Background.sunnyBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .rain, .thunderstorm:
            return LinearGradient(
                gradient: Gradient(colors: [Background.rainyTop, Background.rainyBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .snow:
            return LinearGradient(
                gradient: Gradient(colors: [Background.snowyTop, Background.snowyBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .clouds:
            return LinearGradient(
                gradient: Gradient(colors: [Background.cloudyTop, Background.cloudyBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .fog:
            return LinearGradient(
                gradient: Gradient(colors: [Background.foggyTop, Background.foggyBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [Background.defaultTop, Background.defaultBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
