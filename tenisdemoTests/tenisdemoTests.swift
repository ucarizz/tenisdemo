//
//  tenisdemoTests.swift
//  tenisdemoTests
//
//  Created by Antigravity on 31.07.2026.
//

import Testing
@testable import tenisdemo

@Suite struct TennisMatchScoringTests {

    // 1. Normal Puanlama Testi
    @Test func testNormalScoring() async throws {
        let viewModel = TennisMatchViewModel()
        viewModel.gamesPerSet = 4
        viewModel.setsToWin = 2
        viewModel.startMatch()
        
        // Başlangıç skoru 0-0 olmalı
        #expect(viewModel.state.p1Points == 0)
        #expect(viewModel.state.p2Points == 0)
        #expect(viewModel.state.p1Games == 0)
        
        // P1 1 puan kazanır -> 15 (p1Points = 1)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.p1Points == 1) // 15
        #expect(viewModel.state.p2Points == 0)
        
        // P1 2 puan kazanır -> 30 (p1Points = 2)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.p1Points == 2) // 30
        
        // P1 3 puan kazanır -> 40 (p1Points = 3)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.p1Points == 3) // 40
        
        // P1 4 puan kazanır -> Oyunu kazanmalı (Game P1, games = 1, points = 0-0)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.p1Games == 1)
        #expect(viewModel.state.p1Points == 0)
        #expect(viewModel.state.p2Points == 0)
    }

    // 2. Beraberlik (Deuce) ve Avantaj (Advantage) Testi
    @Test func testDeuceAndAdvantage() async throws {
        let viewModel = TennisMatchViewModel()
        viewModel.startMatch()
        
        // İki oyuncu da 3'er sayı kazanır -> 40-40 (Deuce)
        viewModel.scorePoint(for: .player1) // 15
        viewModel.scorePoint(for: .player1) // 30
        viewModel.scorePoint(for: .player1) // 40
        
        viewModel.scorePoint(for: .player2) // 15
        viewModel.scorePoint(for: .player2) // 30
        viewModel.scorePoint(for: .player2) // 40 (Deuce)
        
        #expect(viewModel.state.p1Points == 3)
        #expect(viewModel.state.p2Points == 3)
        
        // P1 puan alır -> Avantaj P1 (Ad, p1Points = 4)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.p1Points == 4)
        #expect(viewModel.state.p2Points == 3)
        
        // P2 puan alır -> Tekrar Deuce (40-40, p1Points = 3, p2Points = 3)
        viewModel.scorePoint(for: .player2)
        #expect(viewModel.state.p1Points == 3)
        #expect(viewModel.state.p2Points == 3)
        
        // P2 puan alır -> Avantaj P2 (p2Points = 4)
        viewModel.scorePoint(for: .player2)
        #expect(viewModel.state.p1Points == 3)
        #expect(viewModel.state.p2Points == 4)
        
        // P2 bir puan daha alır -> Oyunu kazanır (Game P2, games = 1)
        viewModel.scorePoint(for: .player2)
        #expect(viewModel.state.p2Games == 1)
        #expect(viewModel.state.p1Points == 0)
        #expect(viewModel.state.p2Points == 0)
    }

    // 3. Set Kazanma Kuralları Testi (Fark 2 olmalı)
    @Test func testSetWinConditions() async throws {
        let viewModel = TennisMatchViewModel()
        viewModel.gamesPerSet = 4
        viewModel.setsToWin = 2
        viewModel.startMatch()
        
        // P1 oyunu 3-2'ye getirsin
        viewModel.state.p1Games = 3
        viewModel.state.p2Games = 2
        
        // P1 bir oyun daha kazanır -> Set P1 (4-2)
        viewModel.state.p1Points = 3 // 40
        viewModel.scorePoint(for: .player1) // Win Game
        
        #expect(viewModel.state.p1Sets == 1)
        #expect(viewModel.state.p1Games == 0) // Set bitince sıfırlanır
        #expect(viewModel.state.p2Games == 0)
    }

    // 4. Tiebreak Tetiklenme ve Tiebreak Kazanma Testi
    @Test func testTiebreakTriggerAndWin() async throws {
        let viewModel = TennisMatchViewModel()
        viewModel.gamesPerSet = 4
        viewModel.useMatchTiebreak = false
        viewModel.startMatch()
        
        // Skor 4-3 olsun
        viewModel.state.p1Games = 4
        viewModel.state.p2Games = 3
        
        // P2 oyunu kazanarak skoru 4-4 yapar (Tiebreak tetiklenmeli)
        viewModel.state.p2Points = 3 // 40
        viewModel.scorePoint(for: .player2)
        
        #expect(viewModel.state.isTiebreak == true)
        #expect(viewModel.state.p1Points == 0) // Tiebreak puanları sıfırdan başlar
        #expect(viewModel.state.p2Points == 0)
        
        // Tiebreak'te P1 5, P2 5 puana ulaşsın
        viewModel.state.p1Points = 5
        viewModel.state.p2Points = 5
        
        // P1 6-5 yapar (2 fark olmadığı için devam eder)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.isTiebreak == true)
        
        // P1 7-5 yapar (En az 7 puan ve 2 fark kuralı sağlandı -> Set P1, Set skoru 5-4 olmalı)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.isTiebreak == false)
        #expect(viewModel.state.p1Sets == 1)
        #expect(viewModel.state.setScores.last?.p1Games == 5)
        #expect(viewModel.state.setScores.last?.p2Games == 4)
    }

    // 5. Süper Tiebreak (Match Tiebreak) Testi
    @Test func testSuperTiebreakTriggerAndWin() async throws {
        let viewModel = TennisMatchViewModel()
        viewModel.setsToWin = 2
        viewModel.useMatchTiebreak = true
        viewModel.startMatch()
        
        // Setlerde durum 1-1 olsun
        viewModel.state.p1Sets = 1
        viewModel.state.p2Sets = 1
        
        // Setler 1-1 iken maçı bitiren 3. set yerine 10 puanlık Süper Tiebreak tetiklenmeli
        viewModel.state.p1Games = 0
        viewModel.state.p2Games = 0
        viewModel.state.isTiebreak = true
        viewModel.state.isMatchTiebreak = true
        
        // Tiebreak puanlarını 9-9 yapalım
        viewModel.state.p1Points = 9
        viewModel.state.p2Points = 9
        
        // P1 puan alır -> 10-9 (Bitmez, 2 fark gerekir)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.isMatchOver == false)
        
        // P1 bir puan daha alır -> 11-9 (2 fark sağlandı -> Maç biter, Kazanan P1)
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.isMatchOver == true)
        #expect(viewModel.state.winner == .player1)
    }

    // 6. Geri Al (Undo) Operasyonu Testi
    @Test func testUndoOperation() async throws {
        let viewModel = TennisMatchViewModel()
        viewModel.startMatch()
        
        // P1 puan kazanır -> 15-0
        viewModel.scorePoint(for: .player1)
        #expect(viewModel.state.p1Points == 1)
        
        // P2 puan kazanır -> 15-15
        viewModel.scorePoint(for: .player1) // 30-0 oldu
        #expect(viewModel.state.p1Points == 2)
        
        // Geri al -> Tekrar 15-0 durumuna dönmeli
        viewModel.undo()
        #expect(viewModel.state.p1Points == 1)
        #expect(viewModel.state.p2Points == 0)
        
        // Bir kez daha geri al -> Maç başlangıcı 0-0 olmalı
        viewModel.undo()
        #expect(viewModel.state.p1Points == 0)
        #expect(viewModel.state.p2Points == 0)
    }
}
