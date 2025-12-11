import SwiftUI

@main
struct IRCClientApp: App {
    @State private var confirmationToken: String?
    @State private var isShowingConfirmation = false

    var body: some Scene {
        WindowGroup {
            if let token = confirmationToken {
                EmailConfirmationView(token: token) {
                    self.confirmationToken = nil
                }
            } else {
                LoginView()
                    .onOpenURL { url in
                        handleDeepLink(url)
                    }
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        print("Deep Link received: \(url.absoluteString)")
        
        guard url.scheme == "ircclient" else { return }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        if components.path == "/auth/email-confirmation" {
            if let token = components.queryItems?.first(where: { $0.name == "token" })?.value {
                print("🔑 Token found: \(token)")
                self.confirmationToken = token
            }
        }
    }
}
