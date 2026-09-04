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
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Skor Takibi
            VStack {
                if !viewModel.hasMatchStarted && !connectivityManager.isCompanionActive {
                    SetupMatchView(viewModel: viewModel)
                } else if viewModel.state.isMatchOver {
                    MatchSummaryView(viewModel: viewModel)
                } else {
                    VStack(spacing: 5) {
                        // Üst Bar: Başlık ve Set Skorları
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(connectivityManager.isCompanionActive ? "CANLI" : "YEREL")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(connectivityManager.isCompanionActive ? .statusGreen : .zinc500)
                                
                                Text("MAÇI")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(.zinc500)
                            }
                            
                            Spacer()
                            
                            // Set Skorları
                            if !viewModel.state.setScores.isEmpty {
                                HStack(spacing: 3) {
                                    ForEach(viewModel.state.setScores) { setScore in
                                        Text("\(setScore.p1Games)-\(setScore.p2Games)")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color.zinc900)
                                            .cornerRadius(4)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(Color.zinc800, lineWidth: 1)
                                            )
                                            .foregroundColor(.zinc200)
                                    }
                                }
                            } else {
                                Text("0-0")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.zinc900)
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.zinc800, lineWidth: 1)
                                    )
                                    .foregroundColor(.zinc500)
                            }
                            
                            if viewModel.state.isMatchTiebreak || viewModel.state.isTiebreak {
                                Text("TB")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.zinc950)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.zinc50)
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 4)
                        .frame(height: 22)
                        
                        // Oyuncu Kartları veya Mola Ekranı
                        if viewModel.state.isGameBreak {
                            WatchGameBreakView(viewModel: viewModel, connectivityManager: connectivityManager)
                        } else {
                            VStack(spacing: 4) {
                                PlayerCard(
                                    player: .player1,
                                    name: viewModel.isDouble 
                                        ? "\(viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name) & \(viewModel.player1PartnerName.isEmpty ? "ORTAK 1" : viewModel.player1PartnerName)" 
                                        : (viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name),
                                    points: viewModel.formatPoints(viewModel.state.p1Points, isTiebreak: viewModel.state.isTiebreak),
                                    games: "\(viewModel.state.p1Games)",
                                    sets: "\(viewModel.state.p1Sets)",
                                    isServing: viewModel.state.server == .player1,
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
                        }
                        
                        // Alt Kontrol Paneli (Geri Al / Ayarlar)
                        HStack {
                            Button(action: {
                                if connectivityManager.isCompanionActive {
                                    connectivityManager.sendUndoAction()
                                } else {
                                    viewModel.undo()
                                }
                            }) {
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("Geri")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundColor(.zinc300)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.zinc900)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            .disabled(connectivityManager.isCompanionActive ? !connectivityManager.canUndo : viewModel.history.isEmpty)
                            .opacity((connectivityManager.isCompanionActive ? !connectivityManager.canUndo : viewModel.history.isEmpty) ? 0.4 : 1.0)
                            
                            Spacer()
                            
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.zinc400)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.zinc900)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 2)
                        .frame(height: 22)
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 2)
                }
            }
            .tag(0)
            
            // Tab 2: Vuruş Hızı Takibi
            SwingTrackerView()
                .tag(1)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel, showSettings: $showSettings)
        }
        .onAppear {
            connectivityManager.setup(viewModel: viewModel)
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
    let isMatchOver: Bool
    let onTap: () -> Void
    let onLongPressServer: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                // Servisçi İkonu
                Button(action: onLongPressServer) {
                    ZStack {
                        Circle()
                            .fill(isServing ? Color.zinc50 : Color.clear)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(isServing ? Color.clear : Color.zinc700, lineWidth: 1)
                            )
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 14)
                
                // Oyuncu Adı ve Set Sayısı
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.zinc100)
                        .lineLimit(1)
                    
                    HStack(spacing: 2) {
                        Text("Set:")
                            .font(.system(size: 9))
                            .foregroundColor(.zinc500)
                        Text(sets)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc300)
                    }
                }
                
                Spacer()
                
                // Oyun ve Puan Skorları
                HStack(spacing: 8) {
                    VStack(spacing: 0) {
                        Text("Oyn")
                            .font(.system(size: 7))
                            .foregroundColor(.zinc500)
                        Text(games)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc200)
                    }
                    
                    Text(points)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc50)
                        .frame(width: 32, alignment: .trailing)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isServing ? Color.zinc850 : Color.zinc900)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isServing ? Color.zinc700 : Color.zinc800, lineWidth: 1)
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
            VStack(spacing: 8) {
                Text("MAÇ KURULUMU")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.zinc400)
                    .padding(.top, 2)
                
                Divider()
                    .background(Color.zinc800)

                Toggle("Çiftler", isOn: $viewModel.isDouble)
                    .font(.system(size: 11))
                    .foregroundColor(.zinc300)

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
                .font(.system(size: 11))
                .foregroundColor(.zinc100)
                .padding(.vertical, 2)
                
                // Set kazanmak için oyun sayısı
                SegmentedSelector(
                    title: "Set İçin Game:",
                    options: [4, 6],
                    selection: $viewModel.gamesPerSet
                )
                
                // Kazanılması gereken set sayısı
                SegmentedSelector(
                    title: "Kazanılacak Set:",
                    options: [1, 2],
                    selection: $viewModel.setsToWin
                )
                
                if viewModel.setsToWin > 1 {
                    Toggle(isOn: $viewModel.useMatchTiebreak) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Süper Tiebreak")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.zinc200)
                            Text("1-1'de 10 puan")
                                .font(.system(size: 8))
                                .foregroundColor(.zinc500)
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                // Maçı Başlat Butonu
                Button(action: {
                    viewModel.startMatch()
                }) {
                    Text("Maçı Başlat")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.zinc950)
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(Color.zinc50)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.zinc500)
            
            HStack(spacing: 6) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                        WKInterfaceDevice.current().play(.click)
                    }) {
                        Text("\(option)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(selection == option ? .zinc950 : .zinc300)
                            .frame(maxWidth: .infinity, minHeight: 26)
                            .background(selection == option ? Color.zinc50 : Color.zinc900)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(selection == option ? Color.clear : Color.zinc800, lineWidth: 1)
                            )
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
            VStack(spacing: 8) {
                // Sonuç Başlığı
                VStack(spacing: 2) {
                    Text(viewModel.state.winner == .player1 ? "MAÇI KAZANDINIZ" : "RAKİP KAZANDI")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.zinc50)
                }
                .padding(.top, 4)
                
                Divider()
                    .background(Color.zinc800)
                
                // Set Skorları Listesi
                VStack(alignment: .leading, spacing: 4) {
                    Text("SET SKORLARI")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.zinc500)
                    
                    ForEach(Array(viewModel.state.setScores.enumerated()), id: \.offset) { index, setScore in
                        HStack {
                            Text("\(index + 1). Set")
                                .font(.system(size: 10))
                                .foregroundColor(.zinc400)
                            Spacer()
                            Text("\(setScore.p1Games) - \(setScore.p2Games)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc100)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.zinc900)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 2)
                
                // İstatistikler Özet
                VStack(alignment: .leading, spacing: 4) {
                    Text("İSTATİSTİKLER")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.zinc500)
                    
                    let totalGamesP1 = viewModel.state.setScores.reduce(0) { $0 + $1.p1Games }
                    let totalGamesP2 = viewModel.state.setScores.reduce(0) { $0 + $1.p2Games }
                    
                    HStack {
                        Text("Toplam Game:")
                            .font(.system(size: 9))
                            .foregroundColor(.zinc400)
                        Spacer()
                        Text("Siz: \(totalGamesP1) / Rakip: \(totalGamesP2)")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundColor(.zinc200)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.zinc900)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 2)
                
                Divider()
                    .background(Color.zinc800)
                
                // Aksiyon Butonları
                VStack(spacing: 6) {
                    Button(action: {
                        if connectivityManager.isCompanionActive {
                            connectivityManager.sendResetAction()
                        } else {
                            viewModel.reset()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10, weight: .bold))
                            Text("Yeniden Oyna")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.zinc950)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.zinc50)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        if connectivityManager.isCompanionActive {
                            connectivityManager.sendNewMatchAction()
                        } else {
                            viewModel.newMatch()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                            Text("Yeni Maç Kur")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.zinc300)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.zinc900)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    @Binding var showSettings: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Ayarlar")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.zinc50)
                    .padding(.top, 2)
                
                Divider()
                    .background(Color.zinc800)
                
                // Aktif maç kuralları özeti
                VStack(alignment: .leading, spacing: 3) {
                    Text("Aktif Maç Kuralları:")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.zinc500)
                    Text("• Set limiti: \(viewModel.gamesPerSet) Game")
                        .font(.system(size: 9))
                        .foregroundColor(.zinc300)
                    Text("• Maç limiti: \(viewModel.setsToWin) Set")
                        .font(.system(size: 9))
                        .foregroundColor(.zinc300)
                    if viewModel.setsToWin > 1 {
                        Text("• Karar Seti: \(viewModel.useMatchTiebreak ? "Süper Tiebreak" : "Normal Set")")
                            .font(.system(size: 9))
                            .foregroundColor(.zinc300)
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.zinc900)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
                
                Button(action: {
                    if WatchConnectivityManager.shared.isCompanionActive {
                        WatchConnectivityManager.shared.sendResetAction()
                    } else {
                        viewModel.reset()
                    }
                    showSettings = false
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("Maçı Sıfırla")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.zinc200)
                    .frame(maxWidth: .infinity, minHeight: 28)
                    .background(Color.zinc900)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if WatchConnectivityManager.shared.isCompanionActive {
                        WatchConnectivityManager.shared.sendNewMatchAction()
                    } else {
                        viewModel.newMatch()
                    }
                    showSettings = false
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Yeni Maç")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.zinc950)
                    .frame(maxWidth: .infinity, minHeight: 28)
                    .background(Color.zinc50)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                Button("Kapat") {
                    showSettings = false
                }
                .font(.system(size: 11))
                .foregroundColor(.zinc400)
                .padding(.top, 2)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
    }
}

struct WatchGameBreakView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    @ObservedObject var connectivityManager: WatchConnectivityManager
    
    var winnerName: String {
        guard let winner = viewModel.state.lastGameWinner else { return "OYUN BİTTİ" }
        if winner == .player1 {
            return viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name
        } else {
            return viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name
        }
    }
    
    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.zinc400)
                    .font(.system(size: 9))
                Text("SU MOLASI")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.zinc400)
            }
            
            Text("Game: \(winnerName)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.zinc100)
                .lineLimit(1)
            
            Text("Skor: \(viewModel.state.p1Games) - \(viewModel.state.p2Games)")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.zinc50)
            
            Button(action: {
                if connectivityManager.isCompanionActive {
                    connectivityManager.sendStartNextGameAction()
                } else {
                    viewModel.startNextGame()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                    Text("Yeni Game")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.zinc950)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(Color.zinc50)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(.vertical, 2)
    }
}
