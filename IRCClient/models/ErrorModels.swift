import Foundation

struct BackendErrorResponse: Sendable {
    let statusCode: Int?
    let error: String?
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case error
        case message
    }
}

nonisolated extension BackendErrorResponse: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        statusCode = try? container.decode(Int.self, forKey: .statusCode)
        error = try? container.decodeIfPresent(String.self, forKey: .error)
        
        // Универсальное чтение сообщения (и как строки, и как массива)
        if let stringMessage = try? container.decode(String.self, forKey: .message) {
            message = stringMessage
        } else if let arrayMessage = try? container.decode([String].self, forKey: .message) {
            message = arrayMessage.joined(separator: "\n")
        } else {
            message = "Server error (unknown format)"
        }
    }
}
