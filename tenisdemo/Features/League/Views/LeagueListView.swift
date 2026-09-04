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
                        LazyVStack(spacing: 8) {
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
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        await viewModel.loadMatches()
                    }
                }
            }
            .navigationTitle("Fikstür")
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
        VStack(spacing: 10) {
            // Header: Date & Status Badge
            HStack {
                Text(match.matchDate)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.zinc500)
                
                Spacer()
                
                // Status Badge (Dense Minimal)
                HStack(spacing: 5) {
                    Circle()
                        .fill(match.isCompleted ? Color.statusGreen : Color.statusOrange)
                        .frame(width: 5, height: 5)
                    
                    Text(match.isCompleted ? "TAMAMLANDI" : "BEKLENİYOR")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(match.isCompleted ? .zinc300 : .zinc400)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.zinc850)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
            }
            
            Divider()
                .background(Color.zinc800)
            
            // Match Players & Score
            HStack(spacing: 8) {
                // Oyuncu 1
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.player1Name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.zinc100)
                        .lineLimit(1)
                    if match.isDouble, let partner = match.player1PartnerName {
                        Text("& \(partner)")
                            .font(.system(size: 11))
                            .foregroundColor(.zinc500)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Skor veya vs
                if let score = match.score {
                    Text(score)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc50)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.zinc850)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.zinc700, lineWidth: 1)
                        )
                } else {
                    Text("vs")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc600)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.zinc850)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                }
                
                // Oyuncu 2
                VStack(alignment: .trailing, spacing: 2) {
                    Text(match.player2Name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.zinc100)
                        .lineLimit(1)
                    if match.isDouble, let partner = match.player2PartnerName {
                        Text("& \(partner)")
                            .font(.system(size: 11))
                            .foregroundColor(.zinc500)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(12)
        .background(Color.zinc900)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.zinc800, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

struct LeagueListView_Previews: PreviewProvider {
    static var previews: some View {
        LeagueListView()
            .preferredColorScheme(.dark)
    }
}
