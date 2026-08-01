//
//  WatchConnectivityManager.swift
//  tenisdemo Watch App
//
//  Created by Antigravity on 30.07.2026.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private var session: WCSession = .default
    var viewModel: TennisMatchViewModel?
    private var pendingPayload: [String: Any]? = nil
    
    @Published var isReachable = false
    @Published var isCompanionActive = false
    @Published var canUndo = false
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func setup(viewModel: TennisMatchViewModel) {
        self.viewModel = viewModel
        if let pending = pendingPayload {
            parsePayload(pending)
        }
    }
    
    // Telefondan gelen durum güncellemelerini karşılar (Arka plan/Başlangıç)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("DEBUG [WatchConnectivity]: Received context from iPhone.")
        parsePayload(applicationContext)
    }
    
    // Telefondan gelen durum güncellemelerini karşılar (Anlık/Yüksek Öncelikli)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("DEBUG [WatchConnectivity]: Received live message from iPhone.")
        parsePayload(message)
    }
    
    private func parsePayload(_ payload: [String: Any]) {
        DispatchQueue.main.async {
            guard let viewModel = self.viewModel else {
                self.pendingPayload = payload
                print("DEBUG [WatchConnectivity]: ViewModel not ready, payload cached.")
                return
            }
            self.pendingPayload = nil
            
            if let hasMatchStarted = payload["hasMatchStarted"] as? Bool {
                viewModel.hasMatchStarted = hasMatchStarted
                self.isCompanionActive = hasMatchStarted
            }
            if let player1Name = payload["player1Name"] as? String {
                viewModel.player1Name = player1Name
            }
            if let player2Name = payload["player2Name"] as? String {
                viewModel.player2Name = player2Name
            }
            if let isDouble = payload["isDouble"] as? Bool {
                viewModel.isDouble = isDouble
            }
            if let player1PartnerName = payload["player1PartnerName"] as? String {
                viewModel.player1PartnerName = player1PartnerName
            }
            if let player2PartnerName = payload["player2PartnerName"] as? String {
                viewModel.player2PartnerName = player2PartnerName
            }
            if let gamesPerSet = payload["gamesPerSet"] as? Int {
                viewModel.gamesPerSet = gamesPerSet
            }
            if let setsToWin = payload["setsToWin"] as? Int {
                viewModel.setsToWin = setsToWin
            }
            if let useMatchTiebreak = payload["useMatchTiebreak"] as? Bool {
                viewModel.useMatchTiebreak = useMatchTiebreak
            }
            if let canUndo = payload["canUndo"] as? Bool {
                self.canUndo = canUndo
            }
            
            if let stateData = payload["stateData"] as? Data {
                let decoder = JSONDecoder()
                if let decodedState = try? decoder.decode(MatchState.self, from: stateData) {
                    viewModel.state = decodedState
                    print("DEBUG [WatchConnectivity]: Decoded match state: \(decodedState.p1Points)-\(decodedState.p2Points)")
                }
            }
        }
    }
    
    // WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("DEBUG [WatchConnectivity]: Watch session activated: \(activationState.rawValue)")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    // Telefondaki maça skor/aksiyon gönderir
    func sendScoreAction(for player: Player) {
        sendMessageToCompanion(["action": "scorePoint", "player": player.rawValue])
    }
    
    func sendUndoAction() {
        sendMessageToCompanion(["action": "undo"])
    }
    
    func sendResetAction() {
        sendMessageToCompanion(["action": "reset"])
    }
    
    func sendNewMatchAction() {
        sendMessageToCompanion(["action": "newMatch"])
        self.isCompanionActive = false
    }
    
    private func sendMessageToCompanion(_ message: [String: Any]) {
        guard session.activationState == .activated else { return }
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("DEBUG [WatchConnectivity]: Error sending message: \(error.localizedDescription)")
            // Hata durumunda yerel olarak işlem yapabilmesi için uyarı yazdırıyoruz
        }
    }
}
