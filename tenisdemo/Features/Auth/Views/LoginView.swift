import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var otpCode = ""
    @State private var fullName = ""
    @State private var errorMessage = ""
    @State private var authStep: AuthStep = .emailInput
    @State private var resendTimer = 60
    @State private var timerActive = false
    @State private var timer: Timer? = nil
    
    @FocusState private var isOtpFieldFocused: Bool
    
    enum AuthStep {
        case emailInput
        case otpInput
        case nameInput
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.zinc950.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        Spacer(minLength: 40)
                        
                        // Logo ve Başlık
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.zinc900)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.zinc800, lineWidth: 1)
                                    )
                                
                                Image(systemName: "tennisball.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.zinc100)
                            }
                            
                            if authStep == .nameInput {
                                Text("Profil Oluştur")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.zinc50)
                                
                                Text("Ligi takip etmek için bilgilerinizi tamamlayın.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.zinc400)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            } else {
                                Text("Tenis Ligi")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.zinc50)
                                
                                Text(authStep == .otpInput ? "E-postanıza gelen 6 haneli doğrulama kodunu girin." : "Maçlarını takip et, skorları canlı paylaş.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.zinc400)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Form Adımları
                        switch authStep {
                        case .emailInput:
                            emailInputView
                        case .otpInput:
                            otpInputView
                        case .nameInput:
                            nameInputView
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    // E-posta Adresi Giriş Ekranı
    private var emailInputView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("E-POSTA ADRESİNİZ")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.zinc400)
                
                TextField("ornek@eposta.com", text: $email)
                    .font(.system(size: 14))
                    .foregroundColor(.zinc100)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.zinc900)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 24)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.statusRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: {
                sendOtpCode()
            }) {
                HStack(spacing: 8) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .zinc950))
                    } else {
                        Text("Doğrulama Kodu Gönder")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .foregroundColor(.zinc950)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.zinc50)
                .cornerRadius(6)
            }
            .disabled(authManager.isLoading || email.isEmpty)
            .opacity((authManager.isLoading || email.isEmpty) ? 0.5 : 1.0)
            .padding(.horizontal, 24)
            .padding(.top, 4)
        }
    }
    
    // OTP Doğrulama Kod Ekranı
    private var otpInputView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("GÖNDERİLEN E-POSTA")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.zinc400)
                
                HStack(spacing: 6) {
                    Text(email)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.zinc100)
                    
                    Button(action: {
                        authStep = .emailInput
                        otpCode = ""
                        errorMessage = ""
                    }) {
                        Text("Düzenle")
                            .font(.system(size: 12))
                            .foregroundColor(.zinc400)
                            .underline()
                    }
                }
            }
            
            // OTP Kutu Girişleri
            ZStack {
                TextField("", text: $otpCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .opacity(0.01)
                    .frame(width: 1, height: 1)
                    .focused($isOtpFieldFocused)
                    .onChange(of: otpCode) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count > 6 {
                            otpCode = String(filtered.prefix(6))
                        } else {
                            otpCode = filtered
                        }
                        
                        if otpCode.count == 6 {
                            verifyOtpCode()
                        }
                    }
                
                otpBoxesView
                    .onTapGesture {
                        isOtpFieldFocused = true
                    }
            }
            .frame(height: 52)
            
            // Sayac ve Tekrar Gönderim
            if timerActive {
                Text("Kodu tekrar gönder (\(resendTimer)s)")
                    .font(.system(size: 12))
                    .foregroundColor(.zinc500)
            } else {
                Button(action: {
                    sendOtpCode()
                }) {
                    Text("Tekrar Kod Gönder")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.zinc200)
                }
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.statusRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: {
                verifyOtpCode()
            }) {
                HStack(spacing: 8) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .zinc950))
                    } else {
                        Text("Kodu Doğrula")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .foregroundColor(.zinc950)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.zinc50)
                .cornerRadius(6)
            }
            .disabled(authManager.isLoading || otpCode.count < 6)
            .opacity((authManager.isLoading || otpCode.count < 6) ? 0.5 : 1.0)
            .padding(.horizontal, 24)
        }
    }
    
    // Yeni Kullanıcı Ad-Soyad Ekranı
    private var nameInputView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("ADINIZ SOYADINIZ")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.zinc400)
                
                TextField("Ad Soyad", text: $fullName)
                    .font(.system(size: 14))
                    .foregroundColor(.zinc100)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.zinc900)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 24)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.statusRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: {
                registerNewUser()
            }) {
                HStack(spacing: 8) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .zinc950))
                    } else {
                        Text("Profilimi Kaydet ve Başla")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .foregroundColor(.zinc950)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.zinc50)
                .cornerRadius(6)
            }
            .disabled(authManager.isLoading || fullName.isEmpty)
            .opacity((authManager.isLoading || fullName.isEmpty) ? 0.5 : 1.0)
            .padding(.horizontal, 24)
        }
    }
    
    // OTP Kutu Görünümü
    private var otpBoxesView: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
                let char = index < otpCode.count ? String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]) : ""
                let isCurrent = index == otpCode.count
                
                Text(char)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.zinc50)
                    .frame(width: 44, height: 48)
                    .background(Color.zinc900)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isCurrent ? Color.zinc300 : Color.zinc800, lineWidth: 1)
                    )
            }
        }
    }
    
    // OTP Gönderme Mantığı
    private func sendOtpCode() {
        guard !email.isEmpty else {
            errorMessage = "Lütfen e-posta adresinizi girin."
            return
        }
        
        errorMessage = ""
        
        Task {
            do {
                try await authManager.sendOtp(email: email)
                authStep = .otpInput
                startTimer()
                // Klavyeyi aç
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isOtpFieldFocused = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // OTP Doğrulama Mantığı
    private func verifyOtpCode() {
        guard otpCode.count == 6 else { return }
        
        errorMessage = ""
        
        Task {
            do {
                let isLoggedIn = try await authManager.verifyOtp(email: email, code: otpCode)
                if !isLoggedIn {
                    authStep = .nameInput
                }
            } catch {
                errorMessage = error.localizedDescription
                otpCode = "" // Hatalıysa kodu sıfırla
            }
        }
    }
    
    // Yeni Kullanıcı Kaydetme Mantığı
    private func registerNewUser() {
        guard !fullName.isEmpty else {
            errorMessage = "Lütfen adınızı soyadınızı girin."
            return
        }
        
        errorMessage = ""
        
        Task {
            do {
                let _ = try await authManager.verifyOtp(email: email, code: otpCode, fullName: fullName)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // Sayaç Başlatıcı
    private func startTimer() {
        resendTimer = 60
        timerActive = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendTimer > 0 {
                resendTimer -= 1
            } else {
                timerActive = false
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    LoginView()
}
