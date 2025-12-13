import Foundation
import Combine
import SwiftUI

class ChatDetailViewModel: BaseViewModel {
    @Published var messages: [Message] = []
    @Published var newMessageText = ""
    
    let chat: Chat
    private let myUserId: String
    
    private let messageService = ServiceFactory.makeMessageService()
    private let socketManager = SocketManagerWrapper.shared
    
    private var socketHandlerId: UUID?
    
    init(chat: Chat, myUserId: String) {
        self.chat = chat
        self.myUserId = myUserId
        super.init()
    }
    
    func onAppear() {
        print("ChatDetailViewModel onAppear for chat: \(chat.id)")
        
        cleanup()
        
        socketManager.joinRoom(chatId: chat.id)
        
        loadHistory()
        
        socketHandlerId = socketManager.onNewMessage { [weak self] data in
            guard let self = self else {
                print("ChatDetailViewModel: Self is nil in onNewMessage")
                return
            }
            
            print("ChatDetailViewModel: Received new message data in chat \(self.chat.id)")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let message = try JSONDecoder().decode(Message.self, from: jsonData)
                
                print("ChatDetailViewModel: Decoded message: \(message.id) for chat: \(message.chatId)")
                
                guard message.chatId == self.chat.id else {
                    print("ChatDetailViewModel: Message is for different chat (\(message.chatId)), current is \(self.chat.id), ignoring")
                    return
                }
                
                DispatchQueue.main.async {
                    if !self.messages.contains(where: { $0.id == message.id }) {
                        print("ChatDetailViewModel: Adding message \(message.id) to UI")
                        withAnimation {
                            self.messages.append(message)
                        }
                    } else {
                        print("ChatDetailViewModel: Message \(message.id) already exists, skipping")
                    }
                }
            } catch {
                print("[ERROR] ChatDetailViewModel: Failed to decode message: \(error)")
            }
        }
        
        print("ChatDetailViewModel: Created handler with ID: \(socketHandlerId?.uuidString ?? "nil")")
    }
    
    func onDisappear() {
        print("ChatDetailViewModel onDisappear for chat: \(chat.id)")
        cleanup()
    }
    
    private func cleanup() {
        if let handlerId = socketHandlerId {
            print("ChatDetailViewModel: Cleaning up handlers for chat: \(chat.id)")
            socketManager.leaveRoom(chatId: chat.id)
            socketManager.removeHandler(handlerId)
            socketHandlerId = nil
        }
    }
    
    func loadHistory() {
        self.performAsyncAction { [weak self] onComplete in
            guard let self = self else { return }
            self.messageService.getMessages(chatId: self.chat.id) { result in
                onComplete()
                switch result {
                case .success(let msgs):
                    DispatchQueue.main.async {
                        withAnimation {
                            self.messages = msgs
                        }
                        print("ChatDetailViewModel: Loaded \(msgs.count) messages for chat \(self.chat.id)")
                    }
                case .failure(let error):
                    print("ChatDetailViewModel: History load error: \(error)")
                    self.showError("Failed to load messages")
                }
            }
        }
    }
    
    func sendMessage() {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let textToSend = trimmed
        newMessageText = ""
        
        messageService.sendMessage(chatId: chat.id, text: textToSend) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("ChatDetailViewModel: Message sent successfully")
                
            case .failure(let error):
                print("ChatDetailViewModel: Failed to send: \(error)")
                DispatchQueue.main.async {
                    self.newMessageText = textToSend
                    self.showError("Failed to send message")
                }
            }
        }
    }
    
    func isMyMessage(_ message: Message) -> Bool {
        return message.user.id == myUserId
    }
}
