//
//  SettingsView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack {
            // Arka Plan
            Color(red: 0.08, green: 0.09, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Başlık
                VStack(spacing: 4) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 4)
                        .padding(.top, 8)
                    
                    Text("Maç Ayarları")
                        .font(.system(.headline, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Aktif Kurallar Kartı
                VStack(alignment: .leading, spacing: 12) {
                    Text("AKTİF MAÇ KURALLARI")
                        .font(.system(.caption, design: .rounded))
                        .bold()
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RuleRow(icon: "tennisball.fill", label: "Set Kazanmak İçin Game", value: "\(viewModel.gamesPerSet) Game")
                        RuleRow(icon: "number", label: "Kazanılması Gereken Set", value: "\(viewModel.setsToWin) Set")
                        if viewModel.setsToWin > 1 {
                            RuleRow(
                                icon: "arrow.triangle.merge",
                                label: "Karar Seti",
                                value: viewModel.useMatchTiebreak ? "Süper Tiebreak" : "Normal Set"
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Aksiyon Listesi
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.reset()
                            showSettings = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Mevcut Maçı Yenile")
                        }
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.newMatch()
                            showSettings = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("Maçı İptal Et ve Yeni Kur")
                        }
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showSettings = false
                    }) {
                        Text("Kapat")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }
}

struct RuleRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                .frame(width: 20)
            
            Text(label)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(.body, design: .rounded))
                .bold()
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
