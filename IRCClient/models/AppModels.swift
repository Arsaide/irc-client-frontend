import Foundation

struct Chat: Codable, Identifiable, Sendable {
    let id: String
    let title: String?
    let ircChannelName: String?
    let ownerId: String
}

struct MessageUser: Codable, Sendable {
    let id: String
    let name: String
    let ircNickname: String?
}

struct Message: Codable, Identifiable {
    let id: String
    let text: String
    let chatId: String
    let user: MessageUser
    let createdAt: String
}

struct SendMessageDto: Encodable {
    let target: String
    let message: String
}

struct SendChatMessageDto: Encodable {
    let text: String
}
