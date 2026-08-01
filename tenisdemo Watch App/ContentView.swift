//
//  ContentView.swift
//  tenisdemo Watch App
//
//  Created by Murat Uçar on 19.07.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TennisMatchViewModel()
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    @State private var showSettings = false
    
    var body: some View {
        if !viewModel.hasMatchStarted && !connectivityManager.isCompanionActive {
            SetupMatchView(viewModel: viewModel)
        } else if viewModel.state.isMatchOver {
            MatchSummaryView(viewModel: viewModel)
        } else {
            VStack(spacing: 6) {
                // Üst Bar: Başlık ve Set Skorları
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(connectivityManager.isCompanionActive ? "CANLI" : "YEREL")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(connectivityManager.isCompanionActive ? Color(red: 0.1, green: 0.8, blue: 0.5) : .gray)
                        
                        Text("MAÇI")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Set Skorları
                    if !viewModel.state.setScores.isEmpty {
                        HStack(spacing: 3) {
                            ForEach(viewModel.state.setScores) { setScore in
                                Text("\(setScore.p1Games)-\(setScore.p2Games)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.12))
                                    .cornerRadius(4)
                                    .foregroundColor(.white)
                            }
                        }
                    } else {
                        Text("0-0")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(4)
                            .foregroundColor(.gray)
                    }
                    
                    if viewModel.state.isMatchTiebreak || viewModel.state.isTiebreak {
                        Text("TB")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal, 6)
                .frame(height: 24)
                
                // Oyuncu Kartları (Tıklanabilir Alanlar)
                VStack(spacing: 5) {
                    PlayerCard(
                        player: .player1,
                        name: viewModel.isDouble 
                            ? "\(viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name) & \(viewModel.player1PartnerName.isEmpty ? "ORTAK 1" : viewModel.player1PartnerName)" 
                            : (viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name),
                        points: viewModel.formatPoints(viewModel.state.p1Points, isTiebreak: viewModel.state.isTiebreak),
                        games: "\(viewModel.state.p1Games)",
                        sets: "\(viewModel.state.p1Sets)",
                        isServing: viewModel.state.server == .player1,
                        color: Color(red: 0.1, green: 0.8, blue: 0.5), // Emerald
                        isMatchOver: viewModel.state.isMatchOver,
                        onTap: {
                            if connectivityManager.isCompanionActive {
                                connectivityManager.sendScoreAction(for: .player1)
                            } else {
                                viewModel.scorePoint(for: .player1)
                            }
                        },
                        onLongPressServer: { viewModel.toggleStartingServer() }
                    )
                    
                    PlayerCard(
                        player: .player2,
                        name: viewModel.isDouble 
                            ? "\(viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name) & \(viewModel.player2PartnerName.isEmpty ? "ORTAK 2" : viewModel.player2PartnerName)" 
                            : (viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name),
                        points: viewModel.formatPoints(viewModel.state.p2Points, isTiebreak: viewModel.state.isTiebreak),
                        games: "\(viewModel.state.p2Games)",
                        sets: "\(viewModel.state.p2Sets)",
                        isServing: viewModel.state.server == .player2,
                        color: Color(red: 0.95, green: 0.45, blue: 0.15), // Orange
                        isMatchOver: viewModel.state.isMatchOver,
                        onTap: {
                            if connectivityManager.isCompanionActive {
                                connectivityManager.sendScoreAction(for: .player2)
                            } else {
                                viewModel.scorePoint(for: .player2)
                            }
                        },
                        onLongPressServer: { viewModel.toggleStartingServer() }
                    )
                }
                
                // Alt Kontrol Paneli (Geri Al / Ayarlar)
                HStack {
                    // Geri Al (Undo) Butonu
                    Button(action: {
                        if connectivityManager.isCompanionActive {
                            connectivityManager.sendUndoAction()
                        } else {
                            viewModel.undo()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 11, weight: .bold))
                            Text("Geri")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(8)
                    .disabled(connectivityManager.isCompanionActive ? !connectivityManager.canUndo : viewModel.history.isEmpty)
                    
                    Spacer()
                    
                    // Ayarlar Butonu
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 4)
                .frame(height: 24)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel, showSettings: $showSettings)
            }
            .onAppear {
                connectivityManager.setup(viewModel: viewModel)
            }
        }
    }
}

