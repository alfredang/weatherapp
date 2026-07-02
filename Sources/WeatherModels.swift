import Foundation
import CoreLocation

// MARK: - Geocoding (Open-Meteo geocoding API)

struct GeocodingResponse: Decodable {
    let results: [GeoPlace]?
}

struct GeoPlace: Decodable, Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?          // state / region

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// "Singapore, Singapore" / "Austin, Texas, United States"
    var displayName: String {
        [name, admin1, country].compactMap { $0 }.joined(separator: ", ")
    }
}

// MARK: - Forecast (Open-Meteo forecast API)

struct ForecastResponse: Decodable {
    let current: CurrentWeather
    let currentUnits: CurrentUnits
    let timezone: String?            // IANA id, resolved by `timezone=auto`

    enum CodingKeys: String, CodingKey {
        case current, timezone
        case currentUnits = "current_units"
    }
}

struct CurrentWeather: Decodable {
    let temperature: Double
    let apparentTemperature: Double
    let humidity: Int
    let windSpeed: Double
    let weatherCode: Int
    let isDay: Int

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case humidity = "relative_humidity_2m"
        case windSpeed = "wind_speed_10m"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}

struct CurrentUnits: Decodable {
    let temperature: String
    let windSpeed: String

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case windSpeed = "wind_speed_10m"
    }
}

// MARK: - WMO weather-code interpretation

/// Maps a WMO weather code to a human label + SF Symbol (day/night aware).
struct WeatherCondition {
    let label: String
    let symbol: String

    static func from(code: Int, isDay: Bool) -> WeatherCondition {
        let sunOrMoon = isDay ? "sun.max.fill" : "moon.stars.fill"
        switch code {
        case 0:        return .init(label: "Clear sky", symbol: sunOrMoon)
        case 1:        return .init(label: "Mainly clear", symbol: isDay ? "sun.max.fill" : "moon.fill")
        case 2:        return .init(label: "Partly cloudy", symbol: isDay ? "cloud.sun.fill" : "cloud.moon.fill")
        case 3:        return .init(label: "Overcast", symbol: "cloud.fill")
        case 45, 48:   return .init(label: "Fog", symbol: "cloud.fog.fill")
        case 51, 53, 55: return .init(label: "Drizzle", symbol: "cloud.drizzle.fill")
        case 56, 57:   return .init(label: "Freezing drizzle", symbol: "cloud.sleet.fill")
        case 61, 63, 65: return .init(label: "Rain", symbol: "cloud.rain.fill")
        case 66, 67:   return .init(label: "Freezing rain", symbol: "cloud.sleet.fill")
        case 71, 73, 75: return .init(label: "Snow", symbol: "cloud.snow.fill")
        case 77:       return .init(label: "Snow grains", symbol: "cloud.snow.fill")
        case 80, 81, 82: return .init(label: "Rain showers", symbol: "cloud.heavyrain.fill")
        case 85, 86:   return .init(label: "Snow showers", symbol: "cloud.snow.fill")
        case 95:       return .init(label: "Thunderstorm", symbol: "cloud.bolt.rain.fill")
        case 96, 99:   return .init(label: "Thunderstorm, hail", symbol: "cloud.bolt.rain.fill")
        default:       return .init(label: "Unknown", symbol: "questionmark.circle.fill")
        }
    }
}

/// A fully-resolved weather result for one place, ready to render.
struct WeatherResult {
    let place: GeoPlace
    let current: CurrentWeather
    let units: CurrentUnits
    let timezoneID: String?

    var condition: WeatherCondition {
        WeatherCondition.from(code: current.weatherCode, isDay: current.isDay == 1)
    }

    /// The place's local time zone (from the forecast response), for the live clock.
    var timeZone: TimeZone? {
        timezoneID.flatMap { TimeZone(identifier: $0) }
    }
}
