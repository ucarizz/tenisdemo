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
            // Neutral Solid Canvas
            Color.zinc950.ignoresSafeArea()
            
            if !viewModel.hasMatchStarted {
                SetupMatchView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            } else if viewModel.state.isMatchOver {
                MatchSummaryView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            } else {
                VStack(spacing: 12) {
                    // Top Bar: Set Scores and Status Badges
                    HStack(spacing: 8) {
                        if viewModel.state.setScores.isEmpty {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.statusGreen)
                                    .frame(width: 6, height: 6)
                                Text("CANLI MAÇ")
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.zinc400)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                        } else {
                            HStack(spacing: 6) {
                                ForEach(viewModel.state.setScores) { setScore in
                                    Text("\(setScore.p1Games)-\(setScore.p2Games)")
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.zinc100)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.zinc900)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.zinc800, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Rule Status Badges
                        if viewModel.state.isMatchTiebreak {
                            Text("SÜPER TB (10)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc100)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.zinc850)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc700, lineWidth: 1)
                                )
                        } else if viewModel.state.isTiebreak {
                            Text("TIEBREAK")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc100)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.zinc850)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc700, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    
                    // Main Scoreboard: Select layout based on width class (iPhone vs iPad)
                    ZStack {
                        Group {
                            if horizontalSizeClass == .regular {
                                // iPad Layout: Side-by-side cards
                                HStack(spacing: 12) {
                                    ScorePlayerCard(
                                        player: .player1,
                                        name: viewModel.isDouble 
                                            ? "\(viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name) & \(viewModel.player1PartnerName.isEmpty ? "ORTAK 1" : viewModel.player1PartnerName)" 
                                            : (viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name),
                                        points: viewModel.formatPoints(viewModel.state.p1Points, isTiebreak: viewModel.state.isTiebreak),
                                        games: "\(viewModel.state.p1Games)",
                                        sets: "\(viewModel.state.p1Sets)",
                                        isServing: viewModel.state.server == .player1,
                                        isMatchOver: viewModel.state.isMatchOver,
                                        onTap: { viewModel.scorePoint(for: .player1) },
                                        onTapServer: { viewModel.toggleStartingServer() }
                                    )
                                    
                                    ScorePlayerCard(
                                        player: .player2,
                                        name: viewModel.isDouble 
                                            ? "\(viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name) & \(viewModel.player2PartnerName.isEmpty ? "ORTAK 2" : viewModel.player2PartnerName)" 
                                            : (viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name),
                                        points: viewModel.formatPoints(viewModel.state.p2Points, isTiebreak: viewModel.state.isTiebreak),
                                        games: "\(viewModel.state.p2Games)",
                                        sets: "\(viewModel.state.p2Sets)",
                                        isServing: viewModel.state.server == .player2,
                                        isMatchOver: viewModel.state.isMatchOver,
                                        onTap: { viewModel.scorePoint(for: .player2) },
                                        onTapServer: { viewModel.toggleStartingServer() }
                                    )
                                }
                                .padding(.horizontal, 16)
                            } else {
                                // iPhone Layout: Vertically stacked cards
                                VStack(spacing: 10) {
                                    ScorePlayerCard(
                                        player: .player1,
                                        name: viewModel.isDouble 
                                            ? "\(viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name) & \(viewModel.player1PartnerName.isEmpty ? "ORTAK 1" : viewModel.player1PartnerName)" 
                                            : (viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name),
                                        points: viewModel.formatPoints(viewModel.state.p1Points, isTiebreak: viewModel.state.isTiebreak),
                                        games: "\(viewModel.state.p1Games)",
                                        sets: "\(viewModel.state.p1Sets)",
                                        isServing: viewModel.state.server == .player1,
                                        isMatchOver: viewModel.state.isMatchOver,
                                        onTap: { viewModel.scorePoint(for: .player1) },
                                        onTapServer: { viewModel.toggleStartingServer() }
                                    )
                                    
                                    ScorePlayerCard(
                                        player: .player2,
                                        name: viewModel.isDouble 
                                            ? "\(viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name) & \(viewModel.player2PartnerName.isEmpty ? "ORTAK 2" : viewModel.player2PartnerName)" 
                                            : (viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name),
                                        points: viewModel.formatPoints(viewModel.state.p2Points, isTiebreak: viewModel.state.isTiebreak),
                                        games: "\(viewModel.state.p2Games)",
                                        sets: "\(viewModel.state.p2Sets)",
                                        isServing: viewModel.state.server == .player2,
                                        isMatchOver: viewModel.state.isMatchOver,
                                        onTap: { viewModel.scorePoint(for: .player2) },
                                        onTapServer: { viewModel.toggleStartingServer() }
                                    )
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .opacity(viewModel.state.isGameBreak ? 0.25 : 1.0)
                        .allowsHitTesting(!viewModel.state.isGameBreak)
                        
                        // Game Arası / Su Molası Kartı
                        if viewModel.state.isGameBreak {
                            GameBreakCardView(viewModel: viewModel)
                                .transition(.opacity)
                        }
                    }
                    
                    // Bottom Bar Controls
                    HStack(spacing: 12) {
                        // Undo Button
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                viewModel.undo()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Geri Al")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(viewModel.history.isEmpty ? .zinc600 : .zinc200)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                        }
                        .disabled(viewModel.history.isEmpty)
                        
                        Spacer()
                        
                        // Settings Button
                        Button(action: {
                            showSettings = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Kurallar")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.zinc400)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
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
                viewModel.newMatch()
            }
        }
        .alert(isPresented: $showOpponentLeftAlert) {
            Alert(
                title: Text("Maç İptal Edildi"),
                message: Text("Rakip oyuncu maçtan veya lobiden ayrıldı."),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}

// MARK: - Linear Minimal Score Player Card
struct ScorePlayerCard: View {
    let player: Player
    let name: String
    let points: String
    let games: String
    let sets: String
    let isServing: Bool
    let isMatchOver: Bool
    let onTap: () -> Void
    let onTapServer: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header Bar: Player Name, Serving Indicator & Set Counter
                HStack(alignment: .center) {
                    // Servis İkonu / Butonu
                    Button(action: onTapServer) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isServing ? Color.zinc100 : Color.zinc700)
                                .frame(width: 6, height: 6)
                            
                            if isServing {
                                Text("SERVİS")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.zinc100)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.zinc800)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.zinc700, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text(name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.zinc200)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Set Skoru
                    HStack(spacing: 4) {
                        Text("SET")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.zinc500)
                        Text(sets)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc100)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.zinc800)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.zinc700, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                Divider()
                    .background(Color.zinc800)
                
                // Point Number (High Information Density, Flat Monochrome)
                HStack {
                    Spacer()
                    Text(points)
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc50)
                        .contentTransition(.numericText())
                    Spacer()
                }
                .padding(.vertical, 14)
                
                Divider()
                    .background(Color.zinc800)
                
                // Footer: Game Count
                HStack {
                    Text("GAME")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.zinc500)
                    Spacer()
                    Text(games)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.zinc100)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .background(Color.zinc900)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isServing ? Color.zinc600 : Color.zinc800, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isMatchOver)
    }
}

// MARK: - Linear Minimal Game Break Card
struct GameBreakCardView: View {
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
        VStack(spacing: 16) {
            // Header Tag
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.statusOrange)
                    .frame(width: 6, height: 6)
                Text("SU MOLASI")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.zinc300)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.zinc850)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.zinc700, lineWidth: 1)
            )
            
            // Winner & Set Score
            VStack(spacing: 4) {
                Text("GAME: \(winnerName.uppercased())")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.zinc100)
                
                Text("Set Skoru: \(viewModel.state.p1Games) - \(viewModel.state.p2Games)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.zinc50)
            }
            
            // Next Serve Row
            HStack(spacing: 6) {
                Text("Sıradaki Servis:")
                    .font(.system(size: 12))
                    .foregroundColor(.zinc500)
                Text(nextServerName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.zinc200)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.zinc850)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.zinc800, lineWidth: 1)
            )
            
            // Primary Action Button (Vercel Crisp White Button)
            Button(action: {
                viewModel.startNextGame()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12))
                    Text("Yeni Game'i Başlat")
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
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color.zinc900)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.zinc700, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 24)
    }
}

struct MatchTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MatchTrackerView()
            .preferredColorScheme(.dark)
    }
}
