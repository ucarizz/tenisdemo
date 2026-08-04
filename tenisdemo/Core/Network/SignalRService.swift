import Foundation
import Combine
import SignalRClient

struct LobbySettings: Codable, Equatable {
    var gamesPerSet: Int
    var setsToWin: Int
    var useMatchTiebreak: Bool
    
    enum CodingKeys: String, CodingKey {
        case gamesPerSet = "games_per_set"
        case setsToWin = "sets_to_win"
        case useMatchTiebreak = "use_match_tiebreak"
    }
}

struct LobbyState: Codable, Equatable {
    var code: String
    var hostName: String
    var hostPartnerName: String?
    var hostProfileImageUrl: String?
    var guestName: String?
    var guestPartnerName: String?
    var guestProfileImageUrl: String?
    var isDouble: Bool
    var settings: LobbySettings
    var isMatchStarted: Bool
    
    enum CodingKeys: String, CodingKey {
        case code
        case hostName = "host_name"
        case hostPartnerName = "host_partner_name"
        case hostProfileImageUrl = "host_profile_image_url"
        case guestName = "guest_name"
        case guestPartnerName = "guest_partner_name"
        case guestProfileImageUrl = "guest_profile_image_url"
        case isDouble = "is_double"
        case settings
        case isMatchStarted = "is_match_started"
    }
}

struct SetScoreState: Codable, Equatable {
    var p1Games: Int
    var p2Games: Int
    
    enum CodingKeys: String, CodingKey {
        case p1Games = "p1_games"
        case p2Games = "p2_games"
    }
}

struct LiveMatchState: Codable, Equatable {
    var p1Points: Int
    var p2Points: Int
    var p1Games: Int
    var p2Games: Int
    var p1Sets: Int
    var p2Sets: Int
    var setScores: [SetScoreState]
    var isTiebreak: Bool
    var isMatchTiebreak: Bool
    var server: String
    var isMatchOver: Bool
    var winner: String?
    var history: [PointHistoryItem]
    
    enum CodingKeys: String, CodingKey {
        case p1Points = "p1_points"
        case p2Points = "p2_points"
        case p1Games = "p1_games"
        case p2Games = "p2_games"
        case p1Sets = "p1_sets"
        case p2Sets = "p2_sets"
        case setScores = "set_scores"
        case isTiebreak = "is_tiebreak"
        case isMatchTiebreak = "is_match_tiebreak"
        case server
        case isMatchOver = "is_match_over"
        case winner
        case history
    }
}

class SignalRService: ObservableObject, HubConnectionDelegate {
    static let shared = SignalRService()
    
    private var connection: HubConnection?
    
    @Published var isConnected = false
    @Published var lobbyState: LobbyState? = nil
    @Published var isMatchStarted = false
    @Published var remoteMatchState: LiveMatchState? = nil
    @Published var errorMessage: String? = nil
    @Published var activeMatchId: Int? = nil
    
    private init() {
        setupConnection()
    }
    
