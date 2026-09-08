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
                VStack(spacing: 6) {
                    ProgressView()
                        .tint(.zinc400)
                    Text("Yükleniyor...")
                        .font(.system(size: 10))
                        .foregroundColor(.zinc400)
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.statusRed)
                        .font(.system(size: 18))
                    Text(errorMessage)
                        .font(.system(size: 10))
                        .foregroundColor(.zinc400)
                        .multilineTextAlignment(.center)
                    Button(action: {
                        Task {
                            await viewModel.loadMatches()
                        }
                    }) {
                        Text("Yeniden Dene")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.zinc950)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.zinc50)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                if viewModel.matches.isEmpty {
                    Text("Yaklaşan maç bulunamadı.")
                        .font(.system(size: 11))
                        .foregroundColor(.zinc500)
                } else {
                    List(viewModel.matches) { match in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(match.player1Name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.zinc100)
                                    .lineLimit(1)
                                
                                Text("vs")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.zinc500)
                                
                                Text(match.player2Name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.zinc100)
                                    .lineLimit(1)
                            }
                            
                            HStack {
                                Text(match.matchDate)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.zinc500)
                                
                                Spacer()
                                
                                if let score = match.score {
                                    Text(score)
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(match.isCompleted ? .courtGreen : .zinc100)
                                } else {
                                    HStack(spacing: 3) {
                                        Circle()
                                            .fill(match.isCompleted ? Color.courtGreen : Color.badgeAmber)
                                            .frame(width: 4, height: 4)
                                        Text(match.isCompleted ? "BİTTİ" : "BEKLİYOR")
                                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                                            .foregroundColor(match.isCompleted ? .courtGreen : .badgeAmber)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(
                            Color.white.opacity(0.04)
                        )
                    }
                }
            }
        }
        .navigationTitle("Fikstür")
        .task {
            await viewModel.loadMatches()
        }
    }
}
