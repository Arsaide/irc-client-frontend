import Foundation

protocol MessageServiceProtocol {
    func getMessages(chatId: String, completion: @escaping (Result<[Message], Error>) -> Void)
    func sendMessage(target: String, text: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class RealMessageService: MessageServiceProtocol {
    func getMessages(chatId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
            guard let request = RequestBuilder()
                .setPath("/chats/\(chatId)/messages")
                .setMethod("GET")
                .build()
            else { return }
            
            NetworkManager.shared.performRequest(request) { result in
                switch result {
                case .success(let data):
                    do {
                        let messages = try JSONDecoder().decode([Message].self, from: data)
                        completion(.success(messages))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        func sendMessage(target: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
            let body = SendMessageDto(target: target, message: text)
            
            guard let request = RequestBuilder()
                .setPath("/irc/send")
                .setMethod("POST")
                .setBody(body)
                .build()
            else { return }
            
            NetworkManager.shared.performRequest(request) { result in
                switch result {
                case .success(_):
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
}
