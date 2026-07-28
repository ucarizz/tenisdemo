//
//  TennisMatch.swift
//  tenisdemo Watch App
//
//  Created by Antigravity on 19.07.2026.
//

import Foundation
import WatchKit
import SwiftUI

enum Player: String, Codable {
    case player1 = "SİZ"
    case player2 = "RAKİP"
}

struct SetScore: Codable, Equatable, Identifiable {
    let id: UUID
    let p1Games: Int
    let p2Games: Int
    
    init(p1Games: Int, p2Games: Int) {
        self.id = UUID()
        self.p1Games = p1Games
        self.p2Games = p2Games
    }
}

struct MatchState: Codable, Equatable {
    var p1Points: Int = 0
    var p2Points: Int = 0
    var p1Games: Int = 0
    var p2Games: Int = 0
    var p1Sets: Int = 0
    var p2Sets: Int = 0
    var setScores: [SetScore] = []
    var isTiebreak: Bool = false
    var isMatchTiebreak: Bool = false // 3. Set yerine oynanan 10 puanlık final tiebreak
    var server: Player = .player1
    var isMatchOver: Bool = false
    var winner: Player? = nil
}

class TennisMatchViewModel: ObservableObject {
    @Published var state = MatchState()
    @Published var history: [MatchState] = []
    @Published var startingServer: Player = .player1
    @Published var player1Name: String = "SİZ"
    @Published var player2Name: String = "RAKİP"
    @Published var isDouble: Bool = false
    @Published var player1PartnerName: String = ""
    @Published var player2PartnerName: String = ""
    
    // Kullanıcı Tarafından Seçilecek Maç Kuralları
    @Published var gamesPerSet: Int = 4             // Bir seti almak için gereken oyun sayısı (Örn: 4 veya 6)
    @Published var setsToWin: Int = 2               // Maçı kazanmak için gereken set sayısı (Örn: 1 veya 2)
    @Published var useMatchTiebreak: Bool = true     // 1-1 (veya berabere) set durumunda 3. set yerine 10 puanlık Tiebreak
    @Published var hasMatchStarted: Bool = false    // Maç başladı mı? (Kurulum ekranı kontrolü)
    
    func startMatch() {
        reset()
        hasMatchStarted = true
    }
    
    func newMatch() {
        reset()
        hasMatchStarted = false
    }
    
    func scorePoint(for player: Player) {
        if state.isMatchOver { return }
        
        // Undo için mevcut durumu geçmişe ekle
        history.append(state)
        
        if state.isTiebreak {
            scoreTiebreakPoint(for: player)
        } else {
            scoreNormalPoint(for: player)
        }
        
        playHapticFeedback()
        
        // Maç bittiyse otomatik olarak sunucuya kaydet
        if state.isMatchOver {
            syncMatchResult()
        }
    }
    
    private func scoreNormalPoint(for player: Player) {
        if player == .player1 {
            if state.p1Points == 3 && state.p2Points < 3 {
                winGame(for: .player1)
            } else if state.p1Points == 3 && state.p2Points == 3 {
                state.p1Points = 4 // Avantaj (Ad)
            } else if state.p1Points == 4 && state.p2Points == 3 {
                winGame(for: .player1)
            } else if state.p1Points == 3 && state.p2Points == 4 {
                state.p2Points = 3 // Deuce'a geri dön
            } else {
                state.p1Points += 1
            }
        } else {
            if state.p2Points == 3 && state.p1Points < 3 {
                winGame(for: .player2)
            } else if state.p2Points == 3 && state.p1Points == 3 {
                state.p2Points = 4 // Avantaj (Ad)
            } else if state.p2Points == 4 && state.p1Points == 3 {
                winGame(for: .player2)
            } else if state.p2Points == 3 && state.p1Points == 4 {
                state.p1Points = 3 // Deuce'a geri dön
            } else {
                state.p2Points += 1
            }
        }
    }
    
    private func scoreTiebreakPoint(for player: Player) {
        if player == .player1 {
            state.p1Points += 1
        } else {
            state.p2Points += 1
        }
        
        // Match Tiebreak (10 puanlık) veya normal Tiebreak (7 puanlık) limit belirleme
        let targetPoints = state.isMatchTiebreak ? 10 : 7
        
        // Tiebreak galibiyeti: En az targetPoints sayı ve 2 sayı fark olmalı
        if state.p1Points >= targetPoints && (state.p1Points - state.p2Points) >= 2 {
            if state.isMatchTiebreak {
                winMatch(for: .player1)
            } else {
                winTiebreak(for: .player1)
            }
        } else if state.p2Points >= targetPoints && (state.p2Points - state.p1Points) >= 2 {
            if state.isMatchTiebreak {
                winMatch(for: .player2)
            } else {
                winTiebreak(for: .player2)
            }
        } else {
            // Tiebreak'te servis değişimi: İlk sayıdan sonra, ardından her 2 sayıda bir
            if (state.p1Points + state.p2Points) % 2 == 1 {
                toggleServer()
            }
        }
    }
    
    private func winGame(for player: Player) {
        state.p1Points = 0
        state.p2Points = 0
        toggleServer()
        
        if player == .player1 {
            state.p1Games += 1
        } else {
            state.p2Games += 1
        }
        
        checkSetWin()
    }
    
