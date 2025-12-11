import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func performRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            if let data = data {
                DispatchQueue.main.async { completion(.success(data)) }
            }
        }.resume()
    }
}
