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
    
    init(chat: Chat, myUserId: String) {
        self.chat = chat
        self.myUserId = myUserId
        super.init()
    }
    
    func onAppear() {
        socketManager.joinRoom(chatId: chat.id)
        
        // 1. ВАЖНО: Удаляем старый слушатель, чтобы сообщения не дублировались при переходе туда-сюда
        socketManager.off("newMessage")
        
        loadHistory()
        
        socketManager.onNewMessage { [weak self] data in
            guard let self = self else { return }
            
            print("📩 RAW SOCKET DATA: \(data)")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let message = try JSONDecoder().decode(Message.self, from: jsonData)
                
                DispatchQueue.main.async {
                    let isAlreadyShown = self.messages.contains {
                        $0.id == message.id ||
                        ($0.text == message.text && $0.user.id == message.user.id)
                    }
                    
                    if !isAlreadyShown {
                        print("Message added to UI: \(message.text)")
                        withAnimation {
                            self.messages.append(message)
                        }
                    } else {
                        print("Message duplicate skipped")
                    }
                }
            } catch let DecodingError.dataCorrupted(context) {
                print("[DECODE ERROR] (Data): \(context)")
            } catch let DecodingError.keyNotFound(key, context) {
                print("[DECODE ERROR] (Key not found): '\(key.stringValue)' не найдено. Context: \(context.debugDescription)")
            } catch let DecodingError.valueNotFound(value, context) {
                print("[DECODE ERROR] (Value not found): '\(value)' не найдено. Context: \(context.debugDescription)")
            } catch let DecodingError.typeMismatch(type, context) {
                print("[DECODE ERROR] (Type mismatch): Ожидался '\(type)', а пришло другое. Field: \(context.codingPath.last?.stringValue ?? "unknown"). Context: \(context.debugDescription)")
            } catch {
                print("[UNKNOWN ERROR]: \(error)")
            }
        }
    }
    
    func onDisappear() {
        socketManager.leaveRoom(chatId: chat.id)
        socketManager.off("newMessage")
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
                    }
                case .failure(let error):
                    print("History load error: \(error)")
                }
            }
        }
    }
    
    func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        
        let target = chat.ircChannelName ?? ("#" + (chat.title ?? "unknown"))
        let textToSend = newMessageText
        
        newMessageText = ""
        
        let tempMessage = Message(
            id: UUID().uuidString,
            text: textToSend,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            user: MessageUser(id: myUserId, name: "Me", ircNickname: nil)
        )
        
        withAnimation {
            self.messages.append(tempMessage)
        }
        
        messageService.sendMessage(target: target, text: textToSend) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("Message sent successfully")
                
            case .failure(let error):
                print("Failed to send: \(error)")
                DispatchQueue.main.async {
                    withAnimation {
                        self.messages.removeAll(where: { $0.id == tempMessage.id })
                    }
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
