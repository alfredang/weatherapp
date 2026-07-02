import SwiftUI

/// Central color tokens — each backed by an Asset Catalog color set with Light + Dark
/// variants so dark mode is automatic. Never use raw `Color(red:…)` literals in views.
enum Theme {
    static let accent = Color("Accent")      // brand / selected-tab color
    static let card   = Color("Card")        // grouped-card surface
    static let bg     = Color("Background")  // screen background

    /// Standard rounded surface used for the grouped-card look across the app.
    static let cardShape = RoundedRectangle(cornerRadius: 18, style: .continuous)

    // MARK: Weather-concept sky gradients

    /// Sky gradient matched to the loaded weather (weather-concept theme).
    /// Falls back to a neutral day sky before anything has loaded.
    static func sky(for result: WeatherResult?) -> LinearGradient {
        let colors = result.map { skyColors(code: $0.current.weatherCode, isDay: $0.current.isDay == 1) }
            ?? [Color(red: 0.35, green: 0.62, blue: 0.95), Color(red: 0.62, green: 0.83, blue: 1.0)]
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    /// The only place raw color literals are allowed — sky tones are inherently
    /// literal and shared by light + dark mode (the sky *is* the theme).
    private static func skyColors(code: Int, isDay: Bool) -> [Color] {
        switch code {
        case 0, 1:                       // clear
            return isDay
                ? [Color(red: 0.18, green: 0.51, blue: 0.94), Color(red: 0.55, green: 0.81, blue: 1.0)]
                : [Color(red: 0.04, green: 0.06, blue: 0.22), Color(red: 0.16, green: 0.21, blue: 0.44)]
        case 2:                          // partly cloudy
            return isDay
                ? [Color(red: 0.33, green: 0.56, blue: 0.86), Color(red: 0.66, green: 0.78, blue: 0.92)]
                : [Color(red: 0.09, green: 0.12, blue: 0.28), Color(red: 0.24, green: 0.29, blue: 0.46)]
        case 3, 45, 48:                  // overcast / fog
            return isDay
                ? [Color(red: 0.47, green: 0.54, blue: 0.64), Color(red: 0.70, green: 0.75, blue: 0.82)]
                : [Color(red: 0.15, green: 0.17, blue: 0.23), Color(red: 0.28, green: 0.31, blue: 0.38)]
        case 51...67, 80...82:           // drizzle / rain / showers
            return isDay
                ? [Color(red: 0.29, green: 0.38, blue: 0.53), Color(red: 0.51, green: 0.60, blue: 0.72)]
                : [Color(red: 0.08, green: 0.11, blue: 0.20), Color(red: 0.20, green: 0.25, blue: 0.36)]
        case 71...77, 85, 86:            // snow
            return isDay
                ? [Color(red: 0.60, green: 0.70, blue: 0.82), Color(red: 0.85, green: 0.90, blue: 0.96)]
                : [Color(red: 0.18, green: 0.22, blue: 0.32), Color(red: 0.38, green: 0.44, blue: 0.55)]
        case 95...99:                    // thunderstorm
            return isDay
                ? [Color(red: 0.23, green: 0.24, blue: 0.38), Color(red: 0.43, green: 0.42, blue: 0.56)]
                : [Color(red: 0.07, green: 0.06, blue: 0.16), Color(red: 0.21, green: 0.18, blue: 0.34)]
        default:
            return isDay
                ? [Color(red: 0.35, green: 0.62, blue: 0.95), Color(red: 0.62, green: 0.83, blue: 1.0)]
                : [Color(red: 0.06, green: 0.08, blue: 0.24), Color(red: 0.18, green: 0.23, blue: 0.42)]
        }
    }
}

extension View {
    /// Wrap a view group in the house-style rounded card surface.
    func cardSurface() -> some View {
        self
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: Theme.cardShape)
    }

    /// Frosted card used on top of the weather sky gradient — the material keeps
    /// text legible over any sky color, day or night.
    func skyCardSurface() -> some View {
        self
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: Theme.cardShape)
    }
}
