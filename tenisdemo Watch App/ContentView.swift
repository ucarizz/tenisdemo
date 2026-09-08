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
                    VStack(spacing: 4) {
                        // Üst Bar: Başlık ve Set Skorları
                        HStack {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(connectivityManager.isCompanionActive ? Color.tennisVolt : Color.zinc500)
                                    .frame(width: 5, height: 5)
                                Text(connectivityManager.isCompanionActive ? "CANLI" : "YEREL")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(connectivityManager.isCompanionActive ? .tennisVolt : .zinc400)
                                    .tracking(0.5)
                            }
                            
                            Spacer()
                            
                            // Set Skorları
                            if !viewModel.state.setScores.isEmpty {
                                HStack(spacing: 6) {
                                    ForEach(viewModel.state.setScores) { setScore in
                                        Text("\(setScore.p1Games)-\(setScore.p2Games)")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(setScore.p1Games > setScore.p2Games ? .courtGreen : .zinc200)
                                    }
                                }
                            } else {
                                Text("0-0")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.zinc500)
                            }
                            
                            if viewModel.state.isMatchTiebreak || viewModel.state.isTiebreak {
                                Text("TB")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.tennisVolt)
                                    .padding(.leading, 2)
                            }
                        }
                        .padding(.horizontal, 4)
                        .frame(height: 18)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                        
                        // Oyuncu Satırları veya Mola Ekranı
                        if viewModel.state.isGameBreak {
                            WatchGameBreakView(viewModel: viewModel, connectivityManager: connectivityManager)
                        } else {
                            VStack(spacing: 0) {
                                WatchEditorialPlayerRow(
                                    name: viewModel.isDouble 
                                        ? "\(viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name) & \(viewModel.player1PartnerName.isEmpty ? "P1" : viewModel.player1PartnerName)" 
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
                                    onToggleServer: { viewModel.toggleStartingServer() }
                                )
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(height: 1)
                                
                                WatchEditorialPlayerRow(
                                    name: viewModel.isDouble 
                                        ? "\(viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name) & \(viewModel.player2PartnerName.isEmpty ? "P2" : viewModel.player2PartnerName)" 
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
                                    onToggleServer: { viewModel.toggleStartingServer() }
                                )
                            }
                        }
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                        
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
                                        .font(.system(size: 9, weight: .bold))
                                    Text("GERİ")
                                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(.zinc400)
                            }
                            .buttonStyle(.plain)
                            .disabled(connectivityManager.isCompanionActive ? !connectivityManager.canUndo : viewModel.history.isEmpty)
                            .opacity((connectivityManager.isCompanionActive ? !connectivityManager.canUndo : viewModel.history.isEmpty) ? 0.3 : 1.0)
                            
                            Spacer()
                            
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 11))
                                    .foregroundColor(.zinc500)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 6)
                        .padding(.top, 1)
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
            if (viewModel.hasMatchStarted || connectivityManager.isCompanionActive) && !viewModel.state.isMatchOver {
                viewModel.startRuntimeSession()
            }
        }
        .onChange(of: viewModel.hasMatchStarted) { started in
            if started && !viewModel.state.isMatchOver {
                viewModel.startRuntimeSession()
            } else if !started && !connectivityManager.isCompanionActive {
                viewModel.stopRuntimeSession()
            }
        }
        .onChange(of: connectivityManager.isCompanionActive) { active in
            if active && !viewModel.state.isMatchOver {
                viewModel.startRuntimeSession()
            } else if !active && !viewModel.hasMatchStarted {
                viewModel.stopRuntimeSession()
            }
        }
        .onChange(of: viewModel.state.isMatchOver) { isOver in
            if isOver {
                viewModel.stopRuntimeSession()
            }
        }
    }
}

// MARK: - Watch Editorial Scoreboard Row (Cardless & Hero Scores)
struct WatchEditorialPlayerRow: View {
    let name: String
    let points: String
    let games: String
    let sets: String
    let isServing: Bool
    let isMatchOver: Bool
    let onTap: () -> Void
    let onToggleServer: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            // Servis Noktası (Tek Tenis Volt Nokta - Bağımsız Tıklanabilir)
            Button(action: onToggleServer) {
                Circle()
                    .fill(isServing ? Color.tennisVolt : Color.clear)
                    .frame(width: 8, height: 8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(width: 14, height: 36)
            
            // Skor Alanı ve Oyuncu Bilgisi (Puan Ekleme)
            Button(action: onTap) {
                HStack(alignment: .center, spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.zinc100)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text("S:\(sets)")
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(.zinc500)
                            Text("G:\(games)")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc300)
                        }
                    }
                    
                    Spacer()
                    
                    // Hero Skor (Büyük Tabular Monospaced Rakamlar)
                    Text(points)
                        .font(.system(size: 34, weight: .bold, design: .monospaced))
                        .foregroundColor(isServing ? .tennisVolt : .zinc50)
                        .frame(minWidth: 42, alignment: .trailing)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isMatchOver)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 5)
    }
}

