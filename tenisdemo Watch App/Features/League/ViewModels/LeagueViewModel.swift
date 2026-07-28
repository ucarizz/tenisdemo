//
//  LeagueViewModel.swift
//  tenisdemo Watch App
//
//  Created by Antigravity on 19.07.2026.
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
        }
        
        isLoading = false
    }
}
