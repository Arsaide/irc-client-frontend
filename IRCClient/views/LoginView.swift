import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    @State private var openRegistration = false
    
    var onLoginSuccess: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "lock.shield")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(.blue)
            
            Text("Welcome Back")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 15) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
            }
            .padding(.vertical)
            
            Button(action: {
                viewModel.login()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.trailing, 5)
                    }
                    Text("Sign In")
                }
                .frame(width: 120)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.isLoading)
            
            Button("Don't have an account? Sign Up") {
                openRegistration = true
            }
            .buttonStyle(.link)
            .sheet(isPresented: $openRegistration) {
                RegisterView()
            }
            
            if let user = viewModel.loggedInUser {
                VStack {
                    Text("Success!")
                        .font(.headline)
                        .foregroundStyle(.green)
                    Text("Logged in as \(user.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)
                .transition(.opacity)
            }
        }
        .padding()
        .frame(minWidth: 450, minHeight: 400)
        .alert("Error", isPresented: $viewModel.hasError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .onChange(of: viewModel.loggedInUser) { oldValue, newValue in
            if newValue != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onLoginSuccess?()
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
