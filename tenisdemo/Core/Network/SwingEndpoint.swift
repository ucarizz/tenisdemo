//
//  SwingEndpoint.swift
//  tenisdemo
//
//  Created by Antigravity on 07.08.2026.
//

import Foundation

enum SwingEndpoint: APIEndpoint {
    case recordSwing(speedKmh: Double, accelerationG: Double, swingType: String)
    case getHistory(limit: Int)
    
    var path: String {
        switch self {
        case .recordSwing:
            return "swing/record"
        case .getHistory:
            return "swing/history"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .recordSwing:
            return .post
        case .getHistory:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getHistory(let limit):
            return [URLQueryItem(name: "limit", value: "\(limit)")]
        default:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .recordSwing(let speedKmh, let accelerationG, let swingType):
            let payload: [String: Any] = [
                "speed_kmh": speedKmh,
                "acceleration_g": accelerationG,
                "swing_type": swingType,
                "recorded_at": ISO8601DateFormatter().string(from: Date())
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
