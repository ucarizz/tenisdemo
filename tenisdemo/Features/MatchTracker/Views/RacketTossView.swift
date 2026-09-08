//
//  RacketTossView.swift
//  tenisdemo
//
//  Created for Modern Sports Analytics & Tennis Ritual
//  Ters mi Düz mü? (Spin the Racket / Kura)
//

import SwiftUI
import AudioToolbox

struct RacketTossView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    @StateObject private var signalRService = SignalRService.shared
    
    // Kura Modu: Yerel Maç veya Canlı Lobi
    var isLiveLobby: Bool = false
    var onComplete: (_ startingServer: Player) -> Void
    var onDismiss: () -> Void
    
    // Animasyon Durumu
    @State private var rotationAngle: Double = 0
    @State private var isSpinning: Bool = false
    @State private var tossResult: String? = nil // "UP" (DÜZ) veya "DOWN" (TERS)
    @State private var winnerName: String = ""
    @State private var isWinnerPlayer1: Bool = true
    @State private var selectedChoice: Player? = nil // Kim servis atacak?
    
    // Tahmin (Yerel Maç İçin)
    @State private var playerGuess: String = "UP" // "UP" (DÜZ) veya "DOWN" (TERS)
    
    private let hapticLight = UIImpactFeedbackGenerator(style: .light)
    private let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let hapticMedium = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Bulletin)
                headerView
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                
                Spacer()
                
                // 3D Dönen Raket
                racket3DView
                    .frame(height: 280)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if !isSpinning && tossResult == nil {
                                    startSpin()
                                }
                            }
                    )
                
                Spacer()
                
                // Sonuç & Seçim Alanı
                bottomControlView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            hapticLight.prepare()
            hapticHeavy.prepare()
            hapticMedium.prepare()
            
            // Eğer Canlı Lobide kura sonucu zaten geldiyse
            if isLiveLobby, let res = signalRService.tossResult {
                applyLobbyTossResult(res)
            }
        }
        .onChange(of: signalRService.tossResult) { newResult in
            if isLiveLobby, let res = newResult {
                applyLobbyTossResult(res)
            }
        }
        .onChange(of: signalRService.initialServerChoice) { choice in
            if isLiveLobby, let c = choice {
                let s: Player = (c == "p1" || c == "SİZ") ? .player1 : .player2
                onComplete(s)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.tennisVolt)
                        .frame(width: 6, height: 6)
                    Text("MAÇ ÖNCESİ RİTÜELİ")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(.tennisVolt)
                }
                
                Text("TERS Mİ DÜZ MÜ?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                Button(action: {
                    hapticLight.impactOccurred()
                    onDismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.zinc400)
                        .padding(8)
                        .background(Color.zinc900)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.zinc800, lineWidth: 1))
                }
                
                Button(action: {
                    // Kurayı atla, P1 servisle başla
                    hapticLight.impactOccurred()
                    onComplete(.player1)
                }) {
                    Text("KURAYI ATLA")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(.zinc400)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.zinc900)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.zinc800, lineWidth: 1))
                }
            }
        }
    }
    
    // MARK: - 3D Tenis Raketi Görünümü
    private var racket3DView: some View {
        VStack(spacing: 0) {
            // Raket Çerçevesi ve Telleri
            ZStack {
                // Raket Kafası (Oval Kafa)
                Ellipse()
                    .stroke(
                        LinearGradient(
                            colors: [Color.zinc300, Color.tennisVolt, Color.zinc500],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 140, height: 180)
                    .background(
                        Ellipse()
                            .fill(Color.zinc900.opacity(0.4))
                    )
                
                // Kordaj Izgarası (Teller)
                racketStringsGrid
                    .frame(width: 126, height: 164)
                    .clipShape(Ellipse())
                
                // Ortadaki Logo / Yüz Göstergesi (DÜZ veya TERS)
                ZStack {
                    Circle()
                        .fill(Color.zinc950.opacity(0.85))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(tossResult != nil ? Color.tennisVolt : Color.zinc700, lineWidth: 2)
                        )
                    
                    if isFaceUp {
                        VStack(spacing: 2) {
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.tennisVolt)
                            Text("DÜZ")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    } else {
                        VStack(spacing: 2) {
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 14, weight: .bold))
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.badgeAmber)
                            Text("TERS")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            // Raket Boğazı (Throat)
            Path { path in
                path.move(to: CGPoint(x: 10, y: 0))
                path.addLine(to: CGPoint(x: 16, y: 24))
                path.addLine(to: CGPoint(x: 24, y: 24))
                path.addLine(to: CGPoint(x: 30, y: 0))
            }
            .stroke(Color.zinc400, lineWidth: 3)
            .frame(width: 40, height: 24)
            
            // Sap (Grip Handle)
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.zinc800, Color.zinc900, Color.zinc800],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 18, height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.zinc700, lineWidth: 1)
                    )
                
                // Grip Sargı Çizgileri
                VStack(spacing: 8) {
                    ForEach(0..<6) { _ in
                        Rectangle()
                            .fill(Color.zinc700.opacity(0.6))
                            .frame(width: 16, height: 1)
                    }
                }
            }
            
            // Sap Kapağı (Butt Cap)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.tennisVolt)
                .frame(width: 22, height: 8)
                .shadow(color: Color.tennisVolt.opacity(0.3), radius: 4, y: 2)
        }
        .rotation3DEffect(
            .degrees(rotationAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.4
        )
        .scaleEffect(isSpinning ? 1.05 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSpinning)
    }
    
    // Kordaj Izgarası
    private var racketStringsGrid: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            
            ZStack {
                // Dikey Teller
                ForEach(1..<8) { i in
                    let x = w * CGFloat(i) / 8.0
                    Path { p in
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: h))
                    }
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                }
                
                // Yatay Teller
                ForEach(1..<10) { j in
                    let y = h * CGFloat(j) / 10.0
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: w, y: y))
                    }
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                }
            }
        }
    }
    
    // Dönüş açısına göre raketin yüzü DÜZ mü TERS mi?
    private var isFaceUp: Bool {
        let normalized = Int(abs(rotationAngle).truncatingRemainder(dividingBy: 360))
        return (normalized >= 270 || normalized <= 90)
    }
    
    // MARK: - Alt Kontroller ve Seçim
    private var bottomControlView: some View {
        VStack(spacing: 16) {
            if tossResult == nil {
                // Kura Öncesi: Tahmin & Çevir Butonu
                VStack(spacing: 14) {
                    Text("Raketi parmağınızla çevirebilir veya butona basabilirsiniz")
                        .font(.system(size: 11))
                        .foregroundColor(.zinc500)
                    
                    // Tahmin Seçici (Yerel Maçta)
                    if !isLiveLobby {
                        HStack(spacing: 16) {
                            Button(action: {
                                hapticLight.impactOccurred()
                                playerGuess = "UP"
                            }) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(playerGuess == "UP" ? Color.tennisVolt : Color.clear)
                                        .frame(width: 6, height: 6)
                                    Text("▲ DÜZ TAHMİNİ")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(playerGuess == "UP" ? .white : .zinc500)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(playerGuess == "UP" ? Color.zinc900 : Color.clear)
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(playerGuess == "UP" ? Color.tennisVolt.opacity(0.4) : Color.zinc800, lineWidth: 1))
                            }
                            
                            Button(action: {
                                hapticLight.impactOccurred()
                                playerGuess = "DOWN"
                            }) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(playerGuess == "DOWN" ? Color.tennisVolt : Color.clear)
                                        .frame(width: 6, height: 6)
                                    Text("▼ TERS TAHMİNİ")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(playerGuess == "DOWN" ? .white : .zinc500)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(playerGuess == "DOWN" ? Color.zinc900 : Color.clear)
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(playerGuess == "DOWN" ? Color.tennisVolt.opacity(0.4) : Color.zinc800, lineWidth: 1))
                            }
                        }
                    }
                    
                    Button(action: {
                        startSpin()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 14, weight: .bold))
                            Text(isSpinning ? "RAKET DÖNÜYOR..." : "RAKETİ ÇEVİR")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(1.5)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.tennisVolt)
                        .cornerRadius(8)
                    }
                    .disabled(isSpinning)
                }
            } else {
                // Kura Tamamlandı: Sonuç ve Servis Seçimi
                VStack(spacing: 14) {
                    // Sonuç Rozeti
                    HStack(spacing: 8) {
                        Image(systemName: tossResult == "UP" ? "triangle.fill" : "triangle.fill")
                            .rotationEffect(.degrees(tossResult == "UP" ? 0 : 180))
                            .foregroundColor(tossResult == "UP" ? .tennisVolt : .badgeAmber)
                        
                        Text(tossResult == "UP" ? "SONUÇ: DÜZ (UP)" : "SONUÇ: TERS (DOWN)")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.zinc900)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.zinc800, lineWidth: 1))
                    
                    Text("KURAYI KAZANAN: \(winnerName.uppercased())")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(.tennisVolt)
                    
                    // Servis Tercih Kartları
                    HStack(spacing: 12) {
                        Button(action: {
                            hapticMedium.impactOccurred()
                            selectedChoice = isWinnerPlayer1 ? .player1 : .player2
                        }) {
                            VStack(spacing: 6) {
                                Text("🎾 SERVİS ATACAĞIM")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(selectedChoice == (isWinnerPlayer1 ? .player1 : .player2) ? .white : .zinc400)
                                Text("İlk servis hakkını kullanır")
                                    .font(.system(size: 10))
                                    .foregroundColor(.zinc500)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedChoice == (isWinnerPlayer1 ? .player1 : .player2) ? Color.zinc850 : Color.zinc900)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedChoice == (isWinnerPlayer1 ? .player1 : .player2) ? Color.tennisVolt : Color.zinc800, lineWidth: 1)
                            )
                        }
                        
                        Button(action: {
                            hapticMedium.impactOccurred()
                            selectedChoice = isWinnerPlayer1 ? .player2 : .player1
                        }) {
                            VStack(spacing: 6) {
                                Text("🛡️ KARŞILAYACAĞIM")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(selectedChoice == (isWinnerPlayer1 ? .player2 : .player1) ? .white : .zinc400)
                                Text("İlk servisi rakibe bırakır")
                                    .font(.system(size: 10))
                                    .foregroundColor(.zinc500)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedChoice == (isWinnerPlayer1 ? .player2 : .player1) ? Color.zinc850 : Color.zinc900)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedChoice == (isWinnerPlayer1 ? .player2 : .player1) ? Color.tennisVolt : Color.zinc800, lineWidth: 1)
                            )
                        }
                    }
                    
                    // Maça Başla Butonu
                    Button(action: {
                        let finalServer = selectedChoice ?? (isWinnerPlayer1 ? .player1 : .player2)
                        hapticHeavy.impactOccurred()
                        
                        if isLiveLobby, let code = signalRService.lobbyState?.code {
                            signalRService.selectTossChoice(code: code, startingServer: finalServer == .player1 ? "p1" : "p2")
                        } else {
                            onComplete(finalServer)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("MAÇA BAŞLA")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(1.5)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.tennisVolt)
                        .cornerRadius(8)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Kura Döndürme Mantığı
    private func startSpin() {
        guard !isSpinning else { return }
        isSpinning = true
        tossResult = nil
        
        // Rastgele sonuç belirle
        let willBeUp = Bool.random()
        let resultString = willBeUp ? "UP" : "DOWN"
        
        // Eğer canlı lobi ise sunucuya çevirme çağrısı yap
        if isLiveLobby, let code = signalRService.lobbyState?.code {
            signalRService.spinRacket(code: code)
            return
        }
        
        executeSpinAnimation(targetResult: resultString)
    }
    
    private func applyLobbyTossResult(_ res: TossResult) {
        let isUp = res.result == "UP"
        self.winnerName = res.winnerName
        self.isWinnerPlayer1 = (res.winnerSlot == 0)
        executeSpinAnimation(targetResult: res.result)
    }
    
    private func executeSpinAnimation(targetResult: String) {
        let willBeUp = (targetResult == "UP")
        let fullRotations: Double = Double(Int.random(in: 5...7)) * 360
        let targetAngle = fullRotations + (willBeUp ? 0 : 180)
        
        // Haptik zamanlayıcısı
        var tickCount = 0
        let totalTicks = 16
        Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
            tickCount += 1
            hapticLight.impactOccurred()
            if tickCount >= totalTicks {
                timer.invalidate()
            }
        }
        
        withAnimation(.timingCurve(0.15, 0.85, 0.35, 1.0, duration: 2.4)) {
            rotationAngle += targetAngle
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            hapticHeavy.impactOccurred()
            isSpinning = false
            tossResult = targetResult
            
            if !isLiveLobby {
                // Yerel maçta kazananı belirle
                let isGuessCorrect = (playerGuess == targetResult)
                isWinnerPlayer1 = isGuessCorrect
                winnerName = isGuessCorrect ? viewModel.player1Name : viewModel.player2Name
                if winnerName.isEmpty {
                    winnerName = isGuessCorrect ? "OYUNCU 1" : "OYUNCU 2"
                }
            }
            
            // Varsayılan seçim kazanan oyuncunun servisi
            selectedChoice = isWinnerPlayer1 ? .player1 : .player2
        }
    }
}
