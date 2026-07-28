//
//  APIClient.swift
//  tenisdemo Watch App
//
//  Created by Antigravity on 19.07.2026.
//

import Foundation

struct APIErrorResponse: Decodable {
    let message: String
}

protocol APIClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        // Snake_case JSON verilerini CamelCase model değişkenlerine otomatik eşlemek için:
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let request = endpoint.asURLRequest() else {
            throw APIError.invalidURL
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw APIError.custom(message: errorResponse.message)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
