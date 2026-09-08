//
//  MatchTrackerView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//  Refactored for Linear / Vercel Minimal Aesthetic
//

import SwiftUI

struct MatchTrackerView: View {
    @StateObject private var viewModel = TennisMatchViewModel()
    @State private var showSettings = false
    @StateObject private var signalRService = SignalRService.shared
    @State private var showOpponentLeftAlert = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            // Flat Seamless Canvas
            Color.zinc950.ignoresSafeArea()
            
            if !viewModel.hasMatchStarted {
                SetupMatchView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            } else if viewModel.state.isMatchOver {
                MatchSummaryView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            } else {
                VStack(spacing: 0) {
                    // 1. Editorial Match Header (Wimbledon / Apple Sports bulletin)
                    VStack(spacing: 12) {
                        HStack(alignment: .center) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.tennisVolt)
                                    .frame(width: 6, height: 6)
                                Text(signalRService.lobbyState != nil ? "CANLI MAÇ" : "KULÜP MAÇI")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(2.0)
                                    .foregroundColor(.tennisVolt)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(viewModel.isDouble ? "ÇİFTLER" : "TEKLER")
                                    .font(.system(size: 11, weight: .semibold))
                                    .tracking(1.5)
                                    .foregroundColor(.zinc400)
                                
                                if viewModel.state.isMatchTiebreak {
                                    Text("• SÜPER TB (10)")
                                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.badgeAmber)
                                } else if viewModel.state.isTiebreak {
                                    Text("• TIEBREAK")
                                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.tennisVolt)
                                }
                            }
                        }
                        
                        // Kort Çizgisi Ayracı
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                        
                        // Maç İçi Ayrılma / Uyarı Bildirim Bandı
                        if let banner = signalRService.notificationMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.badgeAmber)
                                Text(banner)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(10)
                            .background(Color.badgeAmber.opacity(0.15))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.badgeAmber.opacity(0.4), lineWidth: 1))
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Kolon Başlıkları (Scoreboard Headers)
                        HStack(alignment: .center, spacing: 0) {
                            Text("OYUNCULAR")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(.zinc500)
                            
                            Spacer()
                            
                            HStack(spacing: 0) {
                                Text("SET")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .tracking(1.0)
                                    .foregroundColor(.zinc500)
                                    .frame(width: 44, alignment: .trailing)
                                
                                Text("GAME")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .tracking(1.0)
                                    .foregroundColor(.zinc500)
                                    .frame(width: 50, alignment: .trailing)
                                
                                Text("PUAN")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .tracking(1.0)
                                    .foregroundColor(.zinc500)
                                    .frame(width: 80, alignment: .trailing)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    
                    // Kort Çizgisi: Başlık ile Skor Tahtası Arası
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    // 2. Scoreboard Main Board (Editorial Court Strip)
                    ZStack {
                        VStack(spacing: 0) {
                            // Player 1 Row
                            EditorialPlayerScoreRow(
                                player: .player1,
                                name: viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name,
                                partnerName: viewModel.isDouble ? (viewModel.player1PartnerName.isEmpty ? "ORTAK 1" : viewModel.player1PartnerName) : nil,
                                points: viewModel.formatPoints(viewModel.state.p1Points, isTiebreak: viewModel.state.isTiebreak),
                                games: "\(viewModel.state.p1Games)",
                                sets: "\(viewModel.state.p1Sets)",
                                isServing: viewModel.state.server == .player1,
                                onTapScore: { viewModel.scorePoint(for: .player1) },
                                onTapServer: { viewModel.toggleStartingServer() }
                            )
                            
                            // Kort Çizgisi: İki oyuncu arasındaki belirgin kort çizgisi
                            Rectangle()
                                .fill(Color.white.opacity(0.16))
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                            
                            // Player 2 Row
                            EditorialPlayerScoreRow(
                                player: .player2,
                                name: viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name,
                                partnerName: viewModel.isDouble ? (viewModel.player2PartnerName.isEmpty ? "ORTAK 2" : viewModel.player2PartnerName) : nil,
                                points: viewModel.formatPoints(viewModel.state.p2Points, isTiebreak: viewModel.state.isTiebreak),
                                games: "\(viewModel.state.p2Games)",
                                sets: "\(viewModel.state.p2Sets)",
                                isServing: viewModel.state.server == .player2,
                                onTapScore: { viewModel.scorePoint(for: .player2) },
                                onTapServer: { viewModel.toggleStartingServer() }
                            )
                            
                            // Kort Çizgisi: Alt Çizgi
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                            
                            // Set Geçmişi Şeridi (Minimalist Kort Çizgili Set Bülteni)
                            if !viewModel.state.setScores.isEmpty {
                                HStack(spacing: 16) {
                                    Text("BİTEN SETLER")
                                        .font(.system(size: 10, weight: .semibold))
                                        .tracking(1.2)
                                        .foregroundColor(.zinc500)
                                    
                                    ForEach(Array(viewModel.state.setScores.enumerated()), id: \.offset) { index, score in
                                        HStack(spacing: 4) {
                                            Text("S\(index + 1):")
                                                .font(.system(size: 11, design: .monospaced))
                                                .foregroundColor(.zinc500)
                                            Text("\(score.p1Games)-\(score.p2Games)")
                                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                .foregroundColor(score.p1Games > score.p2Games ? .courtGreen : .zinc300)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .opacity(viewModel.state.isGameBreak ? 0.15 : 1.0)
                        .allowsHitTesting(!viewModel.state.isGameBreak)
                        
                        // Game Arası / Su Molası Editorial Overlay
                        if viewModel.state.isGameBreak {
                            GameBreakEditorialView(viewModel: viewModel)
                                .transition(.opacity)
                        }
                    }
                    
                    // 3. Ferah Dikey Boşluk (Editorial Whitespace)
                    Spacer()
                    
                    // 4. Alt Kort Çizgisi & Kontroller
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                        
                        HStack(spacing: 16) {
                            // Geri Al Butonu
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    viewModel.undo()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("GERİ AL")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(1.2)
                                }
                                .foregroundColor(viewModel.history.isEmpty ? .zinc600 : .zinc200)
                                .padding(.vertical, 14)
                            }
                            .disabled(viewModel.history.isEmpty)
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            // Sayı Ekle İpucu (Editorial)
                            Text("Sayı eklemek için oyuncuya dokunun")
                                .font(.system(size: 11))
                                .foregroundColor(.zinc600)
                            
                            Spacer()
                            
                            // Kurallar Butonu
                            Button(action: {
                                showSettings = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 12, weight: .medium))
                                    Text("KURALLAR")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(1.2)
                                }
                                .foregroundColor(.zinc400)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 6)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(viewModel: viewModel, showSettings: $showSettings)
                }
            }
        }
        .onAppear {
            WatchConnectivityManager.shared.setup(viewModel: viewModel)
        }
        .onChange(of: viewModel.hasMatchStarted) { _ in
            WatchConnectivityManager.shared.syncWithWatch()
        }
        .onChange(of: viewModel.gamesPerSet) { _ in
            WatchConnectivityManager.shared.syncWithWatch()
        }
        .onChange(of: viewModel.setsToWin) { _ in
            WatchConnectivityManager.shared.syncWithWatch()
        }
        .onChange(of: viewModel.useMatchTiebreak) { _ in
            WatchConnectivityManager.shared.syncWithWatch()
        }
        .onChange(of: viewModel.isDouble) { _ in
            WatchConnectivityManager.shared.syncWithWatch()
        }
        .onChange(of: viewModel.player1Name) { _ in
            WatchConnectivityManager.shared.syncWithWatch()
        }
        .onChange(of: viewModel.player2Name) { _ in
            WatchConnectivityManager.shared.syncWithWatch()
        }
        .onChange(of: viewModel.state) { newState in
            WatchConnectivityManager.shared.syncWithWatch()
            
            if let lobby = signalRService.lobbyState {
                let liveState = viewModel.makeLiveMatchState()
                if let remote = signalRService.remoteMatchState,
                   remote.p1Points == liveState.p1Points &&
                   remote.p2Points == liveState.p2Points &&
                   remote.p1Games == liveState.p1Games &&
                   remote.p2Games == liveState.p2Games &&
                   remote.p1Sets == liveState.p1Sets &&
                   remote.p2Sets == liveState.p2Sets &&
                   remote.server == liveState.server &&
                   remote.isMatchOver == liveState.isMatchOver {
                    return
                }
                signalRService.sendScoreUpdate(code: lobby.code, state: liveState)
            }
        }
        .onChange(of: signalRService.remoteMatchState) { remoteState in
            if let remote = remoteState {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    viewModel.applyLiveMatchState(remote)
                }
            }
        }
        .onChange(of: signalRService.lobbyState) { newLobbyState in
            if viewModel.hasMatchStarted && newLobbyState == nil && !viewModel.state.isMatchOver {
                showOpponentLeftAlert = true
            }
        }
        .onChange(of: signalRService.playerLeftMatchAlert) { alertMsg in
            if alertMsg != nil && viewModel.hasMatchStarted && !viewModel.state.isMatchOver {
                showOpponentLeftAlert = true
            }
        }
        .alert(isPresented: $showOpponentLeftAlert) {
            Alert(
                title: Text("Oyuncu Ayrıldı"),
                message: Text(signalRService.playerLeftMatchAlert ?? "Rakip oyuncu maçtan ayrıldı. Maç sonlandırıldı."),
                dismissButton: .default(Text("Tamam")) {
                    let shouldCancel = signalRService.lobbyState == nil
                    signalRService.playerLeftMatchAlert = nil
                    if shouldCancel {
                        viewModel.newMatch()
                    }
                }
            )
        }
    }
}

