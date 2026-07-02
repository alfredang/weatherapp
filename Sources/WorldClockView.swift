import SwiftUI

// MARK: - Model

struct WorldCity: Identifiable, Codable, Hashable {
    let name: String
    let country: String
    let timeZoneID: String

    var id: String { timeZoneID }
    var timeZone: TimeZone? { TimeZone(identifier: timeZoneID) }
}

enum WorldCityCatalog {
    static let all: [WorldCity] = [
        .init(name: "Singapore",     country: "Singapore",            timeZoneID: "Asia/Singapore"),
        .init(name: "Kuala Lumpur",  country: "Malaysia",             timeZoneID: "Asia/Kuala_Lumpur"),
        .init(name: "Jakarta",       country: "Indonesia",            timeZoneID: "Asia/Jakarta"),
        .init(name: "Bangkok",       country: "Thailand",             timeZoneID: "Asia/Bangkok"),
        .init(name: "Hong Kong",     country: "China",                timeZoneID: "Asia/Hong_Kong"),
        .init(name: "Shanghai",      country: "China",                timeZoneID: "Asia/Shanghai"),
        .init(name: "Tokyo",         country: "Japan",                timeZoneID: "Asia/Tokyo"),
        .init(name: "Seoul",         country: "South Korea",          timeZoneID: "Asia/Seoul"),
        .init(name: "Taipei",        country: "Taiwan",               timeZoneID: "Asia/Taipei"),
        .init(name: "Manila",        country: "Philippines",          timeZoneID: "Asia/Manila"),
        .init(name: "Mumbai",        country: "India",                timeZoneID: "Asia/Kolkata"),
        .init(name: "Dubai",         country: "United Arab Emirates", timeZoneID: "Asia/Dubai"),
        .init(name: "Istanbul",      country: "Türkiye",              timeZoneID: "Europe/Istanbul"),
        .init(name: "Moscow",        country: "Russia",               timeZoneID: "Europe/Moscow"),
        .init(name: "Berlin",        country: "Germany",              timeZoneID: "Europe/Berlin"),
        .init(name: "Paris",         country: "France",               timeZoneID: "Europe/Paris"),
        .init(name: "London",        country: "United Kingdom",       timeZoneID: "Europe/London"),
        .init(name: "New York",      country: "United States",        timeZoneID: "America/New_York"),
        .init(name: "Toronto",       country: "Canada",               timeZoneID: "America/Toronto"),
        .init(name: "Chicago",       country: "United States",        timeZoneID: "America/Chicago"),
        .init(name: "Denver",        country: "United States",        timeZoneID: "America/Denver"),
        .init(name: "Los Angeles",   country: "United States",        timeZoneID: "America/Los_Angeles"),
        .init(name: "Vancouver",     country: "Canada",               timeZoneID: "America/Vancouver"),
        .init(name: "Mexico City",   country: "Mexico",               timeZoneID: "America/Mexico_City"),
        .init(name: "São Paulo",     country: "Brazil",               timeZoneID: "America/Sao_Paulo"),
        .init(name: "Cairo",         country: "Egypt",                timeZoneID: "Africa/Cairo"),
        .init(name: "Nairobi",       country: "Kenya",                timeZoneID: "Africa/Nairobi"),
        .init(name: "Johannesburg",  country: "South Africa",         timeZoneID: "Africa/Johannesburg"),
        .init(name: "Sydney",        country: "Australia",            timeZoneID: "Australia/Sydney"),
        .init(name: "Melbourne",     country: "Australia",            timeZoneID: "Australia/Melbourne"),
        .init(name: "Auckland",      country: "New Zealand",          timeZoneID: "Pacific/Auckland"),
        .init(name: "Honolulu",      country: "United States",        timeZoneID: "Pacific/Honolulu"),
    ]

    static let defaultIDs = [
        "Asia/Singapore", "Europe/London", "America/New_York", "Asia/Tokyo", "Australia/Sydney",
    ]
}

