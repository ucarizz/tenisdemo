//
//  LeagueListView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import SwiftUI

struct LeagueListView: View {
    @StateObject private var viewModel = LeagueViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium Koyu Arka Plan
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.12), Color(red: 0.03, green: 0.04, blue: 0.06)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.matches.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(Color(red: 0.86, green: 0.98, blue: 0.22))
                            .scaleEffect(1.2)
                        Text("Maçlar yükleniyor...")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.gray)
                    }
                } else if let errorMessage = viewModel.errorMessage, viewModel.matches.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button(action: {
                            Task {
                                await viewModel.loadMatches()
                            }
                        }) {
                            Text("Yeniden Dene")
                                .font(.system(.subheadline, design: .rounded))
                                .bold()
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                                .cornerRadius(8)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if viewModel.matches.isEmpty {
                                Text("Yaklaşan maç bulunamadı.")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.gray)
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
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .refreshable {
                        await viewModel.loadMatches()
                    }
                }
            }
            .navigationTitle("Lig Fikstürü")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
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
            HStack {
                // Tarih / Saat Bilgisi
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                    Text(match.matchDate)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                // Durum Rozeti
                Text(match.isCompleted ? "TAMAMLANDI" : "BEKLENİYOR")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(match.isCompleted ? Color.emerald.opacity(0.15) : Color.orange.opacity(0.15))
                    .foregroundColor(match.isCompleted ? Color.emerald : Color.orange)
                    .cornerRadius(4)
            }
            
            HStack(spacing: 12) {
                // Oyuncu 1
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.player1Name)
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text("Oyuncu 1")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // VS İkonu veya Skor
                if let score = match.score {
                    Text(score)
                        .font(.system(.body, design: .monospaced))
                        .bold()
                        .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                } else {
                    Text("VS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                        .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                        .clipShape(Circle())
                }
                
                // Oyuncu 2
                VStack(alignment: .trailing, spacing: 4) {
                    Text(match.player2Name)
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text("Oyuncu 2")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// Zümrüt Yeşili Yardımcı Renk Tanımı
extension Color {
    static let emerald = Color(red: 0.1, green: 0.8, blue: 0.5)
}

struct LeagueListView_Previews: PreviewProvider {
    static var previews: some View {
        LeagueListView()
            .preferredColorScheme(.dark)
    }
}
