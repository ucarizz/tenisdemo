//
//  LeagueListView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//  Refactored for Linear / Vercel Minimal Aesthetic
//

import SwiftUI

struct LeagueListView: View {
    @StateObject private var viewModel = LeagueViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.zinc950.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.matches.isEmpty {
                    VStack(spacing: 8) {
                        ProgressView()
                            .tint(.zinc400)
                        Text("Yükleniyor...")
                            .font(.system(size: 13))
                            .foregroundColor(.zinc500)
                    }
                } else if let errorMessage = viewModel.errorMessage, viewModel.matches.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.zinc500)
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.zinc400)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button(action: {
                            Task {
                                await viewModel.loadMatches()
                            }
                        }) {
                            Text("Yeniden Dene")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.zinc950)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.zinc50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc300, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if viewModel.matches.isEmpty {
                                Text("Kayıtlı maç bulunamadı.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.zinc500)
                                    .padding(.top, 40)
                            } else {
                                ForEach(viewModel.matches) { match in
                                    NavigationLink(destination: LeagueMatchDetailView(match: match)) {
                                        LeagueMatchRow(match: match)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(height: 1)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        await viewModel.loadMatches()
                    }
                }
            }
            .navigationTitle("Fikstür Bülteni")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.zinc950, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadMatches()
            }
        }
    }
}

struct LeagueMatchRow: View {
    let match: LeagueMatch
    
    var body: some View {
        VStack(spacing: 12) {
            // Header: Date, Format, Status (Single Dot)
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(match.isCompleted ? Color.courtGreen : Color.badgeAmber)
                        .frame(width: 6, height: 6)
                    
                    Text(match.isCompleted ? "TAMAMLANDI" : "BEKLENİYOR")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(match.isCompleted ? .courtGreen : .badgeAmber)
                }
                
                Text("•")
                    .foregroundColor(.zinc600)
                    .font(.system(size: 10))
                
                Text(match.isDouble ? "ÇİFTLER" : "TEKLER")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.0)
                    .foregroundColor(.zinc400)
                
                Spacer()
                
                Text(match.matchDate)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.zinc500)
            }
            
            // Match Players & Score
            HStack(spacing: 16) {
                // Oyuncu 1
                VStack(alignment: .leading, spacing: 3) {
                    Text(match.player1Name.uppercased())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if match.isDouble, let partner = match.player1PartnerName {
                        Text("& \(partner.uppercased())")
                            .font(.system(size: 11))
                            .foregroundColor(.zinc500)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Skor veya vs (Editorial)
                if let score = match.score, !score.isEmpty {
                    Text(score)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(match.isCompleted ? .courtGreen : .white)
                } else {
                    Text("VS")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.zinc600)
                }
                
                // Oyuncu 2
                VStack(alignment: .trailing, spacing: 3) {
                    Text(match.player2Name.uppercased())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if match.isDouble, let partner = match.player2PartnerName {
                        Text("& \(partner.uppercased())")
                            .font(.system(size: 11))
                            .foregroundColor(.zinc500)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

struct LeagueListView_Previews: PreviewProvider {
    static var previews: some View {
        LeagueListView()
            .preferredColorScheme(.dark)
    }
}
