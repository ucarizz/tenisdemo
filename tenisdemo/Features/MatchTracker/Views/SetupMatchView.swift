import SwiftUI

struct SetupMatchView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    
    @StateObject private var signalRService = SignalRService.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var sharePlayManager = SharePlayManager.shared
    
    @State private var selectedSetupMode = 0 // 0: Yerel Maç, 1: Canlı Lobi
    @State private var lobbyRole = 0 // 0: Lobi Kur, 1: Lobiye Katıl
    @State private var lobbyCodeInput = ""
    @State private var localError = ""
    @State private var copiedCodeFeedback = false
    @State private var showRacketToss = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Editorial Header (Match Bulletin)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.tennisVolt)
                                .frame(width: 6, height: 6)
                            Text("MAÇ PROTOKOLÜ")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2.0)
                                .foregroundColor(.tennisVolt)
                        }
                        
                        Text("YENİ MAÇ KURULUMU")
                            .font(.system(size: 24, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Kort Çizgisi
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    // Editorial Mod Seçici (Kort Çizgili Tablar)
                    HStack(spacing: 28) {
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                selectedSetupMode = 0
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text("YEREL MAÇ")
                                    .font(.system(size: 13, weight: selectedSetupMode == 0 ? .bold : .medium))
                                    .tracking(1.5)
                                    .foregroundColor(selectedSetupMode == 0 ? .white : .zinc500)
                                
                                Rectangle()
                                    .fill(selectedSetupMode == 0 ? Color.tennisVolt : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                selectedSetupMode = 1
                            }
                        }) {
                            VStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Text("CANLI LOBİ")
                                        .font(.system(size: 13, weight: selectedSetupMode == 1 ? .bold : .medium))
                                        .tracking(1.5)
                                        .foregroundColor(selectedSetupMode == 1 ? .white : .zinc500)
                                    
                                    Circle()
                                        .fill(Color.tennisVolt)
                                        .frame(width: 5, height: 5)
                                }
                                
                                Rectangle()
                                    .fill(selectedSetupMode == 1 ? Color.tennisVolt : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    if selectedSetupMode == 0 {
                        localMatchView
                    } else {
                        liveLobbyView
                    }
                    
                    Spacer(minLength: 24)
                }
            }
            
            // Bottom Action Button
            actionButton
        }
        .background(Color.zinc950.ignoresSafeArea())
        .onChange(of: signalRService.isMatchStarted) { started in
            if started, let lobby = signalRService.lobbyState {
                showRacketToss = false
                viewModel.player1Name = lobby.hostName
                viewModel.player1PartnerName = lobby.hostPartnerName ?? ""
                viewModel.player2Name = lobby.guestName ?? "RAKİP"
                viewModel.player2PartnerName = lobby.guestPartnerName ?? ""
                viewModel.isDouble = lobby.isDouble
                viewModel.gamesPerSet = lobby.settings.gamesPerSet
                viewModel.setsToWin = lobby.settings.setsToWin
                viewModel.useMatchTiebreak = lobby.settings.useMatchTiebreak
                if let choice = signalRService.initialServerChoice {
                    viewModel.startingServer = (choice == "p1" || choice == "SİZ") ? .player1 : .player2
                }
                
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    viewModel.startMatch()
                }
            }
        }
        .onChange(of: signalRService.isTossActive) { active in
            if active {
                showRacketToss = true
            }
        }
        .onChange(of: signalRService.initialServerChoice) { choice in
            if let c = choice {
                viewModel.startingServer = (c == "p1" || c == "SİZ") ? .player1 : .player2
            }
        }
        .onChange(of: viewModel.gamesPerSet) { newValue in
            if selectedSetupMode == 1, lobbyRole == 0, let code = signalRService.lobbyState?.code {
                signalRService.updateSettings(code: code, gamesPerSet: newValue, setsToWin: viewModel.setsToWin, useMatchTiebreak: viewModel.useMatchTiebreak)
            }
        }
        .onChange(of: viewModel.setsToWin) { newValue in
            if selectedSetupMode == 1, lobbyRole == 0, let code = signalRService.lobbyState?.code {
                signalRService.updateSettings(code: code, gamesPerSet: viewModel.gamesPerSet, setsToWin: newValue, useMatchTiebreak: viewModel.useMatchTiebreak)
            }
        }
        .onChange(of: viewModel.useMatchTiebreak) { newValue in
            if selectedSetupMode == 1, lobbyRole == 0, let code = signalRService.lobbyState?.code {
                signalRService.updateSettings(code: code, gamesPerSet: viewModel.gamesPerSet, setsToWin: viewModel.setsToWin, useMatchTiebreak: newValue)
            }
        }
        .onChange(of: signalRService.lobbyState?.settings.gamesPerSet) { newValue in
            if selectedSetupMode == 1, lobbyRole == 1, let val = newValue {
                viewModel.gamesPerSet = val
            }
        }
        .onChange(of: signalRService.lobbyState?.settings.setsToWin) { newValue in
            if selectedSetupMode == 1, lobbyRole == 1, let val = newValue {
                viewModel.setsToWin = val
            }
        }
        .onChange(of: signalRService.lobbyState?.settings.useMatchTiebreak) { newValue in
            if selectedSetupMode == 1, lobbyRole == 1, let val = newValue {
                viewModel.useMatchTiebreak = val
            }
        }
        .onChange(of: signalRService.lobbyState?.code) { newCode in
            if let code = newCode, let lobby = signalRService.lobbyState, lobbyRole == 0 {
                sharePlayManager.startSharing(lobbyCode: code, hostName: lobby.hostName, isDouble: lobby.isDouble)
            }
        }
        .onChange(of: sharePlayManager.receivedLobbyCode) { newCode in
            if let code = newCode, lobbyRole == 1 {
                lobbyCodeInput = code
            }
        }
        .onDisappear {
            sharePlayManager.leaveSession()
            if !viewModel.hasMatchStarted, let code = signalRService.lobbyState?.code {
                signalRService.leaveLobby(code: code)
            }
        }
        .fullScreenCover(isPresented: $showRacketToss) {
            RacketTossView(
                viewModel: viewModel,
                isLiveLobby: selectedSetupMode == 1,
                isHost: lobbyRole == 0,
                onComplete: { startingServer in
                    showRacketToss = false
                    viewModel.startingServer = startingServer
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        if selectedSetupMode == 0 {
                            viewModel.startMatch()
                        } else if let code = signalRService.lobbyState?.code {
                            signalRService.selectTossChoice(code: code, startingServer: startingServer == .player1 ? "p1" : "p2")
                        }
                    }
                },
                onDismiss: {
                    showRacketToss = false
                }
            )
        }
    }
    
    // MARK: - YEREL MAÇ AYARLARI
    private var localMatchView: some View {
        VStack(spacing: 20) {
            // Çiftler Toggle
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ÇİFTLER MAÇI (DOUBLE)")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(.white)
                    Text("4 oyuncu ile kort eşleşmesi")
                        .font(.system(size: 11))
                        .foregroundColor(.zinc500)
                }
                Spacer()
                Toggle("", isOn: $viewModel.isDouble)
                    .labelsHidden()
                    .tint(.tennisVolt)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            
            Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1).padding(.horizontal, 20)
            
            // Oyuncular
            VStack(spacing: 16) {
                // 1. Takım / Oyuncu 1
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.isDouble ? "1. TAKIM • 1. OYUNCU (SİZ)" : "OYUNCU 1 (SİZ)")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.zinc500)
                    
                    TextField("İSİM GİRİN", text: $viewModel.player1Name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.characters)
                }
                .padding(.horizontal, 20)
                
                if viewModel.isDouble {
                    Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("1. TAKIM • 2. OYUNCU (ORTAK)")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.zinc500)
                        
                        TextField("ORTAK İSMİ", text: $viewModel.player1PartnerName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.characters)
                    }
                    .padding(.horizontal, 20)
                }
                
                Rectangle().fill(Color.white.opacity(0.16)).frame(height: 1).padding(.horizontal, 20)
                
                // 2. Takım / Oyuncu 2
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.isDouble ? "2. TAKIM • 1. OYUNCU (RAKİP)" : "OYUNCU 2 (RAKİP)")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.zinc500)
                    
                    TextField("RAKİP İSMİ", text: $viewModel.player2Name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.characters)
                }
                .padding(.horizontal, 20)
                
                if viewModel.isDouble {
                    Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("2. TAKIM • 2. OYUNCU (EŞ)")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.zinc500)
                        
                        TextField("EŞ İSMİ", text: $viewModel.player2PartnerName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.characters)
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1).padding(.horizontal, 20)
            
            // Kural Seçicileri
            CustomSegmentedSelector(
                title: "SET İÇİN GAME SAYISI",
                options: [4, 6],
                unit: "GAME",
                selection: $viewModel.gamesPerSet
            )
            .padding(.horizontal, 20)
            
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.horizontal, 20)
            
            CustomSegmentedSelector(
                title: "KAZANILACAK SET SAYISI",
                options: [1, 2],
                unit: "SET",
                selection: $viewModel.setsToWin
            )
            .padding(.horizontal, 20)
            
            if viewModel.setsToWin > 1 {
                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.horizontal, 20)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SÜPER TIEBREAK (10 PUAN)")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(1.0)
                            .foregroundColor(.white)
                        Text("1-1 beraberlikte karar seti olarak oynanır")
                            .font(.system(size: 11))
                            .foregroundColor(.zinc500)
                    }
                    Spacer()
                    Toggle("", isOn: $viewModel.useMatchTiebreak)
                        .labelsHidden()
                        .tint(.tennisVolt)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - CANLI LOBİ TASARIMI
    private var liveLobbyView: some View {
        VStack(spacing: 20) {
            if signalRService.lobbyState == nil {
                // Role Picker (Editorial)
                HStack(spacing: 28) {
                    Button(action: { lobbyRole = 0 }) {
                        VStack(spacing: 6) {
                            Text("LOBİ KUR")
                                .font(.system(size: 12, weight: lobbyRole == 0 ? .bold : .medium))
                                .tracking(1.2)
                                .foregroundColor(lobbyRole == 0 ? .white : .zinc500)
                            Rectangle()
                                .fill(lobbyRole == 0 ? Color.tennisVolt : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { lobbyRole = 1 }) {
                        VStack(spacing: 6) {
                            Text("LOBİYE KATIL")
                                .font(.system(size: 12, weight: lobbyRole == 1 ? .bold : .medium))
                                .tracking(1.2)
                                .foregroundColor(lobbyRole == 1 ? .white : .zinc500)
                            Rectangle()
                                .fill(lobbyRole == 1 ? Color.tennisVolt : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1).padding(.horizontal, 20)
                
                // Çiftler Maçı Seçimi
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ÇİFTLER MAÇI (4 KİŞİ)")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(1.0)
                            .foregroundColor(.white)
                        Text("4 ayrı oyuncu kendi telefonlarıyla lobiye bağlanabilir")
                            .font(.system(size: 11))
                            .foregroundColor(.zinc500)
                    }
                    Spacer()
                    Toggle("", isOn: $viewModel.isDouble)
                        .labelsHidden()
                        .tint(.tennisVolt)
                }
                .padding(.horizontal, 20)
                
                if viewModel.isDouble && lobbyRole == 0 {
                    Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ORTAĞINIZIN ADI (İSTEĞE BAĞLI)")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.zinc500)
                        TextField("TELEFONDAN BAĞLANABİLİR VEYA ELLE YAZIN", text: $viewModel.player1PartnerName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.characters)
                    }
                    .padding(.horizontal, 20)
                }
                
                if lobbyRole == 1 {
                    // SharePlay Yakınlaşma ile Algılanan Lobi Kartı
                    if let detectedCode = sharePlayManager.receivedLobbyCode {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "shareplay")
                                    .font(.system(size: 14))
                                    .foregroundColor(.tennisVolt)
                                Text("YAKINDAKİ COURT LOBİSİ ALGILANDI")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.0)
                                    .foregroundColor(.tennisVolt)
                                Spacer()
                            }
                            
                            HStack {
                                Text(detectedCode)
                                    .font(.system(size: 22, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                    .tracking(2)
                                
                                Spacer()
                                
                                Button(action: {
                                    let name = authManager.currentUser?.fullName ?? "OYUNCU"
                                    signalRService.joinLobbySlot(code: detectedCode, name: name, profileImageUrl: authManager.currentUser?.profileImageUrl)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "bolt.fill")
                                        Text("ANINDA KATIL")
                                    }
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.tennisVolt)
                                    .foregroundColor(.black)
                                    .cornerRadius(6)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.zinc900)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tennisVolt.opacity(0.4), lineWidth: 1))
                        .padding(.horizontal, 20)
                    }
                    
                    Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("LOBİ KODU")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.zinc500)
                        TextField("6 HANELİ KOD", text: $lobbyCodeInput)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.tennisVolt)
                            .textInputAutocapitalization(.characters)
                    }
                    .padding(.horizontal, 20)
                }
                
                if let error = signalRService.errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.statusRed)
                        .padding(.horizontal, 20)
                }
            } else if let lobby = signalRService.lobbyState {
                VStack(spacing: 16) {
                    // Lobi Kodu & Ayrılma Butonu
                    VStack(spacing: 8) {
                        HStack {
                            Text("LOBİ KODU")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2.0)
                                .foregroundColor(.zinc500)
                            
                            Spacer()
                            
                            Button(action: {
                                signalRService.leaveLobby(code: lobby.code)
                                sharePlayManager.leaveSession()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "xmark.circle.fill")
                                    Text(lobbyRole == 0 ? "LOBİYİ KAPAT" : "LOBİDEN AYRIL")
                                }
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.statusRed)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.statusRed.opacity(0.12))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            Text(lobby.code)
                                .font(.system(size: 34, weight: .black, design: .monospaced))
                                .foregroundColor(.tennisVolt)
                                .tracking(4)
                            
                            Button(action: {
                                UIPasteboard.general.string = lobby.code
                                copiedCodeFeedback = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    copiedCodeFeedback = false
                                }
                            }) {
                                Image(systemName: copiedCodeFeedback ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(copiedCodeFeedback ? .tennisVolt : .zinc400)
                                    .padding(8)
                                    .background(Color.zinc850)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Ayrılan Oyuncu Bildirimi
                    if let notification = signalRService.notificationMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.xmark")
                                .font(.system(size: 14))
                                .foregroundColor(.badgeAmber)
                            Text(notification)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(10)
                        .background(Color.badgeAmber.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.badgeAmber.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                    }
                    
                    // SharePlay Yakınlaşma (Proximity) Banner'ı
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.tennisVolt.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "wave.3.forward.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.tennisVolt)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("SHAREPLAY İLE YAKINLAŞTIRIN")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.0)
                                .foregroundColor(.white)
                            Text(lobby.isDouble ? "Telefonları tepe kısımlarından yaklaştırarak 4 kişiye kadar lobiye dahil edin." : "Telefonları yaklaştırarak rakibi anında lobiye bağlayın.")
                                .font(.system(size: 10))
                                .foregroundColor(.zinc400)
                        }
                        Spacer()
                        if sharePlayManager.activeParticipantsCount > 1 {
                            Text("\(sharePlayManager.activeParticipantsCount) Cihaz")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.tennisVolt.opacity(0.2))
                                .foregroundColor(.tennisVolt)
                                .cornerRadius(4)
                        }
                    }
                    .padding(12)
                    .background(Color.zinc900)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.zinc800, lineWidth: 1))
                    .padding(.horizontal, 20)
                    
                    // 4 SLOTLU KORT YERLEŞİMİ (Interactive Court Layout)
                    VStack(spacing: 12) {
                        HStack {
                            Text(lobby.isDouble ? "KORT YERLEŞİMİ (4 KİŞİLİK LOBİ)" : "KORT YERLEŞİMİ (TEKLER)")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(.zinc500)
                            Spacer()
                            Text("BOŞ SLOTA TIKLAYARAK GEÇEBİLİRSİNİZ")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.zinc600)
                        }
                        .padding(.horizontal, 4)
                        
                        // TAKIM 1 (Kurucu & Ortak)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("TAKIM 1")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(1.0)
                                    .foregroundColor(.tennisVolt)
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                slotCard(slot: 0, title: "KURUCU (P1)", lobby: lobby)
                                if lobby.isDouble {
                                    slotCard(slot: 1, title: "ORTAK (P2)", lobby: lobby)
                                }
                            }
                        }
                        
                        // NET / FİLE ÇİZGİSİ
                        HStack(spacing: 8) {
                            Rectangle().fill(Color.zinc800).frame(height: 1)
                            Text("NET")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.zinc600)
                            Rectangle().fill(Color.zinc800).frame(height: 1)
                        }
                        .padding(.vertical, 2)
                        
                        // TAKIM 2 (Rakip 1 & Rakip 2)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("TAKIM 2")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(1.0)
                                    .foregroundColor(.zinc400)
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                slotCard(slot: 2, title: lobby.isDouble ? "RAKİP 1 (P3)" : "RAKİP (P2)", lobby: lobby)
                                if lobby.isDouble {
                                    slotCard(slot: 3, title: "RAKİP 2 (P4)", lobby: lobby)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.zinc900.opacity(0.7))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.zinc800, lineWidth: 1))
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // Slot Kartı Görünümü
    private func slotCard(slot: Int, title: String, lobby: LobbyState) -> some View {
        let player = playerInSlot(slot, lobby: lobby)
        let isOccupied = player != nil
        let isHost = slot == 0
        
        return Button(action: {
            if !isOccupied {
                signalRService.switchSlot(code: lobby.code, targetSlotIndex: slot)
            }
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(isHost ? .tennisVolt : .zinc500)
                    Spacer()
                    if isHost {
                        Text("KURUCU")
                            .font(.system(size: 8, weight: .black))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.tennisVolt)
                            .foregroundColor(.black)
                            .cornerRadius(3)
                    } else if isOccupied {
                        Circle()
                            .fill(Color.courtGreen)
                            .frame(width: 6, height: 6)
                    }
                }
                
                if let p = player {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.zinc800)
                                .frame(width: 28, height: 28)
                            Text(String(p.name.prefix(1)).uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(p.name.uppercased())
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.dashed")
                            .font(.system(size: 13))
                            .foregroundColor(.zinc500)
                        Text("BU SLOTA GEÇ")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.zinc500)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isOccupied ? Color.zinc850 : Color.zinc900.opacity(0.6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isOccupied ? Color.zinc700 : Color.zinc800, style: StrokeStyle(lineWidth: 1, dash: isOccupied ? [] : [4]))
            )
        }
        .buttonStyle(.plain)
    }

    private func playerInSlot(_ slot: Int, lobby: LobbyState) -> LobbyPlayer? {
        if let p = lobby.playerAt(slot: slot) {
            return p
        }
        switch slot {
        case 0:
            return LobbyPlayer(connectionId: "host", userId: nil, name: lobby.hostName, profileImageUrl: lobby.hostProfileImageUrl, team: 1, slotIndex: 0, isHost: true, isReady: true)
        case 1:
            if lobby.isDouble, let name = lobby.hostPartnerName, !name.isEmpty {
                return LobbyPlayer(connectionId: "p1_partner", userId: nil, name: name, profileImageUrl: nil, team: 1, slotIndex: 1, isHost: false, isReady: true)
            }
        case 2:
            if let name = lobby.guestName, !name.isEmpty {
                return LobbyPlayer(connectionId: "guest", userId: nil, name: name, profileImageUrl: lobby.guestProfileImageUrl, team: 2, slotIndex: 2, isHost: false, isReady: true)
            }
        case 3:
            if lobby.isDouble, let name = lobby.guestPartnerName, !name.isEmpty {
                return LobbyPlayer(connectionId: "p2_partner", userId: nil, name: name, profileImageUrl: nil, team: 2, slotIndex: 3, isHost: false, isReady: true)
            }
        default:
            return nil
        }
        return nil
    }

    private func totalPlayerCount(_ lobby: LobbyState) -> Int {
        if let players = lobby.players, !players.isEmpty {
            return players.count
        }
        var count = 1
        if lobby.guestName != nil { count += 1 }
        if lobby.isDouble {
            if lobby.hostPartnerName != nil { count += 1 }
            if lobby.guestPartnerName != nil { count += 1 }
        }
        return count
    }
    
    // MARK: - AKSİYON BUTONU
    private var actionButton: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
            
            Group {
                if selectedSetupMode == 0 {
                    Button(action: {
                        showRacketToss = true
                    }) {
                        buttonContent(title: "Maçı Başlat", icon: "play.fill")
                    }
                } else if signalRService.lobbyState == nil {
                    if lobbyRole == 0 {
                        Button(action: {
                            let name = authManager.currentUser?.fullName ?? "OYUNCU 1"
                            signalRService.createLobby(hostName: name, isDouble: viewModel.isDouble, hostPartnerName: viewModel.isDouble ? viewModel.player1PartnerName : nil, hostProfileImageUrl: authManager.currentUser?.profileImageUrl)
                        }) {
                            buttonContent(title: viewModel.isDouble ? "4 Kişilik Lobi Oluştur" : "Lobi Oluştur", icon: "plus")
                        }
                    } else {
                        Button(action: {
                            guard !lobbyCodeInput.isEmpty else { return }
                            let name = authManager.currentUser?.fullName ?? "OYUNCU 2"
                            signalRService.joinLobbySlot(code: lobbyCodeInput, name: name, profileImageUrl: authManager.currentUser?.profileImageUrl)
                        }) {
                            buttonContent(title: "Lobiye Bağlan", icon: "link")
                        }
                    }
                } else if let lobby = signalRService.lobbyState {
                    if lobbyRole == 0 {
                        let canStart = (lobby.guestName != nil) || (lobby.playerAt(slot: 2) != nil)
                        Button(action: {
                            signalRService.startToss(code: lobby.code)
                        }) {
                            buttonContent(title: "Canlı Maçı Başlat (\(totalPlayerCount(lobby))/\(lobby.isDouble ? 4 : 2) Oyuncu)", icon: "play.fill")
                        }
                        .disabled(!canStart)
                        .opacity(!canStart ? 0.35 : 1.0)
                    } else {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .zinc400))
                                .scaleEffect(0.8)
                            Text("KURUCUNUN MAÇI BAŞLATMASI BEKLENİYOR")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.zinc400)
                                .tracking(1.0)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color.zinc900)
                        .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.zinc950)
    }
    
    private func buttonContent(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
            Text(title.uppercased())
                .font(.system(size: 13, weight: .bold))
                .tracking(1.5)
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(Color.tennisVolt)
    }
}

// MARK: - Editorial Custom Segmented Selector
struct CustomSegmentedSelector: View {
    let title: String
    let options: [Int]
    var unit: String = ""
    @Binding var selection: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.zinc500)
            
            HStack(spacing: 24) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(selection == option ? Color.tennisVolt : Color.clear)
                                .frame(width: 6, height: 6)
                            
                            Text("\(option) \(unit)")
                                .font(.system(size: 13, weight: selection == option ? .bold : .medium, design: .monospaced))
                                .tracking(1.0)
                                .foregroundColor(selection == option ? .white : .zinc500)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
