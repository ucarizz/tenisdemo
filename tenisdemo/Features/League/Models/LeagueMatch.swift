//
//  LeagueMatch.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import Foundation

struct MatchPointHistory: Decodable, Identifiable {
    var id: Int { sequenceNumber }
    let p1Points: String
    let p2Points: String
    let p1Games: Int
    let p2Games: Int
    let p1Sets: Int
    let p2Sets: Int
    let server: String
    let sequenceNumber: Int
    let createdTime: String
    
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

struct LeagueMatch: Identifiable, Decodable {
    let id: Int
    let player1Name: String
    let player2Name: String
    let matchDate: String
    let score: String?
    let isCompleted: Bool
    let createDate: String?
    let isDouble: Bool
    let player1PartnerName: String?
    let player2PartnerName: String?
    let pointHistories: [MatchPointHistory]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case player1Name
        case player2Name
        case matchDate
        case score
        case isCompleted
        case createDate = "create_date"
        case isDouble = "is_double"
        case player1PartnerName = "player_1_partner_name"
        case player2PartnerName = "player_2_partner_name"
        case pointHistories = "pointHistories" // API default serializer retains camelCase
    }
    
    init(
        id: Int, 
        player1Name: String, 
        player2Name: String, 
        matchDate: String, 
        score: String?, 
        isCompleted: Bool, 
        createDate: String? = nil,
        isDouble: Bool = false,
        player1PartnerName: String? = nil,
        player2PartnerName: String? = nil,
        pointHistories: [MatchPointHistory]? = nil
    ) {
        self.id = id
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.matchDate = matchDate
        self.score = score
        self.isCompleted = isCompleted
        self.createDate = createDate
        self.isDouble = isDouble
        self.player1PartnerName = player1PartnerName
        self.player2PartnerName = player2PartnerName
        self.pointHistories = pointHistories
    }
}
