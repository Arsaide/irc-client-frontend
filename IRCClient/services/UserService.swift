import Foundation

struct UserListItem: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let ircNickname: String?
}

protocol UserServiceProtocol {
    func getProfile(completion: @escaping (Result<User, Error>) -> Void)
    func getAllUsers(completion: @escaping (Result<[UserListItem], Error>) -> Void)
}

class RealUserService: UserServiceProtocol {
    func getProfile(completion: @escaping (Result<User, Error>) -> Void) {
        guard let request = RequestBuilder()
            .setPath("/users/profile")
            .setMethod("GET")
            .build()
        else { return }
        
        NetworkManager.shared.performRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[UserListItem], Error>) -> Void) {
        guard let request = RequestBuilder()
            .setPath("/users")
            .setMethod("GET")
            .build()
        else { return }
        
        NetworkManager.shared.performRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let users = try JSONDecoder().decode([UserListItem].self, from: data)
                    completion(.success(users))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
