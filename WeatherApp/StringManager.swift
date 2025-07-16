//
//  StringManager.swift
//  WeatherApp
//
//  Created by Дарья on 16.07.2025.
//

struct StringManager {
    // Common strings
    static let close = "Закрыть"
    static let done = "Готово"
    static let add = "Добавить"
    static let cancel = "Отмена"
    static let loading = "Загрузка..."
    static let errorTitle = "Ошибка загрузки"
    static let retry = "Повторить"
    static let welcomeTitle = "Добро пожаловать в Погода"
    static let getWeather = "Получить погоду"
    
    // Search view strings
    static let selectCity = "Выбрать город"
    static let myLocation = "Мое местоположение"
    static let selectByCoordinates = "Выбор по координитам:"
    static let selectByCoordinatesButton = "выбор по координатам"
    static let popularCities = "Популярные города"
    
    // Saved cities strings
    static let myCities = "Мои города"
    static let addCityTitle = "Добавить город"
    static let addCityMessage = "Добавить текущий город в список?"
    static let searchCityPlaceholder = "Поиск города"
    static let noCitiesAvailable = "Нет доступных городов для добавления"
    
    // Weather details strings
    static let hourlyForecast = "ПОЧАСОВОЙ ПРОГНОЗ"
    static let weatherDetails = "ДЕТАЛИ ПОГОДЫ"
    static let weeklyForecast = "ПРОГНОЗ НА НЕДЕЛЮ"
    static let today = "Сегодня"
    
    // Weather parameters
    static let humidity = "Влажность"
    static let wind = "Ветер"
    static let pressure = "Давление"
    static let feelsLike = "Ощущается"
    static let maxTemp = "Макс"
    static let minTemp = "Мин"
    
    // Units
    static let metersPerSecond = "м/с"
    static let hPa = "гПа"
    static let percent = "%"
    
    static func temperatureString(_ temp: Double) -> String {
        "\(Int(temp))°"
    }
    
    static func humidityString(_ value: Int) -> String {
        "\(value)\(percent)"
    }
    
    static func windSpeedString(_ speed: Double) -> String {
        "\(String(format: "%.1f", speed)) \(metersPerSecond)"
    }
    
    static func pressureString(_ value: Int) -> String {
        "\(value) \(hPa)"
    }
}
