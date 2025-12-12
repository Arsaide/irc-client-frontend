import Foundation

protocol ChatServiceProtocol {
    func getMyChats(completion: @escaping (Result<[Chat], Error>) -> Void)
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
}
