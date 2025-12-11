import Foundation

protocol AuthServiceProtocol {
    func login(request: LoginRequest, completion: @escaping (Result<User, Error>) -> Void)
    func register(request: RegisterRequest, completion: @escaping (Result<RegisterResponse, Error>) -> Void)
}

class AuthService: AuthServiceProtocol {
    func login(request: LoginRequest, completion: @escaping (Result<User, Error>) -> Void) {
        guard let urlRequest = RequestBuilder()
            .setPath("/auth/login")
            .setMethod("POST")
            .setBody(request)
            .build()
        else {
            completion(.failure(NSError(domain: "BuilderError", code: -1)))
            return
        }
        
        NetworkManager.shared.performRequest(urlRequest) {
            result in
            
            switch result {
            case .success(let data):
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func register(request: RegisterRequest, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        guard let urlRequest = RequestBuilder()
            .setPath("/auth/register")
            .setMethod("POST")
            .setBody(request)
            .build()
        else {
            completion(.failure(NSError(domain: "BuilderError", code: -1)))
            return
        }

        NetworkManager.shared.performRequest(urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class ServiceFactory {
    static func makeAuthService() -> AuthServiceProtocol {
        return AuthService()
    }
}
