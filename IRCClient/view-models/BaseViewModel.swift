import Foundation
import Combine

class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    func performAsyncAction(_ action: @escaping (@escaping () -> Void) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
            self.hasError = false
        }
        
        action { [weak self] in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.hasError = true
        }
    }
}
