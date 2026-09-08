import SwiftUI

struct SetupMatchView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    
    @StateObject private var signalRService = SignalRService.shared
    @StateObject private var authManager = AuthManager.shared
    
    @State private var selectedSetupMode = 0 // 0: Yerel Maç, 1: Canlı Lobi
    @State private var lobbyRole = 0 // 0: Lobi Kur, 1: Lobiye Katıl
    @State private var lobbyCodeInput = ""
    @State private var localError = ""
    
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
                viewModel.player1Name = lobby.hostName
                viewModel.player1PartnerName = lobby.hostPartnerName ?? ""
                viewModel.player2Name = lobby.guestName ?? "RAKİP"
                viewModel.player2PartnerName = lobby.guestPartnerName ?? ""
                viewModel.isDouble = lobby.isDouble
                viewModel.gamesPerSet = lobby.settings.gamesPerSet
                viewModel.setsToWin = lobby.settings.setsToWin
                viewModel.useMatchTiebreak = lobby.settings.useMatchTiebreak
                
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    viewModel.startMatch()
                }
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
                
                HStack {
                    Text("ÇİFTLER MAÇI (DOUBLE)")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $viewModel.isDouble)
                        .labelsHidden()
                        .tint(.tennisVolt)
                }
                .padding(.horizontal, 20)
                
                if viewModel.isDouble {
                    Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ORTAĞINIZIN ADI")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.zinc500)
                        TextField("ORTAK İSMİ", text: lobbyRole == 0 ? $viewModel.player1PartnerName : $viewModel.player2PartnerName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.characters)
                    }
                    .padding(.horizontal, 20)
                }
                
                if lobbyRole == 1 {
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
                VStack(spacing: 20) {
                    // Lobi Kodu Editorial Gösterimi
                    VStack(spacing: 8) {
                        Text("LOBİ KODU")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2.0)
                            .foregroundColor(.zinc500)
                        
                        Text(lobby.code)
                            .font(.system(size: 36, weight: .black, design: .monospaced))
                            .foregroundColor(.tennisVolt)
                            .tracking(4)
                    }
                    .padding(.vertical, 16)
                    
                    Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1).padding(.horizontal, 20)
                    
                    // Oyuncular
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("KURUCU")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(.zinc500)
                            Text(lobby.hostName.uppercased())
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("VS")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.zinc600)
                            .padding(.horizontal, 12)
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("MİSAFİR")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(.zinc500)
                            Text((lobby.guestName ?? "Bekleniyor...").uppercased())
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(lobby.guestName != nil ? .white : .zinc600)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
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
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            viewModel.startMatch()
                        }
                    }) {
                        buttonContent(title: "Maçı Başlat", icon: "play.fill")
                    }
                } else if signalRService.lobbyState == nil {
                    if lobbyRole == 0 {
                        Button(action: {
                            let name = authManager.currentUser?.fullName ?? "OYUNCU 1"
                            signalRService.createLobby(hostName: name, isDouble: viewModel.isDouble, hostPartnerName: viewModel.isDouble ? viewModel.player1PartnerName : nil, hostProfileImageUrl: authManager.currentUser?.profileImageUrl)
                        }) {
                            buttonContent(title: "Lobi Oluştur", icon: "plus")
                        }
                    } else {
                        Button(action: {
                            guard !lobbyCodeInput.isEmpty else { return }
                            let name = authManager.currentUser?.fullName ?? "OYUNCU 2"
                            signalRService.joinLobby(code: lobbyCodeInput, guestName: name, guestPartnerName: viewModel.isDouble ? viewModel.player2PartnerName : nil, guestProfileImageUrl: authManager.currentUser?.profileImageUrl)
                        }) {
                            buttonContent(title: "Lobiye Bağlan", icon: "link")
                        }
                    }
                } else if let lobby = signalRService.lobbyState, lobbyRole == 0 {
                    Button(action: {
                        signalRService.startMatch(code: lobby.code)
                    }) {
                        buttonContent(title: "Canlı Maçı Başlat", icon: "play.fill")
                    }
                    .disabled(lobby.guestName == nil)
                    .opacity(lobby.guestName == nil ? 0.35 : 1.0)
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
