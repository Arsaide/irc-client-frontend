import Foundation

struct CreateChatRequest: Encodable {
    let title: String
}

struct AddMembersRequest: Encodable {
    let userIds: [String]
}

protocol ChatServiceProtocol {
    func getMyChats(completion: @escaping (Result<[Chat], Error>) -> Void)
    func createChat(title: String, completion: @escaping (Result<Chat, Error>) -> Void)
    func addMembers(chatId: String, userIds: [String], completion: @escaping (Result<Void, Error>) -> Void)
}

class RealChatService: ChatServiceProtocol {
    func getMyChats(completion: @escaping (Result<[Chat], Error>) -> Void) {
        guard let request = RequestBuilder()
            .setPath("/chats")
            .setMethod("GET")
            .build()
        else { return }
        
        NetworkManager.shared.performRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let chats = try JSONDecoder().decode([Chat].self, from: data)
                    completion(.success(chats))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createChat(title: String, completion: @escaping (Result<Chat, Error>) -> Void) {
        let body = CreateChatRequest(title: title)
        
        guard let request = RequestBuilder()
            .setPath("/chats")
            .setMethod("POST")
            .setBody(body)
            .build()
        else { return }
        
        NetworkManager.shared.performRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let chat = try JSONDecoder().decode(Chat.self, from: data)
                    completion(.success(chat))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addMembers(chatId: String, userIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        let body = AddMembersRequest(userIds: userIds)
        
        guard let request = RequestBuilder()
            .setPath("/chats/\(chatId)/members")
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
