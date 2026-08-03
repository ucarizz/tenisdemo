//
//  APIEndpoint.swift
//  tenisdemo Watch App
//
//  Created by Antigravity on 19.07.2026.
//

import Foundation

protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}

enum AppEnvironment {
    case development
    case testServer
    
    static var current: AppEnvironment = .testServer
    
    var apiBaseURL: URL {
        switch self {
        case .development:
            return URL(string: "http://192.168.1.4:5200/v1")!
        case .testServer:
            return URL(string: "http://207.154.234.58:5200/v1")!
        }
    }
    
    var signalRBaseURL: String {
        switch self {
        case .development:
            return "http://192.168.1.4:5200/hubs/tennis"
        case .testServer:
            return "http://207.154.234.58:5200/hubs/tennis"
        }
    }
    
    var loggingBaseURL: URL {
        switch self {
        case .development:
            return URL(string: "http://192.168.1.4:5200/v1/logs/client-diagnostics")!
        case .testServer:
            return URL(string: "http://207.154.234.58:5200/v1/logs/client-diagnostics")!
        }
    }
}

extension APIEndpoint {
    var baseURL: URL {
        return AppEnvironment.current.apiBaseURL
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    func asURLRequest() -> URLRequest? {
        let url = baseURL.appendingPathComponent(path)
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        guard let finalURL = components.url else {
            return nil
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
}