// Yeni Maç Kurulum Ekranı
struct SetupMatchView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("MAÇ KURULUMU")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.zinc400)
                    .tracking(1.0)
                    .padding(.top, 2)
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)

                Toggle("Çiftler", isOn: $viewModel.isDouble)
                    .font(.system(size: 11, weight: .medium))
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
                
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                
                // Set kazanmak için oyun sayısı
                SegmentedSelector(
                    title: "SET İÇİN GAME:",
                    options: [4, 6],
                    selection: $viewModel.gamesPerSet
                )
                
                // Kazanılması gereken set sayısı
                SegmentedSelector(
                    title: "KAZANILACAK SET:",
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
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                
                // Maçı Başlat Butonu
                Button(action: {
                    viewModel.startMatch()
                }) {
                    Text("MAÇI BAŞLAT")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .tracking(0.5)
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(Color.tennisVolt)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(.horizontal, 4)
        }
    }
}

// Yatay Buton Seçici (Editorial)
struct SegmentedSelector: View {
    let title: String
    let options: [Int]
    @Binding var selection: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.zinc500)
                .tracking(0.5)
            
            HStack(spacing: 6) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                        WKInterfaceDevice.current().play(.click)
                    }) {
                        HStack(spacing: 4) {
                            if selection == option {
                                Circle()
                                    .fill(Color.tennisVolt)
                                    .frame(width: 4, height: 4)
                            }
                            Text("\(option)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(selection == option ? .zinc50 : .zinc400)
                        }
                        .frame(maxWidth: .infinity, minHeight: 26)
                        .background(selection == option ? Color.white.opacity(0.08) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(selection == option ? Color.white.opacity(0.2) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// Maç Sonu Genel Durum / Özet Ekranı (Wimbledon Style)
struct MatchSummaryView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Sonuç Başlığı
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.state.winner == .player1 ? Color.courtGreen : Color.zinc500)
                        .frame(width: 6, height: 6)
                    Text(viewModel.state.winner == .player1 ? "GALİBİYET" : "MAĞLUBİYET")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(viewModel.state.winner == .player1 ? .courtGreen : .zinc400)
                        .tracking(1.0)
                }
                .padding(.top, 4)
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                
                // Set Skorları Listesi
                VStack(alignment: .leading, spacing: 6) {
                    Text("SET SKORLARI")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc500)
                        .tracking(1.0)
                    
                    ForEach(Array(viewModel.state.setScores.enumerated()), id: \.offset) { index, setScore in
                        VStack(spacing: 0) {
                            HStack {
                                Text("\(index + 1). SET")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.zinc400)
                                Spacer()
                                Text("\(setScore.p1Games) — \(setScore.p2Games)")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(setScore.p1Games > setScore.p2Games ? .courtGreen : .zinc100)
                            }
                            .padding(.vertical, 4)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 1)
                        }
                    }
                }
                .padding(.horizontal, 2)
                
                // İstatistikler Özet
                VStack(alignment: .leading, spacing: 4) {
                    Text("İSTATİSTİKLER")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc500)
                        .tracking(1.0)
                    
                    let totalGamesP1 = viewModel.state.setScores.reduce(0) { $0 + $1.p1Games }
                    let totalGamesP2 = viewModel.state.setScores.reduce(0) { $0 + $1.p2Games }
                    
                    HStack {
                        Text("Toplam Game")
                            .font(.system(size: 10))
                            .foregroundColor(.zinc400)
                        Spacer()
                        Text("\(totalGamesP1) — \(totalGamesP2)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc200)
                    }
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, 2)
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                
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
                            Text("YENİDEN OYNA")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.tennisVolt)
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
                            Text("YENİ MAÇ KUR")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.zinc300)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
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
                Text("AYARLAR")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.zinc300)
                    .tracking(1.0)
                    .padding(.top, 2)
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                
                // Aktif maç kuralları özeti
                VStack(alignment: .leading, spacing: 3) {
                    Text("AKTİF KURALLAR")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc500)
                        .tracking(0.5)
                    Text("• Set: \(viewModel.gamesPerSet) Game")
                        .font(.system(size: 10))
                        .foregroundColor(.zinc300)
                    Text("• Maç: \(viewModel.setsToWin) Set")
                        .font(.system(size: 10))
                        .foregroundColor(.zinc300)
                    if viewModel.setsToWin > 1 {
                        Text("• Karar Seti: \(viewModel.useMatchTiebreak ? "Süper TB" : "Normal")")
                            .font(.system(size: 10))
                            .foregroundColor(.zinc300)
                    }
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                
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
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
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
                    .font(.system(size: 11, weight: .bold))
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
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.zinc400)
                    .font(.system(size: 9))
                Text("MOLA")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.zinc400)
                    .tracking(1.0)
            }
            
            Text("GAME: \(winnerName.uppercased())")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.zinc100)
                .lineLimit(1)
            
            Text("\(viewModel.state.p1Games) — \(viewModel.state.p2Games)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.tennisVolt)
            
            Button(action: {
                if connectivityManager.isCompanionActive {
                    connectivityManager.sendStartNextGameAction()
                } else {
                    viewModel.startNextGame()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                    Text("YENİ GAME")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(Color.tennisVolt)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}
