import SwiftUI

/// Root bottom-tab navigation (house style): Weather + Feedback + About.
struct MainTabView: View {
    var body: some View {
        TabView {
            WeatherView()
                .tabItem { Label("Weather", systemImage: "cloud.sun.fill") }
            FeedbackView()
                .tabItem { Label("Feedback", systemImage: "bubble.left.and.bubble.right.fill") }
            AboutView()
                .tabItem { Label("About", systemImage: "info.circle.fill") }
        }
        .tint(Theme.accent)
    }
}

#Preview { MainTabView() }
#Preview("Dark") { MainTabView().preferredColorScheme(.dark) }
