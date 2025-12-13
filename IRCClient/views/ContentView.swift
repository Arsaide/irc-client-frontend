import SwiftUI

struct ContentView: View {
    @State private var serverMessage: String = "Ready to connect..."
    @State private var statusColor: Color = .gray
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "desktopcomputer")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(statusColor)
            
            Text("IRC Client (macOS)")
                .font(.title)
                .bold()
            
            Text(serverMessage)
                .multilineTextAlignment(.center)
                .padding()
                .textSelection(.enabled)
            
            Button("Ping API") {
                pingServer()
            }
            .controlSize(.large)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
    
    func pingServer() {
        self.serverMessage = "Pinging..."
        self.statusColor = .yellow
        
        guard let request = RequestBuilder()
            .setPath("/")
            .setMethod("GET")
            .build()
        else { return }
        
        NetworkManager.shared.performRequest(request) { result in
            switch result {
            case .success(_):
                self.serverMessage = "Server is Online!"
                self.statusColor = .green
            case .failure(let error):
                let nsError = error as NSError
                
                if nsError.domain == "ServerError" {
                     self.serverMessage = "Server replied with error \(nsError.code) (It's alive!)"
                     self.statusColor = .orange
                } else {
                    self.serverMessage = "Failed: \(error.localizedDescription)"
                    self.statusColor = .red
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