    private func setupConnection() {
        // APIEndpoint IP adresimizle aynı
        let urlString = AppEnvironment.current.signalRBaseURL
        guard let url = URL(string: urlString) else { return }
        
        connection = HubConnectionBuilder(url: url)
            .withLogging(minLogLevel: .info)
            .build()
        
        connection?.delegate = self
        
        // Lobi kuruldu yayını
        connection?.on(method: "LobbyCreated", callback: { (lobby: LobbyState) in
            DispatchQueue.main.async {
                self.lobbyState = lobby
                self.errorMessage = nil
            }
        })
        
        // Lobi güncellendi (Rakip katıldı) yayını
        connection?.on(method: "LobbyUpdated", callback: { (lobby: LobbyState) in
            DispatchQueue.main.async {
                self.lobbyState = lobby
                self.errorMessage = nil
            }
        })
        
        // Lobi ayarları değişti yayını
        connection?.on(method: "LobbySettingsUpdated", callback: { (settings: LobbySettings) in
            DispatchQueue.main.async {
                self.lobbyState?.settings = settings
            }
        })
        
        // Maç başladı yayını
        connection?.on(method: "MatchStarted", callback: { (matchId: Int) in
            DispatchQueue.main.async {
                self.activeMatchId = matchId
                self.isMatchStarted = true
            }
        })
        
        // Canlı skor güncellendi yayını
        connection?.on(method: "ScoreUpdated", callback: { (score: LiveMatchState) in
            DispatchQueue.main.async {
                self.remoteMatchState = score
            }
        })
        
        // Oyuncu ayrıldı yayını
        connection?.on(method: "PlayerLeft", callback: {
            DispatchQueue.main.async {
                self.errorMessage = "Rakip lobiden/maçtan ayrıldı."
                self.lobbyState = nil
                self.isMatchStarted = false
                self.remoteMatchState = nil
            }
        })
        
        // Sunucu hata yayını
        connection?.on(method: "Error", callback: { (errorMsg: String) in
            DispatchQueue.main.async {
                self.errorMessage = errorMsg
            }
        })
        
        start()
    }
    
    func start() {
        guard let connection = connection else { return }
        if !isConnected {
            connection.start()
        }
    }
    
    func stop() {
        connection?.stop()
    }
    
    // HubConnectionDelegate
    func connectionDidOpen(hubConnection: HubConnection) {
        DispatchQueue.main.async {
            self.isConnected = true
        }
    }
    
    func connectionDidFailToOpen(error: Error) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.errorMessage = "Bağlantı kurulamadı: \(error.localizedDescription)"
        }
    }
    
    func connectionDidClose(error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            if let error = error {
                self.errorMessage = "Bağlantı koptu: \(error.localizedDescription)"
            }
        }
    }
    
    // Sunucu Metodları (Invocations)
    func createLobby(hostName: String, isDouble: Bool, hostPartnerName: String?, hostProfileImageUrl: String?) {
        errorMessage = nil
        isMatchStarted = false
        remoteMatchState = nil
        lobbyState = nil
        
        connection?.invoke(method: "createLobby", arguments: [hostName, isDouble, hostPartnerName ?? "", hostProfileImageUrl ?? ""]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Lobi oluşturulamadı: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func joinLobby(code: String, guestName: String, guestPartnerName: String?, guestProfileImageUrl: String?) {
        errorMessage = nil
        isMatchStarted = false
        remoteMatchState = nil
        lobbyState = nil
        
        connection?.invoke(method: "joinLobby", arguments: [code, guestName, guestPartnerName ?? "", guestProfileImageUrl ?? ""]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Lobiye katılamadı: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func updateSettings(code: String, gamesPerSet: Int, setsToWin: Int, useMatchTiebreak: Bool) {
        let settings = LobbySettings(gamesPerSet: gamesPerSet, setsToWin: setsToWin, useMatchTiebreak: useMatchTiebreak)
        connection?.invoke(method: "updateSettings", arguments: [code, settings]) { error in
            if let error = error {
                print("Ayarlar güncellenemedi: \(error.localizedDescription)")
            }
        }
    }
    
    func startMatch(code: String) {
        connection?.invoke(method: "startMatch", arguments: [code]) { error in
            if let error = error {
                print("Maç başlatılamadı: \(error.localizedDescription)")
            }
        }
    }
    
    func sendScoreUpdate(code: String, state: LiveMatchState) {
        connection?.invoke(method: "sendScoreUpdate", arguments: [code, state]) { error in
            if let error = error {
                print("Skor gönderilemedi: \(error.localizedDescription)")
            }
        }
    }
    
    func leaveLobby(code: String) {
        connection?.invoke(method: "leaveLobby", arguments: [code]) { _ in
            DispatchQueue.main.async {
                self.lobbyState = nil
                self.isMatchStarted = false
                self.remoteMatchState = nil
            }
        }
    }
}
