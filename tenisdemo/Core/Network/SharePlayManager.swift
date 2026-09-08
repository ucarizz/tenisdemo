import Foundation
import Combine
import GroupActivities

// CourtMate SharePlay Aktivitesi (Telefonlar yaklaştırıldığında veya SharePlay başlatıldığında paylaşılır)
struct TennisLobbyActivity: GroupActivity {
    let lobbyCode: String
    let hostName: String
    let isDouble: Bool
    
    static let activityIdentifier = "com.tenisdemo.courtmate.lobby"
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "\(hostName) ile Tenis Lobisi"
        metadata.subtitle = isDouble ? "Çiftler Maçı (4 Kişi)" : "Tekler Maçı (2 Kişi)"
        metadata.type = .generic
        return metadata
    }
}

// SharePlay oturumu üzerinden katılımcılara iletilen mesaj paketi
struct LobbySharePayload: Codable {
    let lobbyCode: String
    let hostName: String
    let isDouble: Bool
}

@MainActor
class SharePlayManager: ObservableObject {
    static let shared = SharePlayManager()
    
    @Published var groupSession: GroupSession<TennisLobbyActivity>?
    @Published var messenger: GroupSessionMessenger?
    @Published var receivedLobbyCode: String?
    @Published var isProximityActive: Bool = false
    @Published var activeParticipantsCount: Int = 0
    
    private var tasks = Set<Task<Void, Never>>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        startListeningForSessions()
    }
    
    // Arka planda gelen SharePlay / Proximity oturumlarını dinler
    func startListeningForSessions() {
        let task = Task {
            for await session in TennisLobbyActivity.sessions() {
                self.configureGroupSession(session)
            }
        }
        tasks.insert(task)
    }
    
    // Lobi kurucusu veya katılımcısı SharePlay aktivitesini başlatır (Yakınlaşmaya hazır hale getirir)
    func startSharing(lobbyCode: String, hostName: String, isDouble: Bool) {
        let activity = TennisLobbyActivity(lobbyCode: lobbyCode, hostName: hostName, isDouble: isDouble)
        
        Task {
            do {
                _ = try await activity.activate()
                self.isProximityActive = true
            } catch {
                print("[SharePlay] Aktivite etkinleştirilemedi: \(error.localizedDescription)")
            }
        }
    }
    
    // Yeni bir oturum bağlandığında yapılandır
    private func configureGroupSession(_ session: GroupSession<TennisLobbyActivity>) {
        self.groupSession = session
        let messenger = GroupSessionMessenger(session: session)
        self.messenger = messenger
        
        self.receivedLobbyCode = session.activity.lobbyCode
        self.isProximityActive = true
        
        session.$activeParticipants
            .sink { [weak self] participants in
                DispatchQueue.main.async {
                    self?.activeParticipantsCount = participants.count
                }
            }
            .store(in: &subscriptions)
            
        session.$state
            .sink { [weak self] state in
                DispatchQueue.main.async {
                    if case .invalidated = state {
                        self?.leaveSession()
                    }
                }
            }
            .store(in: &subscriptions)
            
        // Gelen mesajları dinle
        let task = Task {
            for await (message, _) in messenger.messages(of: LobbySharePayload.self) {
                DispatchQueue.main.async {
                    self.receivedLobbyCode = message.lobbyCode
                }
            }
        }
        tasks.insert(task)
        
        session.join()
    }
    
    // Oturumdan güvenli ayrıl
    func leaveSession() {
        groupSession?.leave()
        groupSession = nil
        messenger = nil
        isProximityActive = false
        receivedLobbyCode = nil
        subscriptions.removeAll()
    }
}
