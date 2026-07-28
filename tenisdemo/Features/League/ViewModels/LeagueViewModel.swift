//
//  LeagueViewModel.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import Foundation

@MainActor
class LeagueViewModel: ObservableObject {
    @Published var matches: [LeagueMatch] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let service: LeagueServiceProtocol
    
    init(service: LeagueServiceProtocol = LeagueService()) {
        self.service = service
    }
    
    func loadMatches() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.matches = try await service.fetchMatches()
        } catch {
            self.errorMessage = error.localizedDescription
            
            // Prototipleme/Mock Veri: Eğer gerçek API kapalıysa veya hata verirse
            // kullanıcıya boş ekran göstermek yerine şık bir arayüz sunmak için mock veriler ekleyelim.
            #if DEBUG
            loadMockMatches()
            #endif
        }
        
        isLoading = false
    }
    
    private func loadMockMatches() {
        self.matches = [
            LeagueMatch(id: 1, player1Name: "Murat Uçar", player2Name: "Ahmet Yılmaz", matchDate: "23.07.2026 - 19:30", score: "6-4, 4-6, 10-8", isCompleted: true),
            LeagueMatch(id: 2, player1Name: "Mehmet Demir", player2Name: "Burak Kaya", matchDate: "24.07.2026 - 18:00", score: nil, isCompleted: false),
            LeagueMatch(id: 3, player1Name: "Can Özkan", player2Name: "Murat Uçar", matchDate: "26.07.2026 - 20:00", score: nil, isCompleted: false),
            LeagueMatch(id: 4, player1Name: "Hakan Şahin", player2Name: "Ali Yıldız", matchDate: "27.07.2026 - 21:15", score: "6-3, 6-2", isCompleted: true),
            LeagueMatch(id: 5, player1Name: "Selim Avcı", player2Name: "Deniz Yılmaz", matchDate: "29.07.2026 - 17:30", score: nil, isCompleted: false)
        ]
        self.errorMessage = nil // Mock veri yüklendiği için hatayı gizle
    }
}
