import Foundation
import Observation

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
}
