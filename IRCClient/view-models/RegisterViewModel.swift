import Foundation
import Combine

class RegisterViewModel: BaseViewModel {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordRepeat = ""
    @Published var name = ""
    @Published var successMessage: String?
    
    private let authService = ServiceFactory.makeAuthService()
    
    func register() {
        guard !email.isEmpty, !password.isEmpty, !passwordRepeat.isEmpty, !name.isEmpty else {
            self.showError("Please fill in all fields")
            return
        }
        
        let request = RegisterRequest(
            email: email,
            password: password,
            passwordRepeat: passwordRepeat,
            name: name
        )
        
        self.performAsyncAction { [weak self] onComplete in
            guard let self = self else { return }
            
            self.authService.register(request: request) { result in
                onComplete()
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        self.successMessage = response.message
                        self.password = ""
                    }
                case .failure(let error):
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
}
