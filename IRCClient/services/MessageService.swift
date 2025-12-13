import Foundation


protocol MessageServiceProtocol {
    func getMessages(chatId: String, completion: @escaping (Result<[Message], Error>) -> Void)
    func sendMessage(chatId: String, text: String, completion: @escaping (Result<Message, Error>) -> Void)
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
        
    func sendMessage(chatId: String, text: String, completion: @escaping (Result<Message, Error>) -> Void) {
        let body = SendChatMessageDto(text: text)
            
        guard let request = RequestBuilder()
            .setPath("/chats/\(chatId)/messages")
            .setMethod("POST")
            .setBody(body)
            .build()
        else { return }
            
        NetworkManager.shared.performRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let message = try JSONDecoder().decode(Message.self, from: data)
                    completion(.success(message))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
