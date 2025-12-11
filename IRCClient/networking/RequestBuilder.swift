import Foundation

class RequestBuilder {
    private var urlString: String = ""
    private var method: String = "GET"
    private var headers: [String: String] = ["Content-Type": "application/json"]
    private var body: Data?

    func setPath(_ path: String) -> RequestBuilder {
        self.urlString = AppConfig.shared.apiBaseURL + path
        return self
    }

    func setMethod(_ method: String) -> RequestBuilder {
        self.method = method
        return self
    }

    func build() -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.timeoutInterval = 15
        return request
    }
}
