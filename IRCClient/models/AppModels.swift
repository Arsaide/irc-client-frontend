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

struct Message: Codable, Identifiable, Sendable {
    let id: String
    let text: String
    let createdAt: String
    let user: MessageUser
}

struct SendMessageDto: Encodable {
    let target: String
    let message: String
}
