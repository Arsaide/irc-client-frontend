import SwiftUI

struct EmailConfirmationView: View {
    let token: String
    let onFinish: () -> Void
    
    @State private var message: String = "Verifying email..."
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView()
            } else {
                Image(systemName: message.contains("Success") ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(message.contains("Success") ? .green : .red)
            }
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Back to Login") {
                onFinish()
            }
            .disabled(isLoading)
        }
        .padding()
        .frame(width: 400, height: 300)
        .onAppear {
            verifyEmail()
        }
    }
    
    func verifyEmail() {
        struct ConfirmationDto: Encodable { let token: String }
        
        guard let request = RequestBuilder()
            .setPath("/auth/email-confirmation")
            .setMethod("POST")
            .setBody(ConfirmationDto(token: token))
            .build()
        else { return }
        
        NetworkManager.shared.performRequest(request) { result in
            isLoading = false
            switch result {
            case .success(_):
                message = "Success! Email verified."
            case .failure(let error):
                message = "Error: \(error.localizedDescription)"
            }
        }
    }
}
