//
//  SettingsView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//  Refactored for Linear / Vercel Minimal Aesthetic
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header & Handle
                VStack(spacing: 10) {
                    Capsule()
                        .fill(Color.zinc700)
                        .frame(width: 32, height: 3)
                        .padding(.top, 10)
                    
                    Text("Maç Ayarları")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.zinc100)
                }
                
                Divider()
                    .background(Color.zinc800)
                
                // Aktif Kurallar Kartı
                VStack(alignment: .leading, spacing: 8) {
                    Text("AKTİF MAÇ KURALLARI")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.zinc500)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        RuleRow(label: "Set Başına Game", value: "\(viewModel.gamesPerSet) Game")
                        Divider().background(Color.zinc800)
                        RuleRow(label: "Kazanılması Gereken Set", value: "\(viewModel.setsToWin) Set")
                        if viewModel.setsToWin > 1 {
                            Divider().background(Color.zinc800)
                            RuleRow(
                                label: "Karar Seti Kuralı",
                                value: viewModel.useMatchTiebreak ? "Süper Tiebreak (10)" : "Standart Set"
                            )
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
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Aksiyon Butonları
                VStack(spacing: 8) {
                    // Mevcut Maçı Yenile
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            viewModel.reset()
                            showSettings = false
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12))
                            Text("Mevcut Maçı Yenile")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.zinc200)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.zinc900)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    
                    // Maçı İptal Et ve Yeni Kur
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            if let code = SignalRService.shared.lobbyState?.code {
                                SignalRService.shared.leaveLobby(code: code)
                            }
                            viewModel.newMatch()
                            showSettings = false
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                            Text("Maçı İptal Et & Yeni Kur")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.zinc950)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.zinc50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc300, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    
                    Button(action: {
                        showSettings = false
                    }) {
                        Text("Kapat")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc500)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

struct RuleRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.zinc400)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.zinc100)
        }
    }
}
