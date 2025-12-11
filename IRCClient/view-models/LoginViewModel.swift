import Foundation
import Combine

class LoginViewModel: BaseViewModel {
    @Published var email = ""
    @Published var password = ""
    @Published var loggedInUser: User?
    
    private let authService = ServiceFactory.makeAuthService()
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            self.showError("Please enter email and password")
            return
        }
        
        let request = LoginRequest(email: email, password: password)
        
        self.performAsyncAction { [weak self] onComplete in
            guard let self = self else { return }

            self.authService.login(request: request) { result in
                onComplete()
                
                switch result {
                case .success(let user):
                    DispatchQueue.main.async {
                        self.loggedInUser = user
                    }
                case .failure(let error):
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
}
