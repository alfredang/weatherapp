import SwiftUI

/// About tab (house style): app card, developer card + link, data-source attribution, version.
struct AboutView: View {
    private let developerURL = URL(string: "https://www.tertiaryinfotech.com")!
    private let dataSourceURL = URL(string: "https://open-meteo.com")!

    private var versionString: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // App card
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Weather", systemImage: "cloud.sun.fill")
                            .font(.title3.bold())
                        Text("Search any city or place to see its current weather — temperature, "
                             + "conditions, humidity and wind — pulled live from the free Open-Meteo "
                             + "API, with the location pinned on an Apple map.")
                            .foregroundStyle(.secondary)
                    }
                    .cardSurface()

                    // Developer card
                    section("DEVELOPER") {
                        Label("Tertiary Infotech Academy Pte Ltd", systemImage: "building.2.fill")
                            .padding(.vertical, 14)
                        Divider()
                        Link(destination: developerURL) {
                            Label("tertiaryinfotech.com", systemImage: "globe")
                        }
                        .padding(.vertical, 14)
                    }

                    // Data-source card (attribution for the weather data)
                    section("DATA SOURCE") {
                        Label("Weather data by Open-Meteo.com", systemImage: "thermometer.sun.fill")
                            .padding(.vertical, 14)
                        Divider()
                        Link(destination: dataSourceURL) {
                            Label("open-meteo.com", systemImage: "globe")
                        }
                        .padding(.vertical, 14)
                    }

                    // Version row
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(versionString).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(20)
            }
            .background(Theme.bg)
            .navigationTitle("About")
        }
    }

    @ViewBuilder
    private func section(_ header: String, @ViewBuilder _ content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 0) { content() }
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.card, in: Theme.cardShape)
        }
    }
}

#Preview { AboutView() }
#Preview("Dark") { AboutView().preferredColorScheme(.dark) }
