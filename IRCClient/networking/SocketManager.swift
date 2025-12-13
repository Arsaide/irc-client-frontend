import Foundation
import Combine
import SocketIO

class SocketManagerWrapper: ObservableObject {
    static let shared = SocketManagerWrapper()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    @Published var isConnected = false
    
    private var messageHandlers: [UUID: ([String: Any]) -> Void] = [:]
    private var hasSocketListener = false
    
    private init() {}
    
    func connect() {
        let cookies = NetworkManager.shared.getCookies()
        let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)["Cookie"] ?? ""
        
        print("Connecting to Socket.IO with cookie: \(cookieHeader)")
        
        manager = SocketManager(
            socketURL: URL(string: "http://127.0.0.1:5050")!,
            config: [
                .log(true),
                .compress,
                .extraHeaders(["Cookie": cookieHeader])
            ]
        )
        
        socket = manager?.defaultSocket
        
        setupBaseHandlers()
        
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
    }
    
    private func setupBaseHandlers() {
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket Connected!")
            DispatchQueue.main.async { self?.isConnected = true }
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("Socket Disconnected")
            DispatchQueue.main.async { self?.isConnected = false }
        }
        
        socket?.on(clientEvent: .error) { data, ack in
            print("Socket Error: \(data)")
        }
    }
    
    func joinRoom(chatId: String) {
        socket?.emit("joinRoom", ["chatId": chatId])
    }
    
    func leaveRoom(chatId: String) {
        socket?.emit("leaveRoom", ["chatId": chatId])
    }
    
    func onNewMessage(completion: @escaping ([String: Any]) -> Void) -> UUID {
        let handlerId = UUID()
        
        print("SocketManager: Adding handler with ID: \(handlerId)")
        
        messageHandlers[handlerId] = completion
        
        if !hasSocketListener {
            print("SocketManager: Setting up socket listener for newMessage")
            socket?.on("newMessage") { [weak self] data, ack in
                guard let self = self else { return }
                
                if let messageData = data.first as? [String: Any] {
                    for (id, handler) in self.messageHandlers {
                        print("SocketManager: Processing message with handler: \(id)")
                        handler(messageData)
                    }
                }
            }
            hasSocketListener = true
        }
        
        return handlerId
    }
    
    func removeHandler(_ handlerId: UUID) {
        print("SocketManager: Removing handler: \(handlerId)")
        messageHandlers.removeValue(forKey: handlerId)
        
        if messageHandlers.isEmpty && hasSocketListener {
            print("SocketManager: No more handlers, removing socket listener")
            socket?.off("newMessage")
            hasSocketListener = false
        }
    }
    
    func off(_ event: String) {
        print("SocketManager: Removing all listeners for event: \(event)")
        if event == "newMessage" {
            messageHandlers.removeAll()
            socket?.off(event)
            hasSocketListener = false
        } else {
            socket?.off(event)
        }
    }
}
