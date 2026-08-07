//
//  WatchConnectivityManager.swift
//  tenisdemo
//
//  Created by Antigravity on 30.07.2026.
//

import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private var session: WCSession = .default
    var viewModel: TennisMatchViewModel?
    
    @Published var isWatchPaired = false
    @Published var isWatchAppInstalled = false
    @Published var isReachable = false
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func setup(viewModel: TennisMatchViewModel) {
        self.viewModel = viewModel
        // İlk bağlantıda mevcut durumu gönder
        syncWithWatch()
    }
    
    func syncWithWatch() {
        guard let viewModel = viewModel, WCSession.isSupported() && session.activationState == .activated else { return }
        
        let encoder = JSONEncoder()
        if let stateData = try? encoder.encode(viewModel.state) {
            let context: [String: Any] = [
                "hasMatchStarted": viewModel.hasMatchStarted,
                "player1Name": viewModel.player1Name,
                "player2Name": viewModel.player2Name,
                "isDouble": viewModel.isDouble,
                "player1PartnerName": viewModel.player1PartnerName,
                "player2PartnerName": viewModel.player2PartnerName,
                "gamesPerSet": viewModel.gamesPerSet,
                "setsToWin": viewModel.setsToWin,
                "useMatchTiebreak": viewModel.useMatchTiebreak,
                "canUndo": !viewModel.history.isEmpty,
                "stateData": stateData
            ]
            
            // 1. Arka plan/başlangıç senkronizasyonu için önbelleğe al
            do {
                try session.updateApplicationContext(context)
                print("DEBUG [WatchConnectivity]: Match state successfully context-updated.")
            } catch {
                print("DEBUG [WatchConnectivity]: Failed to update context: \(error.localizedDescription)")
            }
            
            // 2. Anlık yüksek öncelikli mesaj gönder (Real-time güncelleme için)
            session.sendMessage(context, replyHandler: nil) { error in
                print("DEBUG [WatchConnectivity]: Live message send failed (normal if watch is inactive): \(error.localizedDescription)")
            }
        }
    }
    
    // WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
            print("DEBUG [WatchConnectivity]: Session activated state = \(activationState.rawValue), error = \(String(describing: error))")
            if activationState == .activated {
                self.syncWithWatch()
            }
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Oturum sıfırlandıktan sonra tekrar aktif hale getirilir (saat geçişlerinde)
        session.activate()
    }
    #endif
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    // Saatten gelen anlık komutları (puan artırma vb.) karşılar
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let action = message["action"] as? String else { return }
        
        print("DEBUG [WatchConnectivity]: Received action from watch: \(action)")
        
        DispatchQueue.main.async {
            guard let viewModel = self.viewModel else { return }
            
            switch action {
            case "scorePoint":
                if let playerString = message["player"] as? String,
                   let player = Player(rawValue: playerString) {
                    viewModel.scorePoint(for: player)
                }
            case "undo":
                viewModel.undo()
            case "reset":
                viewModel.reset()
            case "newMatch":
                viewModel.newMatch()
            case "recordSwing":
                if let speedKmh = message["speedKmh"] as? Double,
                   let accelerationG = message["accelerationG"] as? Double,
                   let swingType = message["swingType"] as? String {
                    let matchId = self.viewModel?.activeMatchId
                    Task {
                        do {
                            let client = URLSessionAPIClient()
                            struct SwingResponse: Decodable { let id: Int }
                            let _: SwingResponse = try await client.request(SwingEndpoint.recordSwing(speedKmh: speedKmh, accelerationG: accelerationG, swingType: swingType, matchId: matchId))
                            print("DEBUG [WatchConnectivity]: Swing speed recorded successfully in DB (MatchId: \(String(describing: matchId))).")
                        } catch {
                            print("DEBUG [WatchConnectivity]: Failed to upload swing: \(error.localizedDescription)")
                        }
                    }
                }
            default:
                break
            }
            
            // Güncellenen durumu saat tarafına hemen geri besle
            self.syncWithWatch()
        }
    }
}