struct PlayerCard: View {
    let player: Player
    let name: String
    let points: String
    let games: String
    let sets: String
    let isServing: Bool
    let color: Color
    let isMatchOver: Bool
    let onTap: () -> Void
    let onLongPressServer: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                // Servisçi İkonu (Dokunulunca başlangıçta servis değiştirir)
                Button(action: onLongPressServer) {
                    ZStack {
                        Circle()
                            .fill(isServing ? Color(red: 0.86, green: 0.98, blue: 0.22) : Color.clear)
                            .frame(width: 18, height: 18)
                        
                        if isServing {
                            Image(systemName: "tennisball.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                        } else {
                            Image(systemName: "tennisball")
                                .font(.system(size: 10))
                                .foregroundColor(.gray.opacity(0.3))
                        }
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 22)
                
                // Oyuncu Adı ve Set Sayısı
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                    
                    HStack(spacing: 2) {
                        Text("Set:")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.gray)
                        Text(sets)
                            .font(.system(.caption2, design: .rounded))
                            .bold()
                            .foregroundColor(color)
                    }
                }
                
                Spacer()
                
                // Oyun ve Puan Skorları
                HStack(spacing: 8) {
                    VStack(spacing: 0) {
                        Text("Oyn")
                            .font(.system(size: 8, design: .rounded))
                            .foregroundColor(.gray)
                        Text(games)
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                    }
                    
                    Text(points)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(color)
                        .frame(width: 32, alignment: .trailing)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isServing ? color.opacity(0.5) : color.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isMatchOver)
    }
}

// Yeni Maç Kurulum Ekranı
struct SetupMatchView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("MAÇ AYARLARI")
                    .font(.system(.headline, design: .rounded))
                    .bold()
                    .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                    .padding(.top, 2)
                
                Divider()

                Toggle("Çiftler (Double)", isOn: $viewModel.isDouble)
                    .font(.system(.footnote, design: .rounded))
                    .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))

                VStack(spacing: 4) {
                    TextField("Oyuncu 1", text: $viewModel.player1Name)
                    if viewModel.isDouble {
                        TextField("Ortak 1", text: $viewModel.player1PartnerName)
                    }
                    TextField("Oyuncu 2", text: $viewModel.player2Name)
                    if viewModel.isDouble {
                        TextField("Ortak 2", text: $viewModel.player2PartnerName)
                    }
                }
                .font(.system(.footnote, design: .rounded))
                .padding(.vertical, 2)
                
                // Set kazanmak için oyun sayısı
                SegmentedSelector(
                    title: "Set Kazanmak İçin Game:",
                    options: [4, 6],
                    selection: $viewModel.gamesPerSet,
                    color: Color(red: 0.1, green: 0.8, blue: 0.5)
                )
                
                // Kazanılması gereken set sayısı
                SegmentedSelector(
                    title: "Kazanılması Gereken Set:",
                    options: [1, 2],
                    selection: $viewModel.setsToWin,
                    color: Color(red: 0.95, green: 0.45, blue: 0.15)
                )
                
                // 1-1 set beraberliğinde Tiebreak oynanacak mı (Match/Super Tiebreak)
                if viewModel.setsToWin > 1 {
                    Toggle(isOn: $viewModel.useMatchTiebreak) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Süper Tiebreak (10)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                            Text("1-1'de 3. set yerine oynanır")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))
                    .padding(.vertical, 2)
                }
                
                // Maçı Başlat Butonu
                Button(action: {
                    viewModel.startMatch()
                }) {
                    Text("Maçı Başlat")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
            }
            .padding(.horizontal, 4)
        }
    }
}