// MARK: - Editorial Player Score Row (Wimbledon Scoreboard Strip)
struct EditorialPlayerScoreRow: View {
    let player: Player
    let name: String
    let partnerName: String?
    let points: String
    let games: String
    let sets: String
    let isServing: Bool
    let onTapScore: () -> Void
    let onTapServer: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            onTapScore()
        }) {
            HStack(alignment: .center, spacing: 0) {
                // Servis Noktası (●) & Oyuncu Adı
                HStack(spacing: 12) {
                    // Yalnızca tek bir volt sarısı/lime nokta (●)
                    Button(action: onTapServer) {
                        ZStack {
                            Circle()
                                .fill(isServing ? Color.tennisVolt : Color.clear)
                                .frame(width: 8, height: 8)
                                .shadow(color: isServing ? Color.tennisVolt.opacity(0.8) : Color.clear, radius: 4)
                        }
                        .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(name.uppercased())
                            .font(.system(size: 19, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(.zinc50)
                            .lineLimit(1)
                        
                        if let partner = partnerName, !partner.isEmpty {
                            Text("& \(partner.uppercased())")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.zinc500)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Skor Sütunları: SET, GAME ve Devasa PUAN
                HStack(alignment: .center, spacing: 0) {
                    // Set Sayısı
                    Text(sets)
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        .foregroundColor(.zinc400)
                        .frame(width: 44, alignment: .trailing)
                    
                    // Game Sayısı
                    Text(games)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc100)
                        .frame(width: 50, alignment: .trailing)
                    
                    // PUAN: Ekranın en büyük görsel öğesi
                    Text(points)
                        .font(.system(size: 54, weight: .black, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(isServing ? .tennisVolt : .white)
                        .frame(width: 80, alignment: .trailing)
                        .contentTransition(.numericText())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Editorial Minimal Game Break View (Court Overlay)
struct GameBreakEditorialView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    
    var winnerName: String {
        guard let winner = viewModel.state.lastGameWinner else { return "OYUN TAMAMLANDI" }
        if winner == .player1 {
            return viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name
        } else {
            return viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name
        }
    }
    
    var nextServerName: String {
        if viewModel.state.server == .player1 {
            return viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name
        } else {
            return viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Başlık
            Text("SU MOLASI • OYUN ARASI")
                .font(.system(size: 11, weight: .bold))
                .tracking(2.0)
                .foregroundColor(.tennisVolt)
            
            // Kort Çizgisi
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
            
            // Kazanan & Set Skoru
            VStack(spacing: 8) {
                Text("KAZANAN: \(winnerName.uppercased())")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(1.0)
                    .foregroundColor(.zinc100)
                
                Text("Set Skoru: \(viewModel.state.p1Games) - \(viewModel.state.p2Games)")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            // Sıradaki Servis: Tek volt nokta
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.tennisVolt)
                    .frame(width: 7, height: 7)
                Text("SIRADAKİ SERVİS:")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.zinc500)
                Text(nextServerName.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.zinc200)
            }
            
            // Kort Çizgisi
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
            
            // Aksiyon Butonu
            Button(action: {
                viewModel.startNextGame()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text("YENİ GAME'İ BAŞLAT")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.tennisVolt)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(Color.zinc950)
        .overlay(
            Rectangle()
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

struct MatchTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MatchTrackerView()
            .preferredColorScheme(.dark)
    }
}
