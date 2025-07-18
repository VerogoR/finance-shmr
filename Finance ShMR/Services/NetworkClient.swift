import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case encodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        case .httpError(let code):
            return "Ошибка HTTP: \(code)"
        case .decodingError(let error), .encodingError(let error), .unknown(let error):
            return error.localizedDescription
        }
    }
}

final class NetworkClient {
    private let baseURL: URL
    private let token: String
    private let session: URLSession
    
    init(
        baseURL: URL = URL(string: Secret.url)!,
        token: String,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }
    
    func request<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: RequestBody? = nil
    ) async throws -> ResponseBody {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if method != "GET", let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(ResponseBody.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    private struct Empty: Encodable {}
    func request<ResponseBody: Decodable>(
        path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil
    ) async throws -> ResponseBody {
        return try await request(
            path: path,
            method: method,
            queryItems: queryItems,
            body: Optional<Empty>.none
        )
    }
    
    func request(
        path: String,
        method: String = "DELETE",
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
