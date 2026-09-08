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

struct LobbyPlayer: Codable, Equatable, Identifiable {
    var id: String { connectionId.isEmpty ? "\(name)-\(slotIndex)" : connectionId }
    var connectionId: String
    var userId: String?
    var name: String
    var profileImageUrl: String?
    var team: Int
    var slotIndex: Int
    var isHost: Bool
    var isReady: Bool
    
    enum CodingKeys: String, CodingKey {
        case connectionId = "connection_id"
        case userId = "user_id"
        case name
        case profileImageUrl = "profile_image_url"
        case team
        case slotIndex = "slot_index"
        case isHost = "is_host"
        case isReady = "is_ready"
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
    var players: [LobbyPlayer]?
    var maxPlayers: Int?
    
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
        case players
        case maxPlayers = "max_players"
    }
    
    func playerAt(slot: Int) -> LobbyPlayer? {
        return players?.first(where: { $0.slotIndex == slot })
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
    var isGameBreak: Bool? = false
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
        case isGameBreak = "is_game_break"
        case history
    }
}

struct TossResult: Equatable {
    var result: String // "UP" veya "DOWN"
    var winnerSlot: Int // 0: Takım 1, 2: Takım 2
    var winnerName: String
}

class SignalRService: ObservableObject, HubConnectionDelegate {
    static let shared = SignalRService()
    
    private var connection: HubConnection?
    
    @Published var isConnected = false
    @Published var lobbyState: LobbyState? = nil
    @Published var isMatchStarted = false
    @Published var remoteMatchState: LiveMatchState? = nil
    @Published var errorMessage: String? = nil
    @Published var notificationMessage: String? = nil
    @Published var playerLeftMatchAlert: String? = nil
    @Published var activeMatchId: Int? = nil
    
    // Raket Çevirme (Kura) Durumu
    @Published var isTossActive: Bool = false
    @Published var tossResult: TossResult? = nil
    @Published var initialServerChoice: String? = nil
    @Published var currentTossChoice: String? = nil // "SERVE" veya "RECEIVE"
    @Published var mySlotIndex: Int = 0
    
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
        
        // Lobi güncellendi (Rakip katıldı / slot değişti / biri ayrıldı) yayını
        connection?.on(method: "LobbyUpdated", callback: { (lobby: LobbyState) in
            DispatchQueue.main.async {
                self.lobbyState = lobby
                self.errorMessage = nil
            }
        })
        
        // Slot boşaldı (Biri ayrıldı) bilgilendirmesi
        connection?.on(method: "PlayerLeftSlot", callback: { (playerName: String) in
            DispatchQueue.main.async {
                self.notificationMessage = "\(playerName) lobiden ayrıldı."
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    if self.notificationMessage == "\(playerName) lobiden ayrıldı." {
                        self.notificationMessage = nil
                    }
                }
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
        
        // Kurucu ayrıldı / Lobi kapandı / Rakip maçtan ayrıldı yayını
        connection?.on(method: "PlayerLeft", callback: { (reason: String) in
            DispatchQueue.main.async {
                self.errorMessage = reason
                self.playerLeftMatchAlert = reason
                self.lobbyState = nil
                self.isMatchStarted = false
                self.remoteMatchState = nil
            }
        })
        
        // Maç esnasında çiftler maçında bir oyuncu ayrıldı yayını
        connection?.on(method: "PlayerLeftMatch", callback: { (playerName: String) in
            DispatchQueue.main.async {
                let msg = "\(playerName) maçtan ayrıldı."
                self.notificationMessage = msg
                self.playerLeftMatchAlert = msg
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if self.notificationMessage == msg {
                        self.notificationMessage = nil
                    }
                }
            }
        })
        
        // Sunucu hata yayını
        connection?.on(method: "Error", callback: { (errorMsg: String) in
            DispatchQueue.main.async {
                self.errorMessage = errorMsg
            }
        })
        
        // Kura başladı yayını
        connection?.on(method: "TossStarted", callback: {
            DispatchQueue.main.async {
                self.isTossActive = true
                self.tossResult = nil
                self.initialServerChoice = nil
                self.currentTossChoice = nil
            }
        })
        
        // Raket çevrildi ve sonuç geldi yayını
        connection?.on(method: "RacketSpun", callback: { (result: String, winnerSlot: Int, winnerName: String) in
            DispatchQueue.main.async {
                self.isTossActive = true
                self.tossResult = TossResult(result: result, winnerSlot: winnerSlot, winnerName: winnerName)
            }
        })
        
        // Kazanan servis tercihi yaptığında anında diğer oyuncuya yansıtma yayını
        connection?.on(method: "TossChoiceUpdated", callback: { (choice: String, startingServer: String) in
            DispatchQueue.main.async {
                self.currentTossChoice = choice
                self.initialServerChoice = startingServer
            }
        })
        
        // Kura tercihi seçildi ve maç başlatılıyor yayını
        connection?.on(method: "TossChoiceSelected", callback: { (serverChoice: String) in
            DispatchQueue.main.async {
                self.initialServerChoice = serverChoice
                self.isTossActive = false
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
        mySlotIndex = 0
        
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
        mySlotIndex = 2
        
        connection?.invoke(method: "joinLobby", arguments: [code, guestName, guestPartnerName ?? "", guestProfileImageUrl ?? ""]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Lobiye katılamadı: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func joinLobbySlot(code: String, name: String, profileImageUrl: String?, requestedSlotIndex: Int = -1) {
        errorMessage = nil
        isMatchStarted = false
        remoteMatchState = nil
        mySlotIndex = (requestedSlotIndex >= 0 ? requestedSlotIndex : 2)
        
        connection?.invoke(method: "joinLobbySlot", arguments: [code, name, profileImageUrl ?? "", requestedSlotIndex]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Lobi slotuna katılamadı: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func switchSlot(code: String, targetSlotIndex: Int) {
        mySlotIndex = targetSlotIndex
        connection?.invoke(method: "switchSlot", arguments: [code, targetSlotIndex]) { error in
            if let error = error {
                print("Slot değiştirilemedi: \(error.localizedDescription)")
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
    
    func startToss(code: String) {
        connection?.invoke(method: "startToss", arguments: [code]) { error in
            if let error = error {
                print("Kura başlatılamadı: \(error.localizedDescription)")
            }
        }
    }
    
    func spinRacket(code: String) {
        connection?.invoke(method: "spinRacket", arguments: [code]) { error in
            if let error = error {
                print("Raket çevrilemedi: \(error.localizedDescription)")
            }
        }
    }
    
    func updateTossChoice(code: String, choice: String, startingServer: String) {
        connection?.invoke(method: "updateTossChoice", arguments: [code, choice, startingServer]) { error in
            if let error = error {
                print("Kura tercihi iletilemedi: \(error.localizedDescription)")
            }
        }
    }
    
    func selectTossChoice(code: String, startingServer: String) {
        connection?.invoke(method: "selectTossChoice", arguments: [code, startingServer]) { error in
            if let error = error {
                print("Kura seçimi iletilemedi: \(error.localizedDescription)")
            }
        }
    }
}
