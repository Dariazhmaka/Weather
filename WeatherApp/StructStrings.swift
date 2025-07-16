//
//  StructStrings.swift
//  WeatherApp
//
//  Created by Дарья on 16.07.2025.
//

import Foundation

struct Strings {
    struct Common {
        static let today = "Сегодня"
        static let close = "Закрыть"
        static let done = "Готово"
        static let add = "Добавить"
        static let cancel = "Отмена"
        static let edit = "Редактировать"
        static let myLocation = "Мое местоположение"
        static let loading = "Загрузка..."
    }
    
    struct ErrorView {
        static let title = "Ошибка загрузки"
        static let retry = "Повторить"
    }
    
    struct ContentView {
        static let welcome = "Добро пожаловать в Погода"
        static let getWeather = "Получить погоду"
        static let myCities = "Мои города"
    }
    
    struct DaySelectionView {
        static let today = "Сегодня"
    }
    
    struct HomeView {
        static let hourlyForecast = "ПОЧАСОВОЙ ПРОГНОЗ"
        static let dailyForecast = "ПРОГНОЗ НА НЕДЕЛЮ"
        static let weatherDetails = "ДЕТАЛИ ПОГОДЫ"
        static let feelsLike = "Ощущается"
        static let maxTemp = "Макс"
        static let minTemp = "Мин"
    }
    
    struct LoadingView {
        static let loading = "Загрузка..."
    }
    
    struct SearchView {
        static let searchCity = "Выбрать город"
        static let searchByCoordinates = "выбор по координатам"
        static let coordinatesPrompt = "Выбор по координитам:"
        static let popularCities = "Популярные города"
        static let latitude = "Широта"
        static let longitude = "Долгота"
    }
    
    struct SavedCitiesView {
        static let title = "Мои города"
        static let addCityTitle = "Добавить город"
        static let addCityMessage = "Добавить текущий город в список?"
    }
    
    struct WeatherDetails {
        static let humidity = "Влажность"
        static let wind = "Ветер"
        static let pressure = "Давление"
        static let windSpeedUnit = "м/с"
        static let pressureUnit = "гПа"
    }
    
    struct WeatherConditions {
        static let clear = "Ясно"
        static let clouds = "Облачно"
        static let rain = "Дождь"
        static let snow = "Снег"
        static let fog = "Туман"
        static let thunderstorm = "Гроза"
    }
}
