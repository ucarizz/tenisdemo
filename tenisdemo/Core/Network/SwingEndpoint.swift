//
//  SwingEndpoint.swift
//  tenisdemo
//
//  Created by Antigravity on 07.08.2026.
//

import Foundation

enum SwingEndpoint: APIEndpoint {
    case recordSwing(speedKmh: Double, accelerationG: Double, swingType: String, matchId: Int?)
    case getHistory(limit: Int)
    case getHistoryByMatch(matchId: Int)
    
    var path: String {
        switch self {
        case .recordSwing:
            return "swing/record"
        case .getHistory:
            return "swing/history"
        case .getHistoryByMatch(let matchId):
            return "swing/match/\(matchId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .recordSwing:
            return .post
        case .getHistory, .getHistoryByMatch:
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
        case .recordSwing(let speedKmh, let accelerationG, let swingType, let matchId):
            var payload: [String: Any] = [
                "speedKmh": speedKmh,
                "speed_kmh": speedKmh,
                "accelerationG": accelerationG,
                "acceleration_g": accelerationG,
                "swingType": swingType,
                "swing_type": swingType,
                "recordedAt": ISO8601DateFormatter().string(from: Date()),
                "recorded_at": ISO8601DateFormatter().string(from: Date())
            ]
            if let matchId = matchId {
                payload["matchId"] = matchId
                payload["match_id"] = matchId
            }
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
