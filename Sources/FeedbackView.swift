import SwiftUI

/// Feedback tab (house style): Title + Message → opens WhatsApp with the composed text.
struct FeedbackView: View {
    private let whatsAppNumber = "6588666375"   // +65 8866 6375, country code, no "+"/spaces
    @State private var title = ""
    @State private var message = ""

    private var canSend: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("We'd love your feedback")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 16) {
                        TextField("Title", text: $title)
                            .textFieldStyle(.roundedBorder)

                        Text("Message").font(.subheadline).foregroundStyle(.secondary)
                        ZStack(alignment: .topLeading) {
                            if message.isEmpty {
                                Text("Your message…")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 8)
                            }
                            TextEditor(text: $message)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 160)
                        }
                        .padding(8)
                        .background(Theme.bg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .cardSurface()

                    Button(action: send) {
                        Label("Send via WhatsApp", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                    .disabled(!canSend)
                }
                .padding(20)
            }
            .background(Theme.bg)
            .navigationTitle("Feedback")
        }
    }

    private func send() {
        var text = ""
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let m = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.isEmpty { text += "*\(t)*\n" }
        text += m

        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = "wa.me"
        comps.path = "/\(whatsAppNumber)"
        comps.queryItems = [URLQueryItem(name: "text", value: text)]
        if let url = comps.url { UIApplication.shared.open(url) }
    }
}

#Preview { FeedbackView() }
