import Foundation
import Combine

class InviteUsersViewModel: ObservableObject {
    @Published var users: [UserListItem] = []
    @Published var selectedUserIds: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let chat: Chat
    
    private let userService = ServiceFactory.makeUserService()
    private let chatService = ServiceFactory.makeChatService()
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    func loadUsers() {
        isLoading = true
        print("Loading users...")
        
        userService.getAllUsers { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let users):
                    print("Loaded \(users.count) users")
                    for user in users {
                        print("  - \(user.name) (\(user.id))")
                    }
                    self.users = users
                    
                case .failure(let error):
                    print("Failed to load users: \(error)")
                    self.errorMessage = "Failed to load users"
                }
            }
        }
    }
    
    func toggleUser(_ userId: String) {
        if selectedUserIds.contains(userId) {
            selectedUserIds.remove(userId)
        } else {
            selectedUserIds.insert(userId)
        }
        print("Selected: \(selectedUserIds.count) users")
    }
    
    func inviteSelectedUsers(completion: @escaping (Bool) -> Void) {
        guard !selectedUserIds.isEmpty else {
            errorMessage = "Select at least one user"
            completion(false)
            return
        }
        
        isLoading = true
        let userIdsArray = Array(selectedUserIds)
        print("Inviting \(userIdsArray.count) users")
        
        chatService.addMembers(chatId: chat.id, userIds: userIdsArray) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success():
                    print("Users invited successfully")
                    completion(true)
                    
                case .failure(let error):
                    print("Failed to invite: \(error)")
                    self.errorMessage = "Failed to invite users"
                    completion(false)
                }
            }
        }
    }
}
