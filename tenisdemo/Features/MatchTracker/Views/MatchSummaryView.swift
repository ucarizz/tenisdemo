//
//  MatchSummaryView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import SwiftUI

struct MatchSummaryView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Başarı Görseli
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(viewModel.state.winner == .player1 ? Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.15) : Color.orange.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: viewModel.state.winner == .player1 ? "trophy.fill" : "hand.thumbsup.fill")
                        .font(.system(size: 48))
                        .foregroundColor(viewModel.state.winner == .player1 ? Color(red: 0.86, green: 0.98, blue: 0.22) : .orange)
                }
                
                Text(viewModel.state.winner == .player1 ? "MAÇI KAZANDINIZ!" : "RAKİP KAZANDI")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .tracking(1)
            }
            .padding(.top)
            
            // Set Skor Kartı
            VStack(alignment: .leading, spacing: 16) {
                Text("SET SKORLARI")
                    .font(.system(.caption, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.state.setScores.enumerated()), id: \.offset) { index, setScore in
                        HStack {
                            Text("\(index + 1). Set")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Text("\(setScore.p1Games)")
                                    .font(.system(.title3, design: .monospaced))
                                    .bold()
                                    .foregroundColor(setScore.p1Games > setScore.p2Games ? Color.emerald : .white)
                                
                                Text("-")
                                    .font(.system(.title3, design: .rounded))
                                    .foregroundColor(.gray)
                                
                                Text("\(setScore.p2Games)")
                                    .font(.system(.title3, design: .monospaced))
                                    .bold()
                                    .foregroundColor(setScore.p2Games > setScore.p1Games ? Color.orange : .white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            // İstatistik Kartı
            VStack(alignment: .leading, spacing: 12) {
                Text("İSTATİSTİKLER")
                    .font(.system(.caption, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                
                let totalGamesP1 = viewModel.state.setScores.reduce(0) { $0 + $1.p1Games }
                let totalGamesP2 = viewModel.state.setScores.reduce(0) { $0 + $1.p2Games }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Toplam Alınan Game")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                        Text("Siz: \(totalGamesP1)  /  Rakip: \(totalGamesP2)")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Aksiyon Butonları
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.reset()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Aynı Kurallarla Yeniden Oyna")
                    }
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                    .cornerRadius(14)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.newMatch()
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Yeni Maç Kur")
                    }
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
