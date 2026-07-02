import Foundation

enum WeatherError: LocalizedError {
    case placeNotFound
    case badResponse

    var errorDescription: String? {
        switch self {
        case .placeNotFound: return "We couldn't find that place. Try another city or town."
        case .badResponse:   return "The weather service returned an unexpected response."
        }
    }
}

/// Talks to the free Open-Meteo geocoding + forecast APIs.
/// Endpoints and the (optional) API key are read from Info.plist so they can be
/// changed without touching code. Open-Meteo's free tier needs no key; if an
/// `OpenMeteoAPIKey` is present it is appended as `apikey=` for the commercial tier.
struct WeatherService {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    private func infoValue(_ key: String) -> String? {
        guard let v = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !v.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return v
    }

    private var geocodingBase: String {
        infoValue("OpenMeteoGeocodingURL") ?? "https://geocoding-api.open-meteo.com/v1/search"
    }
    private var forecastBase: String {
        infoValue("OpenMeteoAPIBaseURL") ?? "https://api.open-meteo.com/v1/forecast"
    }
    private var apiKey: String? { infoValue("OpenMeteoAPIKey") }

    /// Geocode a free-text query (city / place) to its top match.
    func geocode(_ query: String) async throws -> GeoPlace {
        guard var comps = URLComponents(string: geocodingBase) else { throw WeatherError.badResponse }
        comps.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json"),
        ] + keyItem()
        guard let url = comps.url else { throw WeatherError.badResponse }

        let (data, response) = try await session.data(from: url)
        try Self.validate(response)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        guard let place = decoded.results?.first else { throw WeatherError.placeNotFound }
        return place
    }

    /// Fetch current weather for a geocoded place.
    func currentWeather(for place: GeoPlace) async throws -> WeatherResult {
        guard var comps = URLComponents(string: forecastBase) else { throw WeatherError.badResponse }
        comps.queryItems = [
            URLQueryItem(name: "latitude", value: String(place.latitude)),
            URLQueryItem(name: "longitude", value: String(place.longitude)),
            URLQueryItem(name: "current",
                         value: "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m"),
            URLQueryItem(name: "timezone", value: "auto"),
        ] + keyItem()
        guard let url = comps.url else { throw WeatherError.badResponse }

        let (data, response) = try await session.data(from: url)
        try Self.validate(response)
        let decoded = try JSONDecoder().decode(ForecastResponse.self, from: data)
        return WeatherResult(place: place, current: decoded.current,
                             units: decoded.currentUnits, timezoneID: decoded.timezone)
    }

    /// One-shot: text query → resolved weather + location.
    func weather(for query: String) async throws -> WeatherResult {
        let place = try await geocode(query)
        return try await currentWeather(for: place)
    }

    private func keyItem() -> [URLQueryItem] {
        guard let key = apiKey else { return [] }
        return [URLQueryItem(name: "apikey", value: key)]
    }

    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw WeatherError.badResponse
        }
    }
}
