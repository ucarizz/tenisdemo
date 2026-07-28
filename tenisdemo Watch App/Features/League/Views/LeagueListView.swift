//
//  LeagueListView.swift
//  tenisdemo Watch App
//
//  Created by Antigravity on 19.07.2026.
//

import SwiftUI

struct LeagueListView: View {
    @StateObject private var viewModel = LeagueViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Maçlar Yükleniyor...")
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text(errorMessage)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                    Button("Yeniden Dene") {
                        Task {
                            await viewModel.loadMatches()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                if viewModel.matches.isEmpty {
                    Text("Yaklaşan maç bulunamadı.")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.matches) { match in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(match.player1Name)
                                    .font(.body)
                                    .bold()
                                Spacer()
                                Text("vs")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(match.player2Name)
                                    .font(.body)
                                    .bold()
                            }
                            
                            HStack {
                                Text(match.matchDate)
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Spacer()
                                if let score = match.score {
                                    Text(score)
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Lig Fikstürü")
        .task {
            // Görünüm yüklendiğinde otomatik olarak API'den veri çeker
            await viewModel.loadMatches()
        }
    }
}
