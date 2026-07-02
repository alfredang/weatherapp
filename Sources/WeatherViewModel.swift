import Foundation
import Observation
import CoreLocation

@MainActor
@Observable
final class WeatherViewModel {
    enum State {
        case idle
        case loading
        case loaded(WeatherResult)
        case failed(String)
    }

    var query: String = ""
    private(set) var state: State = .idle

    private let service: WeatherService
    private let locationProvider = LocationProvider()
    private var didAutoLocate = false

    init(service: WeatherService = WeatherService()) { self.service = service }

    var result: WeatherResult? {
        if case let .loaded(r) = state { return r }
        return nil
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        state = .loading
        do {
            let result = try await service.weather(for: trimmed)
            state = .loaded(result)
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            state = .failed(message)
        }
    }

    /// Detect the device's location and load its weather. When `quietly` is true
    /// (the launch-time auto attempt) a failure falls back to the idle hint
    /// instead of an error card.
    func locateMe(quietly: Bool = false) async {
        state = .loading
        do {
            let location = try await locationProvider.currentLocation()
            let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first
            let name = placemark?.locality ?? placemark?.subAdministrativeArea
                ?? placemark?.name ?? "My Location"
            // Drop 2–3 letter region codes ("SG", "TX") and admin areas that just
            // repeat the city — they read as noise in the subtitle.
            let admin = placemark?.administrativeArea.flatMap { $0.count > 3 && $0 != name ? $0 : nil }
            let place = GeoPlace(
                id: -1,
                name: name,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                country: placemark?.country,
                admin1: admin)
            let result = try await service.currentWeather(for: place)
            query = place.name
            state = .loaded(result)
        } catch {
            if quietly {
                state = .idle
            } else {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                state = .failed(message)
            }
        }
    }

    /// Launch-time behaviour: try the current location once, silently.
    func autoLocateIfNeeded() async {
        guard !didAutoLocate, case .idle = state else { return }
        didAutoLocate = true
        await locateMe(quietly: true)
    }
}
