# Tertiary Weather

A native **iOS** weather app built with **SwiftUI**. Search for any city or place, pull live
current conditions from the free **[Open-Meteo](https://open-meteo.com)** API, and see the
location pinned on an **Apple Map** — all behind a clean bottom-tab navigation. Universal
(iPhone + iPad), available on the **App Store** as *Tertiary Weather*.

<a href="https://apps.apple.com/us/app/tertiary-weather/id6785375222">
  <img src="https://toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-app-store/black/en-us" alt="Download on the App Store" height="54">
</a>

![Tertiary Weather — search screen](screenshot.png)

## Features

- 📍 **Auto-detect current location** — on launch the app finds where you are (CoreLocation +
  reverse geocoding) and shows the local weather and time; a `location` button re-detects on demand.
- 🔎 **Search any city or place** — free-text geocoding via Open-Meteo.
- 🌡️ **Live current weather** — temperature, feels-like, humidity, wind, and a WMO
  condition label with a matching SF Symbol (day/night aware).
- 🕐 **Live local time** — a running clock for the loaded place, in its own time zone.
- 🌍 **World Time** — a world-clock tab with live times for your chosen cities
  (add/remove/reorder, day/night icons, UTC-offset vs your device).
- 🗺️ **Location on Apple Maps** — the resolved place is dropped as a `Marker` on a MapKit map.
- 🧭 **Bottom-tab navigation** — Weather, World Time, Feedback (→ WhatsApp), and About.
- 🌦️ **Weather-concept theme** — the sky *is* the theme: a dynamic gradient background that
  matches the current condition (clear/cloudy/rain/snow/storm, day and night variants),
  with frosted-material cards on top.
- ♿ **HIG-friendly** — Dynamic Type, SF Symbols, 44pt hit targets, VoiceOver labels.

## Tech Stack

| Layer | Choice |
|-------|--------|
| UI | SwiftUI (iOS 17+), `@Observable` state |
| Maps | MapKit (`Map` + `Marker`) |
| Networking | `URLSession` async/await |
| Data source | [Open-Meteo](https://open-meteo.com) geocoding + forecast APIs (no key required) |
| Project gen | [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml`) |

## Architecture

```
Sources/
├── WeatherApp.swift        # @main App entry
├── MainTabView.swift       # Root TabView: Weather / World Time / Feedback / About
├── WeatherView.swift       # Search field, weather card + live clock, MapKit map
├── WeatherViewModel.swift  # @Observable: idle / loading / loaded / failed + locate-me
├── WeatherService.swift    # Open-Meteo geocoding + forecast (async/await)
├── WeatherModels.swift     # Codable models + WMO code → label/symbol
├── LocationProvider.swift  # One-shot async CoreLocation wrapper
├── WorldClockView.swift    # World Time tab: live city clocks + picker
├── FeedbackView.swift      # Title + Message → WhatsApp (wa.me)
├── AboutView.swift         # App / developer / data-source / version cards
└── Theme.swift             # Color tokens, card surfaces + weather sky gradients
Resources/
├── Info.plist              # Endpoints + optional OpenMeteoAPIKey
└── Assets.xcassets         # Accent / Card / Background color sets, AppIcon
```

## Getting Started

**Requirements:** macOS with Xcode 17+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`).

```bash
# 1. Generate the Xcode project from project.yml
xcodegen generate

# 2. Open and run
open WeatherApp.xcodeproj
#    ⌘R on an iPhone simulator or a signed physical device

# …or build from the CLI for the simulator
xcodebuild -project WeatherApp.xcodeproj -scheme WeatherApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

> `WeatherApp.xcodeproj` is generated from `project.yml` and is git-ignored — run
> `xcodegen generate` after cloning.

## Configuration

Open-Meteo's free tier needs **no API key**. The forecast/geocoding endpoints (and an optional
`OpenMeteoAPIKey` for the commercial tier) live in `Resources/Info.plist` and are read at
runtime by `WeatherService` — set the key there and it's appended automatically.

## Data Source

Weather and geocoding data © [Open-Meteo.com](https://open-meteo.com), licensed under
CC BY 4.0.

## Acknowledgements

Developed by [Tertiary Infotech Academy Pte Ltd](https://www.tertiaryinfotech.com).
