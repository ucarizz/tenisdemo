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
                    Spacer(minLength: 16)
                    
                    // Logo / Başlık
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "tennisball.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                        }
                        
                        Text("MAÇ KURULUMU")
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                            .tracking(2)
                    }
                    .padding(.bottom, 4)
                    
                    // Maç Tipi Seçimi
                    Picker("Maç Tipi", selection: $selectedSetupMode) {
                        Text("Yerel Maç").tag(0)
                        Text("Canlı Lobi").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    
                    if selectedSetupMode == 0 {
                        // YEREL MAÇ AYARLARI
                        localMatchView
                    } else {
                        // CANLI LOBİ AYARLARI
                        liveLobbyView
                    }
                    
                    Spacer(minLength: 24)
                }
            }
            
            // Alt Buton (Maçı Başlat / Katıl / Bağlan)
            actionButton
        }
        .onChange(of: signalRService.isMatchStarted) { started in
            if started, let lobby = signalRService.lobbyState {
                // Maç başladığında isimleri ve kuralları viewmodel'a yükle
                viewModel.player1Name = lobby.hostName
                viewModel.player1PartnerName = lobby.hostPartnerName ?? ""
                viewModel.player2Name = lobby.guestName ?? "RAKİP"
                viewModel.player2PartnerName = lobby.guestPartnerName ?? ""
                viewModel.isDouble = lobby.isDouble
                viewModel.gamesPerSet = lobby.settings.gamesPerSet
                viewModel.setsToWin = lobby.settings.setsToWin
                viewModel.useMatchTiebreak = lobby.settings.useMatchTiebreak
                
                withAnimation(.spring()) {
                    viewModel.startMatch()
                }
            }
        }
        // Kurucu ayarları değiştirdikçe karşıya gönder
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
        // Katılımcı iken kurucunun değiştirdiği ayarları local viewmodel'a senkronize et
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
    
    // YEREL MAÇ TASARIMI
    private var localMatchView: some View {
        VStack(spacing: 20) {
            Toggle(isOn: $viewModel.isDouble) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Çiftler Maçı (Double)")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                    Text("4 oyuncu ile oynanır")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))
            .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.isDouble ? "1. Takım - 1. Oyuncu (Siz)" : "Oyuncu 1 Adı (Siz)")
                        .font(.system(.caption, design: .rounded))
                        .bold()
                        .foregroundColor(.gray)
                    TextField("SİZ", text: $viewModel.player1Name)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        .textInputAutocapitalization(.characters)
                }
                
                if viewModel.isDouble {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("1. Takım - 2. Oyuncu (Ortak)")
                            .font(.system(.caption, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                        TextField("ORTAK 1", text: $viewModel.player1PartnerName)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            .textInputAutocapitalization(.characters)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.isDouble ? "2. Takım - 1. Oyuncu (Rakip)" : "Oyuncu 2 Adı (Rakip)")
                        .font(.system(.caption, design: .rounded))
                        .bold()
                        .foregroundColor(.gray)
                    TextField("RAKİP", text: $viewModel.player2Name)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        .textInputAutocapitalization(.characters)
                }
                
                if viewModel.isDouble {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("2. Takım - 2. Oyuncu (Eş)")
                            .font(.system(.caption, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                        TextField("ORTAK 2", text: $viewModel.player2PartnerName)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            .textInputAutocapitalization(.characters)
                    }
                }
            }
            
            CustomSegmentedSelector(
                title: "Set Kazanmak İçin Game Sayısı",
                options: [4, 6],
                selection: $viewModel.gamesPerSet,
                color: Color.emerald
            )
            
            CustomSegmentedSelector(
                title: "Kazanılması Gereken Set Sayısı",
                options: [1, 2],
                selection: $viewModel.setsToWin,
                color: Color(red: 0.95, green: 0.45, blue: 0.15)
            )
            
            if viewModel.setsToWin > 1 {
                Toggle(isOn: $viewModel.useMatchTiebreak) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Süper Tiebreak (10 Puan)")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                        Text("1-1 beraberlikte 3. set yerine oynanır")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))
                .padding()
                .background(Color.white.opacity(0.04))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
            }
        }
        .padding(.horizontal)
    }
    
    // CANLI LOBİ TASARIMI
    private var liveLobbyView: some View {
        VStack(spacing: 20) {
            if signalRService.lobbyState == nil {
                // LOBİ KATILMA/KURMA SEÇİM EKRANI
                Picker("Rol", selection: $lobbyRole) {
                    Text("Lobi Kur").tag(0)
                    Text("Lobiye Katıl").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Toggle(isOn: $viewModel.isDouble) {
                    Text("Çiftler Maçı (Double)")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))
                .padding(.horizontal, 4)
                
                if viewModel.isDouble {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ortağınızın Adı")
                            .font(.system(.caption, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                        TextField("EŞ", text: lobbyRole == 0 ? $viewModel.player1PartnerName : $viewModel.player2PartnerName)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            .textInputAutocapitalization(.characters)
                    }
                }
                
                if lobbyRole == 1 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Lobi Kodu")
                            .font(.system(.caption, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                        TextField("6 Haneli Kod (Örn: AB12CD)", text: $lobbyCodeInput)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            .textInputAutocapitalization(.characters)
                    }
                }
                
                if let error = signalRService.errorMessage {
                    Text(error)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            } else if let lobby = signalRService.lobbyState {
                // AKTİF LOBİ ODA EKRANI (BAĞLANDIKTAN SONRA)
                VStack(spacing: 24) {
                    // Oda Kodu Kartı
                    VStack(spacing: 8) {
                        Text("LOBİ KODU")
                            .font(.system(.caption2, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        Text(lobby.code)
                            .font(.system(.title, design: .rounded))
                            .bold()
                            .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                            .tracking(4)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    
                    // Oyuncular / Takımlar Durumu
                    HStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("1. TAKIM (Kurucu)")
                                .font(.system(.caption2, design: .rounded))
                                .bold()
                                .foregroundColor(.emerald)
                            
                            if let urlStr = lobby.hostProfileImageUrl,
                               let url = URL(string: urlStr) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.emerald.opacity(0.6), lineWidth: 1.5))
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.emerald)
                            }
                            
                            Text(lobby.hostName)
                                .font(.system(.body, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                            
                            if lobby.isDouble {
                                Text("& \(lobby.hostPartnerName ?? "ORTAK")")
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                        
                        Text("VS")
                            .font(.system(.headline, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            Text("2. TAKIM (Misafir)")
                                .font(.system(.caption2, design: .rounded))
                                .bold()
                                .foregroundColor(Color(red: 0.95, green: 0.45, blue: 0.15))
                            
                            if let guest = lobby.guestName {
                                if let urlStr = lobby.guestProfileImageUrl,
                                   let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color(red: 0.95, green: 0.45, blue: 0.15).opacity(0.6), lineWidth: 1.5))
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                    }
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(red: 0.95, green: 0.45, blue: 0.15))
                                }
                                
                                Text(guest)
                                    .font(.system(.body, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                
                                if lobby.isDouble {
                                    Text("& \(lobby.guestPartnerName ?? "ORTAK")")
                                        .font(.system(.footnote, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .padding(.vertical, 2)
                                Text("Rakip Bekleniyor...")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                    }
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    // Maç Kuralları (Kurucu değiştirebilir, katılımcı sadece izler)
                    VStack(spacing: 16) {
                        if lobbyRole == 0 {
                            // Kurucu için interaktif ayarlar
                            CustomSegmentedSelector(
                                title: "Set Kazanmak İçin Game Sayısı",
                                options: [4, 6],
                                selection: $viewModel.gamesPerSet,
                                color: Color.emerald
                            )
                            
                            CustomSegmentedSelector(
                                title: "Kazanılması Gereken Set Sayısı",
                                options: [1, 2],
                                selection: $viewModel.setsToWin,
                                color: Color(red: 0.95, green: 0.45, blue: 0.15)
                            )
                            
                            if viewModel.setsToWin > 1 {
                                Toggle(isOn: $viewModel.useMatchTiebreak) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Süper Tiebreak (10 Puan)")
                                            .font(.system(.body, design: .rounded))
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))
                                .padding()
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(12)
                            }
                        } else {
                            // Katılımcı için salt okunur ayarlar
                            VStack(alignment: .leading, spacing: 12) {
                                Text("MAÇ KURALLARI")
                                    .font(.system(.caption, design: .rounded))
                                    .bold()
                                    .foregroundColor(.gray)
                                
                                    HStack {
                                        Text("Set Başına Oyun:")
                                        Spacer()
                                        Text("\(lobby.settings.gamesPerSet)").bold()
                                    }
                                    HStack {
                                        Text("Kazanılması Gereken Set:")
                                        Spacer()
                                        Text("\(lobby.settings.setsToWin)").bold()
                                    }
                                    HStack {
                                        Text("Süper Tiebreak:")
                                        Spacer()
                                        Text(lobby.settings.useMatchTiebreak ? "Açık" : "Kapalı").bold()
                                    }
                            }
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(12)
                            
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.86, green: 0.98, blue: 0.22)))
                                    .padding(.trailing, 8)
                                Text("Kurucunun maçı başlatması bekleniyor...")
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.top, 12)
                        }
                    }
                    
                    // Lobiden Çık Butonu
                    Button(action: {
                        signalRService.leaveLobby(code: lobby.code)
                    }) {
                        Text("Lobiden Ayrıl")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.red)
                            .bold()
                            .padding()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // AKTİF AKSİYON BUTONU
    private var actionButton: some View {
        Group {
            if selectedSetupMode == 0 {
                // Yerel Maç Başlat
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.startMatch()
                    }
                }) {
                    buttonContent(title: "Maçı Başlat", icon: "play.fill", color: Color(red: 0.86, green: 0.98, blue: 0.22))
                }
            } else if signalRService.lobbyState == nil {
                // Lobi Kur / Katıl Butonu
                if lobbyRole == 0 {
                    Button(action: {
                        let name = authManager.currentUser?.fullName ?? "OYUNCU 1"
                        signalRService.createLobby(hostName: name, isDouble: viewModel.isDouble, hostPartnerName: viewModel.isDouble ? viewModel.player1PartnerName : nil, hostProfileImageUrl: authManager.currentUser?.profileImageUrl)
                    }) {
                        buttonContent(title: "Lobi Oluştur", icon: "plus.circle.fill", color: Color(red: 0.86, green: 0.98, blue: 0.22))
                    }
                } else {
                    Button(action: {
                        guard !lobbyCodeInput.isEmpty else { return }
                        let name = authManager.currentUser?.fullName ?? "OYUNCU 2"
                        signalRService.joinLobby(code: lobbyCodeInput, guestName: name, guestPartnerName: viewModel.isDouble ? viewModel.player2PartnerName : nil, guestProfileImageUrl: authManager.currentUser?.profileImageUrl)
                    }) {
                        buttonContent(title: "Lobiye Bağlan", icon: "link", color: Color.emerald)
                    }
                }
            } else if let lobby = signalRService.lobbyState, lobbyRole == 0 {
                // Kurucu İçin Maçı Başlat Butonu
                Button(action: {
                    signalRService.startMatch(code: lobby.code)
                }) {
                    buttonContent(title: "Canlı Maçı Başlat", icon: "play.fill", color: Color(red: 0.86, green: 0.98, blue: 0.22))
                }
                .disabled(lobby.guestName == nil)
                .opacity(lobby.guestName == nil ? 0.5 : 1.0)
            } else {
                EmptyView()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(Color.black.edgesIgnoringSafeArea(.bottom))
    }
    
    private func buttonContent(title: String, icon: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(.body, design: .rounded))
                .bold()
            Image(systemName: icon)
                .font(.system(size: 14))
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(color)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.3), radius: 10, y: 5)
    }
}

struct CustomSegmentedSelector: View {
    let title: String
    let options: [Int]
    @Binding var selection: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .bold()
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
            
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.interactiveSpring()) {
                            selection = option
                        }
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                        Text("\(option)")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(selection == option ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(selection == option ? color : Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selection == option ? color : Color.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
