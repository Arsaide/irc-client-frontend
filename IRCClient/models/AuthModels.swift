import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let name: String
    let role: String
    let isVerified: Bool
    let isTwoFactorEnabled: Bool
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let passwordRepeat: String
    let name: String
}

struct RegisterResponse: Decodable {
    let message: String
}
