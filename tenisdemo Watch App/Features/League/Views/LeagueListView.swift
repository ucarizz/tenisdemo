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
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(match.player1Name)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.zinc100)
                                Spacer()
                                Text("vs")
                                    .font(.system(size: 9))
                                    .foregroundColor(.zinc500)
                                Spacer()
                                Text(match.player2Name)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.zinc100)
                            }
                            
                            HStack {
                                Text(match.matchDate)
                                    .font(.system(size: 9))
                                    .foregroundColor(.zinc500)
                                Spacer()
                                if let score = match.score {
                                    Text(score)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.zinc100)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.zinc900)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc800, lineWidth: 1)
                                )
                        )
                    }
                    .listStyle(.carousel)
                }
            }
        }
        .navigationTitle("Fikstür")
        .task {
            await viewModel.loadMatches()
        }
    }
}
