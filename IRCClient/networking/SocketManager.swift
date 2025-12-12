import Foundation
import Combine
import SocketIO

class SocketManagerWrapper: ObservableObject {
    static let shared = SocketManagerWrapper()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    @Published var isConnected = false
    
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
    
    func onNewMessage(completion: @escaping ([String: Any]) -> Void) {
        socket?.on("newMessage") { data, ack in
            if let messageData = data.first as? [String: Any] {
                completion(messageData)
            }
        }
    }
    
    func off(_ event: String) {
        print("Removing listeners for event: \(event)")
        socket?.off(event)
    }
}
