//
//  SetupMatchView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import SwiftUI

struct SetupMatchView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 16)
                    
                    // Logo / Başlık
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "tennisball.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                        }
                        
                        Text("MAÇ AYARLARI")
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                            .tracking(2)
                    }
                    .padding(.bottom, 8)
                    
                    // Ayarlar Kutusu
                    VStack(spacing: 20) {
                        // Maç Modu (Tekler / Çiftler)
                        Toggle(isOn: $viewModel.isDouble) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Çiftler Maçı (Double)")
                                    .font(.system(.body, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                Text("4 oyuncu ile oynanır")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))
                        .padding(.horizontal, 4)
                        
                        // Oyuncu İsimleri
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(viewModel.isDouble ? "1. Takım - 1. Oyuncu (Siz)" : "Oyuncu 1 Adı (Siz)")
                                    .font(.system(.caption, design: .rounded))
                                    .bold()
                                    .foregroundColor(.gray)
                                TextField("SİZ", text: $viewModel.player1Name)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                                    .textInputAutocapitalization(.characters)
                            }
                            
                            if viewModel.isDouble {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("1. Takım - 2. Oyuncu (Ortak)")
                                        .font(.system(.caption, design: .rounded))
                                        .bold()
                                        .foregroundColor(.gray)
                                    TextField("EŞ 1", text: $viewModel.player1PartnerName)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                        .textInputAutocapitalization(.characters)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(viewModel.isDouble ? "2. Takım - 1. Oyuncu (Rakip)" : "Oyuncu 2 Adı (Rakip)")
                                    .font(.system(.caption, design: .rounded))
                                    .bold()
                                    .foregroundColor(.gray)
                                TextField("RAKİP", text: $viewModel.player2Name)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                                    .textInputAutocapitalization(.characters)
                            }
                            
                            if viewModel.isDouble {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("2. Takım - 2. Oyuncu (Eş)")
                                        .font(.system(.caption, design: .rounded))
                                        .bold()
                                        .foregroundColor(.gray)
                                    TextField("EŞ 2", text: $viewModel.player2PartnerName)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                        .textInputAutocapitalization(.characters)
                                }
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // Set kazanmak için oyun sayısı
                        CustomSegmentedSelector(
                            title: "Set Kazanmak İçin Game Sayısı",
                            options: [4, 6],
                            selection: $viewModel.gamesPerSet,
                            color: Color.emerald
                        )
                        
                        // Kazanılması gereken set sayısı
                        CustomSegmentedSelector(
                            title: "Kazanılması Gereken Set Sayısı",
                            options: [1, 2],
                            selection: $viewModel.setsToWin,
                            color: Color(red: 0.95, green: 0.45, blue: 0.15)
                        )
                        
                        // 1-1 set beraberliğinde Tiebreak oynanacak mı (Match/Super Tiebreak)
                        if viewModel.setsToWin > 1 {
                            Toggle(isOn: $viewModel.useMatchTiebreak) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Süper Tiebreak (10 Puan)")
                                        .font(.system(.body, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                    Text("1-1 beraberlikte 3. set yerine oynanır")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))
                            .padding()
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 24)
                }
            }
            
            // Maçı Başlat Butonu (Sabit Alt Kısım)
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.startMatch()
                }
            }) {
                HStack {
                    Text("Maçı Başlat")
                        .font(.system(.body, design: .rounded))
                        .bold()
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                .cornerRadius(16)
                .shadow(color: Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(Color.black.edgesIgnoringSafeArea(.bottom))
        }
    }
    }


struct CustomSegmentedSelector: View {
    let title: String
    let options: [Int]
    @Binding var selection: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .bold()
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
            
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.interactiveSpring()) {
                            selection = option
                        }
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                        Text("\(option)")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(selection == option ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(selection == option ? color : Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selection == option ? color : Color.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
