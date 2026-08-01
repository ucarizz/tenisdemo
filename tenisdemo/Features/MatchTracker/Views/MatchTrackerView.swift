//
//  MatchTrackerView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import SwiftUI

struct MatchTrackerView: View {
    @StateObject private var viewModel = TennisMatchViewModel()
    @State private var showSettings = false
    @StateObject private var signalRService = SignalRService.shared
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            // Dark Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.12), Color(red: 0.03, green: 0.04, blue: 0.06)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if !viewModel.hasMatchStarted {
                SetupMatchView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            } else if viewModel.state.isMatchOver {
                MatchSummaryView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                VStack(spacing: 16) {
                    // Top Bar: Set Scores and Status Badges
                    HStack {
                        if viewModel.state.setScores.isEmpty {
                            Text("LİG MAÇI")
                                .font(.system(.subheadline, design: .rounded))
                                .bold()
                                .foregroundColor(.gray)
                        } else {
                            HStack(spacing: 8) {
                                ForEach(viewModel.state.setScores) { setScore in
                                    Text("\(setScore.p1Games)-\(setScore.p2Games)")
                                        .font(.system(.subheadline, design: .monospaced))
                                        .bold()
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.12))
                                        .cornerRadius(6)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Rule Status Badges
                        if viewModel.state.isMatchTiebreak {
                            Text("SÜPER TB (10)")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                                .cornerRadius(6)
                        } else if viewModel.state.isTiebreak {
                            Text("TIEBREAK")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Main Scoreboard: Select layout based on width class (iPhone vs iPad)
                    if horizontalSizeClass == .regular {
                        // iPad Layout: Side-by-side cards
                        HStack(spacing: 20) {
                            ScorePlayerCard(
                                player: .player1,
                                name: viewModel.isDouble 
                                    ? "\(viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name) & \(viewModel.player1PartnerName.isEmpty ? "ORTAK 1" : viewModel.player1PartnerName)" 
                                    : (viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name),
                                points: viewModel.formatPoints(viewModel.state.p1Points, isTiebreak: viewModel.state.isTiebreak),
                                games: "\(viewModel.state.p1Games)",
                                sets: "\(viewModel.state.p1Sets)",
                                isServing: viewModel.state.server == .player1,
                                color: Color.emerald,
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
                                color: Color(red: 0.95, green: 0.45, blue: 0.15),
                                isMatchOver: viewModel.state.isMatchOver,
                                onTap: { viewModel.scorePoint(for: .player2) },
                                onTapServer: { viewModel.toggleStartingServer() }
                            )
                        }
                        .padding(.horizontal)
                    } else {
                        // iPhone Layout: Vertically stacked cards
                        VStack(spacing: 16) {
                            ScorePlayerCard(
                                player: .player1,
                                name: viewModel.isDouble 
                                    ? "\(viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name) & \(viewModel.player1PartnerName.isEmpty ? "ORTAK 1" : viewModel.player1PartnerName)" 
                                    : (viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name),
                                points: viewModel.formatPoints(viewModel.state.p1Points, isTiebreak: viewModel.state.isTiebreak),
                                games: "\(viewModel.state.p1Games)",
                                sets: "\(viewModel.state.p1Sets)",
                                isServing: viewModel.state.server == .player1,
                                color: Color.emerald,
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
                                color: Color(red: 0.95, green: 0.45, blue: 0.15),
                                isMatchOver: viewModel.state.isMatchOver,
                                onTap: { viewModel.scorePoint(for: .player2) },
                                onTapServer: { viewModel.toggleStartingServer() }
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Bottom Bar Controls
                    HStack {
                        // Undo Button
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.undo()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(.body, weight: .bold))
                                Text("Geri Al")
                                    .font(.system(.subheadline, design: .rounded))
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(viewModel.history.isEmpty ? 0.04 : 0.12))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .disabled(viewModel.history.isEmpty)
                        
                        Spacer()
                        
                        // Settings Button
                        Button(action: {
                            showSettings = true
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(.body))
                                Text("Ayarlar")
                                    .font(.system(.subheadline, design: .rounded))
                                    .bold()
                            }
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
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
            // Saate anlık skoru gönder
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
                withAnimation(.spring()) {
                    viewModel.applyLiveMatchState(remote)
                }
            }
        }
    }
}

struct ScorePlayerCard: View {
    let player: Player
    let name: String
    let points: String
    let games: String
    let sets: String
    let isServing: Bool
    let color: Color
    let isMatchOver: Bool
    let onTap: () -> Void
    let onTapServer: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    // Servisçi İkonu
                    Button(action: onTapServer) {
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(isServing ? Color(red: 0.86, green: 0.98, blue: 0.22) : Color.clear)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: isServing ? "tennisball.fill" : "tennisball")
                                    .font(.system(size: 12))
                                    .foregroundColor(isServing ? .black : .gray.opacity(0.4))
                            }
                            
                            if isServing {
                                Text("SERVİS")
                                    .font(.system(size: 9, weight: .black, design: .rounded))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Set Skoru
                    HStack(spacing: 4) {
                        Text("SET:")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                        Text(sets)
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(color)
                    }
                }
                
                Spacer()
                
                // Oyuncu İsmi & Puan
                VStack(spacing: 4) {
                    Text(name)
                        .font(.system(.headline, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(points)
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Spacer()
                
                // Game Skorları
                HStack {
                    Text("Game:")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(games)
                        .font(.system(.title3, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isServing ? color.opacity(0.6) : color.opacity(0.15), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isMatchOver)
    }
}

struct MatchTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MatchTrackerView()
            .preferredColorScheme(.dark)
    }
}
