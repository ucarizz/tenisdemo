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
                VStack(spacing: 16) {
                    // Minimal Linear Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Yeni Maç")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.zinc100)
                        Text("Maç modunu ve oyuncuları yapılandırın.")
                            .font(.system(size: 13))
                            .foregroundColor(.zinc500)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Mode Selector (Segmented Tab Bar)
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                selectedSetupMode = 0
                            }
                        }) {
                            Text("Yerel Maç")
                                .font(.system(size: 13, weight: selectedSetupMode == 0 ? .semibold : .medium))
                                .foregroundColor(selectedSetupMode == 0 ? .zinc100 : .zinc500)
                                .frame(maxWidth: .infinity)
                                .frame(height: 34)
                                .background(selectedSetupMode == 0 ? Color.zinc800 : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                selectedSetupMode = 1
                            }
                        }) {
                            Text("Canlı Lobi")
                                .font(.system(size: 13, weight: selectedSetupMode == 1 ? .semibold : .medium))
                                .foregroundColor(selectedSetupMode == 1 ? .zinc100 : .zinc500)
                                .frame(maxWidth: .infinity)
                                .frame(height: 34)
                                .background(selectedSetupMode == 1 ? Color.zinc800 : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(3)
                    .background(Color.zinc900)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    
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
        VStack(spacing: 14) {
            // Çiftler Toggle Kartı
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Çiftler Maçı (Double)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.zinc200)
                    Text("4 oyuncu ile oynanır")
                        .font(.system(size: 12))
                        .foregroundColor(.zinc500)
                }
                Spacer()
                Toggle("", isOn: $viewModel.isDouble)
                    .labelsHidden()
                    .tint(.zinc400)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.zinc900)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.zinc800, lineWidth: 1)
            )
            
            // Oyuncu İsimleri
            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.isDouble ? "1. Takım - 1. Oyuncu (Siz)" : "Oyuncu 1 Adı (Siz)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.zinc500)
                    TextField("SİZ", text: $viewModel.player1Name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.zinc100)
                        .padding(.horizontal, 12)
                        .frame(height: 38)
                        .background(Color.zinc900)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                        .textInputAutocapitalization(.characters)
                }
                
                if viewModel.isDouble {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("1. Takım - 2. Oyuncu (Ortak)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.zinc500)
                        TextField("ORTAK 1", text: $viewModel.player1PartnerName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc100)
                            .padding(.horizontal, 12)
                            .frame(height: 38)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            .textInputAutocapitalization(.characters)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.isDouble ? "2. Takım - 1. Oyuncu (Rakip)" : "Oyuncu 2 Adı (Rakip)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.zinc500)
                    TextField("RAKİP", text: $viewModel.player2Name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.zinc100)
                        .padding(.horizontal, 12)
                        .frame(height: 38)
                        .background(Color.zinc900)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                        .textInputAutocapitalization(.characters)
                }
                
                if viewModel.isDouble {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("2. Takım - 2. Oyuncu (Eş)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.zinc500)
                        TextField("ORTAK 2", text: $viewModel.player2PartnerName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc100)
                            .padding(.horizontal, 12)
                            .frame(height: 38)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            .textInputAutocapitalization(.characters)
                    }
                }
            }
            
            // Kural Seçicileri
            CustomSegmentedSelector(
                title: "Set Kazanmak İçin Game Sayısı",
                options: [4, 6],
                selection: $viewModel.gamesPerSet
            )
            
            CustomSegmentedSelector(
                title: "Kazanılması Gereken Set Sayısı",
                options: [1, 2],
                selection: $viewModel.setsToWin
            )
            
            if viewModel.setsToWin > 1 {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Süper Tiebreak (10 Puan)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc200)
                        Text("1-1 beraberlikte 3. set yerine oynanır")
                            .font(.system(size: 12))
                            .foregroundColor(.zinc500)
                    }
                    Spacer()
                    Toggle("", isOn: $viewModel.useMatchTiebreak)
                        .labelsHidden()
                        .tint(.zinc400)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.zinc900)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - CANLI LOBİ TASARIMI
    private var liveLobbyView: some View {
        VStack(spacing: 14) {
            if signalRService.lobbyState == nil {
                // Role Picker
                HStack(spacing: 0) {
                    Button(action: { lobbyRole = 0 }) {
                        Text("Lobi Kur")
                            .font(.system(size: 13, weight: lobbyRole == 0 ? .semibold : .medium))
                            .foregroundColor(lobbyRole == 0 ? .zinc100 : .zinc500)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(lobbyRole == 0 ? Color.zinc800 : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { lobbyRole = 1 }) {
                        Text("Lobiye Katıl")
                            .font(.system(size: 13, weight: lobbyRole == 1 ? .semibold : .medium))
                            .foregroundColor(lobbyRole == 1 ? .zinc100 : .zinc500)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(lobbyRole == 1 ? Color.zinc800 : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                }
                .padding(3)
                .background(Color.zinc900)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
                
                HStack {
                    Text("Çiftler Maçı (Double)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.zinc200)
                    Spacer()
                    Toggle("", isOn: $viewModel.isDouble)
                        .labelsHidden()
                        .tint(.zinc400)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.zinc900)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
                
                if viewModel.isDouble {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Ortağınızın Adı")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.zinc500)
                        TextField("EŞ", text: lobbyRole == 0 ? $viewModel.player1PartnerName : $viewModel.player2PartnerName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc100)
                            .padding(.horizontal, 12)
                            .frame(height: 38)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            .textInputAutocapitalization(.characters)
                    }
                }
                
                if lobbyRole == 1 {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Lobi Kodu")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.zinc500)
                        TextField("6 Haneli Kod (Örn: AB12CD)", text: $lobbyCodeInput)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.zinc100)
                            .padding(.horizontal, 12)
                            .frame(height: 38)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            .textInputAutocapitalization(.characters)
                    }
                }
                
                if let error = signalRService.errorMessage {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.statusRed)
                }
            } else if let lobby = signalRService.lobbyState {
                VStack(spacing: 16) {
                    // Lobi Kodu Kartı
                    VStack(spacing: 6) {
                        Text("LOBİ KODU")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc500)
                        
                        Text(lobby.code)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc50)
                            .tracking(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.zinc900)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                    
                    // Oyuncular
                    HStack(spacing: 12) {
                        VStack(spacing: 6) {
                            Text("1. Takım (Kurucu)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.zinc500)
                            Text(lobby.hostName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.zinc100)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.zinc900)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                        
                        Text("VS")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc500)
                        
                        VStack(spacing: 6) {
                            Text("2. Takım (Misafir)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.zinc500)
                            Text(lobby.guestName ?? "Bekleniyor...")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(lobby.guestName != nil ? .zinc100 : .zinc600)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.zinc900)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - AKSİYON BUTONU
    private var actionButton: some View {
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
                .opacity(lobby.guestName == nil ? 0.4 : 1.0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(Color.zinc950)
    }
    
    private func buttonContent(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(title)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.zinc950)
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background(Color.zinc50)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.zinc300, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Minimal Linear Custom Segmented Selector
struct CustomSegmentedSelector: View {
    let title: String
    let options: [Int]
    @Binding var selection: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.zinc500)
            
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                        Text("\(option)")
                            .font(.system(size: 13, weight: selection == option ? .bold : .medium, design: .monospaced))
                            .foregroundColor(selection == option ? .zinc950 : .zinc400)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(selection == option ? Color.zinc100 : Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(selection == option ? Color.zinc300 : Color.zinc800, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
