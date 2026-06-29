import SwiftUI

/// Central color tokens — each backed by an Asset Catalog color set with Light + Dark
/// variants so dark mode is automatic. Never use raw `Color(red:…)` literals in views.
enum Theme {
    static let accent = Color("Accent")      // brand / selected-tab color
    static let card   = Color("Card")        // grouped-card surface
    static let bg     = Color("Background")  // screen background

    /// Standard rounded surface used for the grouped-card look across the app.
    static let cardShape = RoundedRectangle(cornerRadius: 18, style: .continuous)
}

extension View {
    /// Wrap a view group in the house-style rounded card surface.
    func cardSurface() -> some View {
        self
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: Theme.cardShape)
    }
}
