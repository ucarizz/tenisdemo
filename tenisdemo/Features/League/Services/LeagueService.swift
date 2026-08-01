//
//  LeagueService.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import Foundation

// Sayı geçmişi detayı veri transfer modeli
struct PointHistoryItem: Codable, Equatable {
    var p1Points: String
    var p2Points: String
    var p1Games: Int
    var p2Games: Int
    var p1Sets: Int
    var p2Sets: Int
    var server: String
    var sequenceNumber: Int
    var createdTime: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case p1Points = "p1_points"
        case p2Points = "p2_points"
        case p1Games = "p1_games"
        case p2Games = "p2_games"
        case p1Sets = "p1_sets"
        case p2Sets = "p2_sets"
        case server
        case sequenceNumber = "sequence_number"
        case createdTime = "created_time"
    }
}

// Tamamlanmış maç kaydetme istek modeli
struct SaveCompletedMatchRequest: Encodable {
    let player1Name: String
    let player2Name: String
    let matchDate: String
    let score: String
    let isDouble: Bool
    let player1PartnerName: String?
    let player2PartnerName: String?
    let history: [PointHistoryItem]
    
    enum CodingKeys: String, CodingKey {
        case player1Name = "player_1_name"
        case player2Name = "player_2_name"
        case matchDate = "match_date"
        case score
        case isDouble = "is_double"
        case player1PartnerName = "player_1_partner_name"
        case player2PartnerName = "player_2_partner_name"
        case history
    }
}

// Lig Modülüne Özel API Uç Noktaları
enum LeagueEndpoint: APIEndpoint {
    case getMatches
    case getMatchDetails(id: Int)
    case saveCompleted(
        player1: String, 
        player2: String, 
        date: String, 
        score: String, 
        isDouble: Bool, 
        player1Partner: String?, 
        player2Partner: String?, 
        history: [PointHistoryItem]
    )
    case updateLiveProgress(
        id: Int,
        score: String,
        isCompleted: Bool,
        history: [PointHistoryItem]
    )
    case createMatch(
        player1: String,
        player2: String,
        date: String,
        isDouble: Bool,
        player1Partner: String?,
        player2Partner: String?
    )
    
    var path: String {
        switch self {
        case .getMatches, .createMatch:
            return "/matches"
        case .getMatchDetails(let id):
            return "/matches/\(id)"
        case .saveCompleted:
            return "/matches/completed"
        case .updateLiveProgress(let id, _, _, _):
            return "/matches/\(id)/live-progress"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMatches, .getMatchDetails:
            return .get
        case .saveCompleted:
            return .post
        case .createMatch:
            return .post
        case .updateLiveProgress:
            return .put
        }
    }
    
    var body: Data? {
        switch self {
        case .saveCompleted(let p1, let p2, let date, let score, let isDouble, let p1Partner, let p2Partner, let history):
            let request = SaveCompletedMatchRequest(
                player1Name: p1,
                player2Name: p2,
                matchDate: date,
                score: score,
                isDouble: isDouble,
                player1PartnerName: p1Partner,
                player2PartnerName: p2Partner,
                history: history
            )
            return try? JSONEncoder().encode(request)
        case .createMatch(let p1, let p2, let date, let isDouble, let p1Partner, let p2Partner):
            struct CreateRequest: Encodable {
                let player1Name: String
                let player2Name: String
                let matchDate: String
                let isDouble: Bool
                let player1PartnerName: String?
                let player2PartnerName: String?
                
                enum CodingKeys: String, CodingKey {
                    case player1Name = "player_1_name"
                    case player2Name = "player_2_name"
                    case matchDate = "match_date"
                    case isDouble = "is_double"
                    case player1PartnerName = "player_1_partner_name"
                    case player2PartnerName = "player_2_partner_name"
                }
            }
            let request = CreateRequest(
                player1Name: p1,
                player2Name: p2,
                matchDate: date,
                isDouble: isDouble,
                player1PartnerName: p1Partner,
                player2PartnerName: p2Partner
            )
            return try? JSONEncoder().encode(request)
        case .updateLiveProgress(_, let score, let isCompleted, let history):
            struct UpdateProgressRequest: Encodable {
                let score: String
                let isCompleted: Bool
                let history: [PointHistoryItem]
                
                enum CodingKeys: String, CodingKey {
                    case score
                    case isCompleted = "is_completed"
                    case history
                }
            }
            let request = UpdateProgressRequest(score: score, isCompleted: isCompleted, history: history)
            return try? JSONEncoder().encode(request)
        default:
            return nil
        }
    }
}

protocol LeagueServiceProtocol {
    func fetchMatches() async throws -> [LeagueMatch]
    func createMatch(
        player1: String,
        player2: String,
        date: String,
        isDouble: Bool,
        player1Partner: String?,
        player2Partner: String?
    ) async throws -> LeagueMatch
    func saveCompletedMatch(
        player1: String, 
        player2: String, 
        date: String, 
        score: String, 
        isDouble: Bool, 
        player1Partner: String?, 
        player2Partner: String?, 
        history: [PointHistoryItem]
    ) async throws -> LeagueMatch
    
    func updateLiveProgress(
        id: Int,
        score: String,
        isCompleted: Bool,
        history: [PointHistoryItem]
    ) async throws
}

struct UpdateLiveProgressResponse: Decodable {
    let message: String
}

class LeagueService: LeagueServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = URLSessionAPIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchMatches() async throws -> [LeagueMatch] {
        return try await apiClient.request(LeagueEndpoint.getMatches)
    }
    
    func createMatch(
        player1: String,
        player2: String,
        date: String,
        isDouble: Bool,
        player1Partner: String?,
        player2Partner: String?
    ) async throws -> LeagueMatch {
        return try await apiClient.request(LeagueEndpoint.createMatch(
            player1: player1,
            player2: player2,
            date: date,
            isDouble: isDouble,
            player1Partner: player1Partner,
            player2Partner: player2Partner
        ))
    }
    
    func saveCompletedMatch(
        player1: String, 
        player2: String, 
        date: String, 
        score: String, 
        isDouble: Bool, 
        player1Partner: String?, 
        player2Partner: String?, 
        history: [PointHistoryItem]
    ) async throws -> LeagueMatch {
        return try await apiClient.request(LeagueEndpoint.saveCompleted(
            player1: player1,
            player2: player2,
            date: date,
            score: score,
            isDouble: isDouble,
            player1Partner: player1Partner,
            player2Partner: player2Partner,
            history: history
        ))
    }
    
    func updateLiveProgress(
        id: Int,
        score: String,
        isCompleted: Bool,
        history: [PointHistoryItem]
    ) async throws {
        let _: UpdateLiveProgressResponse = try await apiClient.request(LeagueEndpoint.updateLiveProgress(
            id: id,
            score: score,
            isCompleted: isCompleted,
            history: history
        ))
    }
}
