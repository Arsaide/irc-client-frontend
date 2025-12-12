import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    private var storedCookies: [HTTPCookie] = []
    
    private init() {}
    
    func getCookies() -> [HTTPCookie] {
        return storedCookies
    }
    
    func performRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        var mutableRequest = request
        
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: storedCookies)
        for (key, value) in cookieHeaders {
            mutableRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        print("[REQUEST] \(mutableRequest.httpMethod ?? "GET") \(mutableRequest.url?.absoluteString ?? "")")
        if let cookieString = mutableRequest.value(forHTTPHeaderField: "Cookie") {
            print("[SENDING COOKIES]: \(cookieString)")
        }
        
        if let body = mutableRequest.httpBody, let json = String(data: body, encoding: .utf8) {
            print("[BODY]: \(json)")
        }
        
        let task = URLSession.shared.dataTask(with: mutableRequest) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("[CODE]: \(httpResponse.statusCode)")
                
                if let url = httpResponse.url, let allHeaderFields = httpResponse.allHeaderFields as? [String: String] {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
                    
                    if !cookies.isEmpty {
                        self.storedCookies = cookies
                        print("[NEW COOKIES SAVED]: \(cookies.count)")
                        for cookie in cookies {
                            print("   - \(cookie.name): \(cookie.value)")
                        }
                    }
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    var finalMessage = "Server Error \(httpResponse.statusCode)"
                    
                    if let data = data,
                       let backendError = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                        finalMessage = backendError.message
                        print("[API ERROR]: \(finalMessage)")
                    } else if let data = data, let rawString = String(data: data, encoding: .utf8) {
                        print("[RAW ERROR]: \(rawString)")
                    }
                    
                    let customError = NSError(
                        domain: "BackendError",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: finalMessage]
                    )
                    
                    DispatchQueue.main.async { completion(.failure(customError)) }
                    return
                }
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    let logString = responseString.count > 500 ? String(responseString.prefix(500)) + "..." : responseString
                    print("[RESPONSE]: \(logString)")
                }
                DispatchQueue.main.async { completion(.success(data)) }
            }
        }
        task.resume()
    }
}
