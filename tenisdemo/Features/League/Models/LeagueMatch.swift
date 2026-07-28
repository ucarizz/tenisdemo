//
//  LeagueMatch.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import Foundation

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
    
    // Eski çağrılarda hata oluşmaması için varsayılan kurucu metot ekliyoruz
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
        player2PartnerName: String? = nil
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
    }
}
