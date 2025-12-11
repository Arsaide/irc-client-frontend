    import Foundation

    final class NetworkManager {
        static let shared = NetworkManager()
        private init() {}
        
        func performRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
            print("[REQUEST] \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
                
            if let body = request.httpBody, let jsonString = String(data: body, encoding: .utf8) {
                print("[BODY SEND]: \(jsonString)")
            }
                
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("[NETWORK ERROR]: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                    return
                }
                    
                if let httpResponse = response as? HTTPURLResponse {
                    print("[RESPONSE CODE]: \(httpResponse.statusCode)")
                        
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("[RESPONSE BODY]: \(responseString)")
                    }
                        
                    guard (200...299).contains(httpResponse.statusCode) else {
                        var errorMessage = "Server Error \(httpResponse.statusCode)"
                            
                        if let data = data, let backendError = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                            errorMessage = backendError.message
                        }
                            
                        let customError = NSError(
                            domain: "BackendError",
                            code: httpResponse.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: errorMessage]
                        )
                            
                        DispatchQueue.main.async { completion(.failure(customError)) }
                        return
                    }
                }
                    
                if let data = data {
                    DispatchQueue.main.async { completion(.success(data)) }
                }
            }
            task.resume()
        }
    }
