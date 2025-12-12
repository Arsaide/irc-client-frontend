import Foundation
import Combine

class HomeViewModel: BaseViewModel {
    @Published var currentUser: User?
    @Published var chats: [Chat] = []
    
    @Published var showCreateChatSheet = false
    @Published var showInviteSheet = false
    @Published var selectedChatForInvite: Chat?
    
    private let userService = ServiceFactory.makeUserService()
    private let chatService = ServiceFactory.makeChatService()
    
    func loadData() {
        self.performAsyncAction { [weak self] onComplete in
            guard let self = self else { return }
            
            let group = DispatchGroup()
            
            group.enter()
            self.userService.getProfile { result in
                switch result {
                case .success(let user):
                    DispatchQueue.main.async { self.currentUser = user }
                case .failure(let error):
                    print("Error loading profile: \(error)")
                }
                group.leave()
            }
            
            group.enter()
            self.chatService.getMyChats { result in
                switch result {
                case .success(let chats):
                    DispatchQueue.main.async { self.chats = chats }
                case .failure(let error):
                    print("Error loading chats: \(error)")
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                onComplete()
            }
        }
    }
    
    func openInviteSheet(for chat: Chat) {
        self.selectedChatForInvite = chat
        self.showInviteSheet = true
    }
}