    private func winTiebreak(for player: Player) {
        state.p1Points = 0
        state.p2Points = 0
        state.isTiebreak = false
        
        if player == .player1 {
            state.p1Games = gamesPerSet + 1
            state.p2Games = gamesPerSet
        } else {
            state.p1Games = gamesPerSet
            state.p2Games = gamesPerSet + 1
        }
        
        winSet(for: player)
    }
    
    private func checkSetWin() {
        if state.p1Games >= gamesPerSet && (state.p1Games - state.p2Games) >= 2 {
            winSet(for: .player1)
        } else if state.p2Games >= gamesPerSet && (state.p2Games - state.p1Games) >= 2 {
            winSet(for: .player2)
        } else if state.p1Games == gamesPerSet && state.p2Games == gamesPerSet {
            state.isTiebreak = true
        }
    }
    
    private func winSet(for player: Player) {
        state.setScores.append(SetScore(p1Games: state.p1Games, p2Games: state.p2Games))
        state.p1Games = 0
        state.p2Games = 0
        
        if player == .player1 {
            state.p1Sets += 1
        } else {
            state.p2Sets += 1
        }
        
        if state.p1Sets >= setsToWin {
            state.isMatchOver = true
            state.winner = .player1
        } else if state.p2Sets >= setsToWin {
            state.isMatchOver = true
            state.winner = .player2
        } else {
            // Set skorları berabere ve karar setine giriliyorsa (Örn: 1-1 set skoru ve setsToWin = 2)
            if useMatchTiebreak && state.p1Sets == state.p2Sets && state.p1Sets == (setsToWin - 1) {
                state.isTiebreak = true
                state.isMatchTiebreak = true
            }
        }
    }
    
    private func winMatch(for player: Player) {
        // Match tiebreak skorunu set olarak kaydet
        if player == .player1 {
            state.p1Games = state.p1Points
            state.p2Games = state.p2Points
            state.p1Sets += 1
        } else {
            state.p1Games = state.p1Points
            state.p2Games = state.p2Points
            state.p2Sets += 1
        }
        state.setScores.append(SetScore(p1Games: state.p1Games, p2Games: state.p2Games))
        
        state.p1Points = 0
        state.p2Points = 0
        state.isTiebreak = false
        state.isMatchTiebreak = false
        state.isMatchOver = true
        state.winner = player
    }
    
    private func toggleServer() {
        state.server = (state.server == .player1) ? .player2 : .player1
    }
    
    func toggleStartingServer() {
        if state.p1Points == 0 && state.p2Points == 0 && state.p1Games == 0 && state.p2Games == 0 && state.setScores.isEmpty {
            toggleServer()
            startingServer = state.server
            WKInterfaceDevice.current().play(.click)
        }
    }
    
    func undo() {
        guard let previousState = history.popLast() else { return }
        state = previousState
        WKInterfaceDevice.current().play(.directionDown)
    }
    
    func reset() {
        history.removeAll()
        state = MatchState()
        state.server = startingServer
        WKInterfaceDevice.current().play(.retry)
    }
    
    private func playHapticFeedback() {
        if state.isMatchOver {
            WKInterfaceDevice.current().play(.success)
        } else if state.p1Games == 0 && state.p2Games == 0 && state.p1Points == 0 && state.p2Points == 0 {
            WKInterfaceDevice.current().play(.success)
        } else if state.p1Points == 0 && state.p2Points == 0 {
            WKInterfaceDevice.current().play(.directionUp)
        } else {
            WKInterfaceDevice.current().play(.click)
        }
    }
    
    func formatPoints(_ points: Int, isTiebreak: Bool) -> String {
        if isTiebreak {
            return "\(points)"
        }
        switch points {
        case 0: return "0"
        case 1: return "15"
        case 2: return "30"
        case 3: return "40"
        case 4: return "Ad"
        default: return ""
        }
    }
    
    // Maçı API'ye gönderme / Senkronizasyon (Option 2)
    private func syncMatchResult() {
        let p1 = player1Name.isEmpty ? "SİZ" : player1Name
        let p2 = player2Name.isEmpty ? "RAKİP" : player2Name
        let p1Partner = isDouble ? (player1PartnerName.isEmpty ? "ORTAK 1" : player1PartnerName) : nil
        let p2Partner = isDouble ? (player2PartnerName.isEmpty ? "ORTAK 2" : player2PartnerName) : nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm"
        let dateString = formatter.string(from: Date())
        
        let scoreString = state.setScores.map { "\($0.p1Games)-\($0.p2Games)" }.joined(separator: ", ")
        
        let historyItems = history.enumerated().map { (index, s) in
            return PointHistoryItem(
                p1Points: s.p1Points,
                p2Points: s.p2Points,
                p1Games: s.p1Games,
                p2Games: s.p2Games,
                p1Sets: s.p1Sets,
                p2Sets: s.p2Sets,
                server: s.server.rawValue,
                sequenceNumber: index
            )
        }
        
        Task {
            do {
                let service = LeagueService()
                let savedMatch = try await service.saveCompletedMatch(
                    player1: p1,
                    player2: p2,
                    date: dateString,
                    score: scoreString,
                    isDouble: isDouble,
                    player1Partner: p1Partner,
                    player2Partner: p2Partner,
                    history: historyItems
                )
                print("Maç sunucuya başarıyla kaydedildi. Veritabanı ID: \(savedMatch.id)")
            } catch {
                print("Maç sunucuya kaydedilemedi: \(error.localizedDescription)")
            }
        }
    }
}