/// Persists the user's world-clock city list in UserDefaults.
@MainActor
@Observable
final class WorldClockStore {
    private static let storageKey = "worldClockCityIDs"

    var cities: [WorldCity] {
        didSet { save() }
    }

    init() {
        let ids = UserDefaults.standard.stringArray(forKey: Self.storageKey)
            ?? WorldCityCatalog.defaultIDs
        cities = ids.compactMap { id in WorldCityCatalog.all.first { $0.timeZoneID == id } }
    }

    func add(_ city: WorldCity) {
        guard !cities.contains(city) else { return }
        cities.append(city)
    }

    func remove(atOffsets offsets: IndexSet) { cities.remove(atOffsets: offsets) }
    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        cities.move(fromOffsets: source, toOffset: destination)
    }

    private func save() {
        UserDefaults.standard.set(cities.map(\.timeZoneID), forKey: Self.storageKey)
    }
}

// MARK: - View

/// World Time tab: live clocks for the user's chosen cities.
struct WorldClockView: View {
    @State private var store = WorldClockStore()
    @State private var showingPicker = false

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                List {
                    ForEach(store.cities) { city in
                        WorldClockRow(city: city, now: context.date)
                            .listRowBackground(Theme.card)
                    }
                    .onDelete { store.remove(atOffsets: $0) }
                    .onMove { store.move(fromOffsets: $0, toOffset: $1) }
                }
                .scrollContentBackground(.hidden)
            }
            .background(Theme.bg)
            .navigationTitle("World Time")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingPicker = true } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add a city")
                }
            }
            .sheet(isPresented: $showingPicker) {
                CityPicker(store: store)
            }
            .overlay {
                if store.cities.isEmpty {
                    ContentUnavailableView("No cities yet",
                                           systemImage: "globe",
                                           description: Text("Tap + to add a city and see its local time."))
                }
            }
        }
    }
}

private struct WorldClockRow: View {
    let city: WorldCity
    let now: Date

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isDaytime ? "sun.max.fill" : "moon.stars.fill")
                .font(.title3)
                .foregroundStyle(isDaytime ? .yellow : .indigo)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(city.name).font(.headline)
                Text("\(city.country) · \(offsetText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(timeText)
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                Text(dayText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private var tz: TimeZone { city.timeZone ?? .current }

    private var localHour: Int {
        var calendar = Calendar.current
        calendar.timeZone = tz
        return calendar.component(.hour, from: now)
    }
    private var isDaytime: Bool { (6..<18).contains(localHour) }

    private var timeText: String {
        var style = Date.FormatStyle.dateTime.hour().minute().second()
        style.timeZone = tz
        return now.formatted(style)
    }

    private var dayText: String {
        var style = Date.FormatStyle.dateTime.weekday(.abbreviated).month(.abbreviated).day()
        style.timeZone = tz
        return now.formatted(style)
    }

    /// Difference vs the device's zone, e.g. "+8h", "−4.5h", "Same time".
    private var offsetText: String {
        let seconds = tz.secondsFromGMT(for: now) - TimeZone.current.secondsFromGMT(for: now)
        if seconds == 0 { return "Same time" }
        let hours = Double(seconds) / 3600
        let value = hours == hours.rounded() ? String(Int(hours)) : String(format: "%.1f", hours)
        return (seconds > 0 ? "+" : "") + value + "h"
    }
}

// MARK: - Add-city sheet

private struct CityPicker: View {
    let store: WorldClockStore
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    private var available: [WorldCity] {
        let remaining = WorldCityCatalog.all.filter { !store.cities.contains($0) }
        guard !search.isEmpty else { return remaining }
        return remaining.filter {
            $0.name.localizedCaseInsensitiveContains(search)
                || $0.country.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            List(available) { city in
                Button {
                    store.add(city)
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(city.name).font(.body).foregroundStyle(.primary)
                        Text(city.country).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $search, prompt: "Search cities")
            .navigationTitle("Add City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview { WorldClockView() }
#Preview("Dark") { WorldClockView().preferredColorScheme(.dark) }