// Yatay Buton Seçici
struct SegmentedSelector: View {
    let title: String
    let options: [Int]
    @Binding var selection: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                        WKInterfaceDevice.current().play(.click)
                    }) {
                        Text("\(option)")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(selection == option ? .black : .white)
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .background(selection == option ? color : Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// Maç Sonu Genel Durum / Özet Ekranı
struct MatchSummaryView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Trophy veya Başarı İkonu
                VStack(spacing: 4) {
                    Image(systemName: viewModel.state.winner == .player1 ? "trophy.fill" : "hand.thumbsup.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.state.winner == .player1 ? Color(red: 0.86, green: 0.98, blue: 0.22) : .orange)
                    
                    Text(viewModel.state.winner == .player1 ? "MAÇI KAZANDINIZ!" : "RAKİP KAZANDI")
                        .font(.system(.headline, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.top, 4)
                
                Divider()
                
                // Set Skorları Listesi
                VStack(alignment: .leading, spacing: 6) {
                    Text("SET SKORLARI")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.gray)
                        .bold()
                    
                    ForEach(Array(viewModel.state.setScores.enumerated()), id: \.offset) { index, setScore in
                        HStack {
                            Text("\(index + 1). Set")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(setScore.p1Games) - \(setScore.p2Games)")
                                .font(.system(.body, design: .monospaced))
                                .bold()
                                .foregroundColor(setScore.p1Games > setScore.p2Games ? Color(red: 0.1, green: 0.8, blue: 0.5) : Color(red: 0.95, green: 0.45, blue: 0.15))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 4)
                
                // İstatistikler Özet
                VStack(alignment: .leading, spacing: 6) {
                    Text("İSTATİSTİKLER")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.gray)
                        .bold()
                    
                    let totalGamesP1 = viewModel.state.setScores.reduce(0) { $0 + $1.p1Games }
                    let totalGamesP2 = viewModel.state.setScores.reduce(0) { $0 + $1.p2Games }
                    
                    HStack {
                        Text("Toplam Game:")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Siz: \(totalGamesP1) / Rakip: \(totalGamesP2)")
                            .font(.system(.caption2, design: .rounded))
                            .bold()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(6)
                }
                .padding(.horizontal, 4)
                
                Divider()
                
                // Aksiyon Butonları
                VStack(spacing: 8) {
                    Button(action: {
                        if connectivityManager.isCompanionActive {
                            connectivityManager.sendResetAction()
                        } else {
                            viewModel.reset()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Aynı Kurallarla Yeniden Oyna")
                                .bold()
                        }
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        if connectivityManager.isCompanionActive {
                            connectivityManager.sendNewMatchAction()
                        } else {
                            viewModel.newMatch()
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Yeni Maç Kur")
                                .bold()
                        }
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    @Binding var showSettings: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Ayarlar")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .padding(.top, 2)
                
                Divider()
                
                // Aktif maç kuralları özeti
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aktif Maç Kuralları:")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("• Set limiti: \(viewModel.gamesPerSet) Game")
                        .font(.caption2)
                    Text("• Maç limiti: \(viewModel.setsToWin) Set")
                        .font(.caption2)
                    if viewModel.setsToWin > 1 {
                        Text("• Karar Seti: \(viewModel.useMatchTiebreak ? "Süper Tiebreak" : "Normal Set")")
                            .font(.caption2)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                Button(action: {
                    if WatchConnectivityManager.shared.isCompanionActive {
                        WatchConnectivityManager.shared.sendResetAction()
                    } else {
                        viewModel.reset()
                    }
                    showSettings = false
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Maçı Yenile")
                            .bold()
                    }
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.15))
                
                Button(action: {
                    if WatchConnectivityManager.shared.isCompanionActive {
                        WatchConnectivityManager.shared.sendNewMatchAction()
                    } else {
                        viewModel.newMatch()
                    }
                    showSettings = false
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Yeni Maç Kur")
                            .bold()
                    }
                    .foregroundColor(.yellow)
                }
                .buttonStyle(.bordered)
                .tint(.yellow.opacity(0.15))
                
                Button("Kapat") {
                    showSettings = false
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.15))
            }
            .padding(.bottom, 10)
        }
    }
}
