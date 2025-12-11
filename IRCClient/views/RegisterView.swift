import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
            
            TextField("Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            SecureField("Repeat password", text: $viewModel.passwordRepeat)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            Button(action: { viewModel.register() }) {
                HStack {
                    if viewModel.isLoading { ProgressView().controlSize(.small) }
                    Text("Sign Up")
                }
                .frame(width: 120)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            Button("Already have an account? Login") {
                dismiss()
            }
            .buttonStyle(.link)
        }
        .padding()
        .frame(width: 450, height: 400)
        .alert("Success", isPresented: Binding<Bool>(
            get: { viewModel.successMessage != nil },
            set: { _ in viewModel.successMessage = nil }
        )) {
            Button("OK") { dismiss() }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .alert("Error", isPresented: $viewModel.hasError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    RegisterView()
}
