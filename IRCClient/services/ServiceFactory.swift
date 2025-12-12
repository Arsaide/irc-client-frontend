class ServiceFactory {
    static func makeAuthService() -> AuthServiceProtocol {
        return AuthService()
    }
    
    static func makeUserService() -> UserServiceProtocol {
        return RealUserService()
    }
    
    static func makeChatService() -> ChatServiceProtocol {
        return RealChatService()
    }
    
    static func makeMessageService() -> MessageServiceProtocol {
        return RealMessageService()
    }
}
