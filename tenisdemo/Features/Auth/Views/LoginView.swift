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
    
    private let brandColor = Color(red: 0.86, green: 0.98, blue: 0.22)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Koyu Arka Plan
                Color.black.ignoresSafeArea()
                
                // Dekoratif Arka Plan Işıkları (Premium Hissiyat)
                VStack {
                    HStack {
                        Circle()
                            .fill(brandColor.opacity(0.08))
                            .frame(width: 250, height: 250)
                            .blur(radius: 50)
                            .offset(x: -80, y: -80)
                        Spacer()
                    }
                    Spacer()
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 40)
                        
                        // Logo ve Başlık
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(brandColor.opacity(0.15))
                                    .frame(width: 90, height: 90)
                                
                                Image(systemName: "tennisball.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(brandColor)
                            }
                            
                            if authStep == .nameInput {
                                Text("PROFİL OLUŞTUR")
                                    .font(.system(.title, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                    .tracking(3)
                                
                                Text("Ligi takip etmek için bilgilerinizi tamamlayın.")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            } else {
                                Text("TENİS LİGİ")
                                    .font(.system(.title, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                    .tracking(3)
                                
                                Text(authStep == .otpInput ? "E-postanıza gelen 6 haneli doğrulama kodunu girin." : "Maçlarını takip et, skorları canlı paylaş.")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.gray)
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
                    .font(.system(.caption2, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                
                TextField("ornek@eposta.com", text: $email)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 24)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: {
                sendOtpCode()
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Text("Doğrulama Kodu Gönder")
                            .font(.system(.body, design: .rounded))
                            .bold()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(brandColor)
                .cornerRadius(16)
                .shadow(color: brandColor.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(authManager.isLoading || email.isEmpty)
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
    
    // OTP Doğrulama Kod Ekranı
    private var otpInputView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("GÖNDERİLEN E-POSTA")
                    .font(.system(.caption2, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                
                HStack(spacing: 6) {
                    Text(email)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white)
                        .bold()
                    
                    Button(action: {
                        authStep = .emailInput
                        otpCode = ""
                        errorMessage = ""
                    }) {
                        Text("Düzenle")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(brandColor)
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
            .frame(height: 60)
            
            // Sayac ve Tekrar Gönderim
            if timerActive {
                Text("Kodu tekrar gönder (\(resendTimer)s)")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.gray)
            } else {
                Button(action: {
                    sendOtpCode()
                }) {
                    Text("Tekrar Kod Gönder")
                        .font(.system(.footnote, design: .rounded))
                        .bold()
                        .foregroundColor(brandColor)
                }
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: {
                verifyOtpCode()
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Text("Kodu Doğrula")
                            .font(.system(.body, design: .rounded))
                            .bold()
                        Image(systemName: "checkmark")
                            .font(.system(size: 14))
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(brandColor)
                .cornerRadius(16)
                .shadow(color: brandColor.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(authManager.isLoading || otpCode.count < 6)
            .padding(.horizontal, 24)
        }
    }
    
    // Yeni Kullanıcı Ad-Soyad Ekranı
    private var nameInputView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("ADINIZ SOYADINIZ")
                    .font(.system(.caption2, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                
                TextField("Ad Soyad", text: $fullName)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 24)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button(action: {
                registerNewUser()
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Text("Profilimi Kaydet ve Başla")
                            .font(.system(.body, design: .rounded))
                            .bold()
                        Image(systemName: "checkmark")
                            .font(.system(size: 14))
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(brandColor)
                .cornerRadius(16)
                .shadow(color: brandColor.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(authManager.isLoading || fullName.isEmpty)
            .padding(.horizontal, 24)
        }
    }
    
    // OTP Kutu Görünümü
    private var otpBoxesView: some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                let char = index < otpCode.count ? String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]) : ""
                let isCurrent = index == otpCode.count
                
                Text(char)
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 44, height: 54)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCurrent ? brandColor : Color.white.opacity(0.08), lineWidth: isCurrent ? 2 : 1)
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
