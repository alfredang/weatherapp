import SwiftUI
import MapKit

/// Home tab: search a city/place, pull current weather from Open-Meteo, and show
/// the location on an Apple map.
struct WeatherView: View {
    @State private var model = WeatherViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    searchField

                    switch model.state {
                    case .idle:
                        hint
                    case .loading:
                        ProgressView("Fetching weather…")
                            .frame(maxWidth: .infinity, minHeight: 160)
                    case .failed(let message):
                        errorCard(message)
                    case .loaded(let result):
                        WeatherCard(result: result)
                        LocationMap(result: result)
                    }
                }
                .padding(20)
            }
            .background(Theme.bg)
            .navigationTitle("Weather")
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Enter a city or place", text: $model.query)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { Task { await model.search() } }
            if !model.query.isEmpty {
                Button { model.query = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(14)
        .background(Theme.card, in: Theme.cardShape)
    }

    private var hint: some View {
        VStack(spacing: 12) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.accent)
            Text("Search for a place to see its current weather and location on the map.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func errorCard(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
            Text(message).font(.callout)
        }
        .cardSurface()
    }
}

// MARK: - Weather card

private struct WeatherCard: View {
    let result: WeatherResult

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.place.name).font(.title2.bold())
                    if let sub = subtitle {
                        Text(sub).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: result.condition.symbol)
                    .font(.system(size: 44))
                    .symbolRenderingMode(.multicolor)
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(temperatureText).font(.system(size: 60, weight: .thin))
                Text(result.condition.label).font(.headline).foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                metric("thermometer.medium", "Feels like",
                       format(result.current.apparentTemperature, result.units.temperature))
                Spacer()
                metric("humidity.fill", "Humidity", "\(result.current.humidity)%")
                Spacer()
                metric("wind", "Wind",
                       "\(Int(result.current.windSpeed.rounded())) \(result.units.windSpeed)")
            }
        }
        .cardSurface()
    }

    private var subtitle: String? {
        [result.place.admin1, result.place.country].compactMap { $0 }.joined(separator: ", ").nonEmpty
    }
    private var temperatureText: String {
        format(result.current.temperature, result.units.temperature)
    }
    private func format(_ value: Double, _ unit: String) -> String {
        "\(Int(value.rounded()))\(unit)"
    }

    private func metric(_ symbol: String, _ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol).foregroundStyle(Theme.accent)
            Text(value).font(.subheadline.weight(.semibold))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Map

private struct LocationMap: View {
    let result: WeatherResult
    @State private var position: MapCameraPosition

    init(result: WeatherResult) {
        self.result = result
        _position = State(initialValue: .region(
            MKCoordinateRegion(center: result.place.coordinate,
                               span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))))
    }

    var body: some View {
        Map(position: $position) {
            Marker(result.place.name, systemImage: result.condition.symbol,
                   coordinate: result.place.coordinate)
                .tint(Theme.accent)
        }
        .mapStyle(.standard(elevation: .realistic))
        .frame(height: 280)
        .clipShape(Theme.cardShape)
        .id(result.place.id)   // recenter when a new place loads
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}

#Preview { WeatherView() }
