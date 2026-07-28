import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Koyu Arka Plan
                Color.black.ignoresSafeArea()
                
                // Dekoratif Arka Plan Işıkları (Premium Hissiyat)
                VStack {
                    HStack {
                        Circle()
                            .fill(Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.08))
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
                                    .fill(Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.15))
                                    .frame(width: 90, height: 90)
                                
                                Image(systemName: "tennisball.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                            }
                            
                            Text("TENİS LİGİ")
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                                .tracking(3)
                            
                            Text("Maçlarını takip et, skorları canlı paylaş.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Giriş Formu
                        VStack(spacing: 16) {
                            // E-posta alanı
                            VStack(alignment: .leading, spacing: 6) {
                                Text("E-POSTA")
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
                            }
                            
                            // Şifre alanı
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ŞİFRE")
                                    .font(.system(.caption2, design: .rounded))
                                    .bold()
                                    .foregroundColor(.gray)
                                
                                SecureField("••••••", text: $password)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Hata Mesajı
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        
                        // Giriş Yap Butonu
                        Button(action: {
                            loginUser()
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Giriş Yap")
                                        .font(.system(.body, design: .rounded))
                                        .bold()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14))
                                }
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(authManager.isLoading)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        // Kayıt Ol Yönlendirmesi
                        Button(action: {
                            showRegister = true
                        }) {
                            HStack(spacing: 4) {
                                Text("Hesabınız yok mu?")
                                    .foregroundColor(.gray)
                                Text("Şimdi Kayıt Olun")
                                    .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                                    .bold()
                            }
                            .font(.system(.footnote, design: .rounded))
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: RegisterView(), isActive: $showRegister) {
                    EmptyView()
                }
            )
        }
    }
    
    private func loginUser() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Lütfen e-posta ve şifrenizi girin."
            return
        }
        
        errorMessage = ""
        
        Task {
            do {
                try await authManager.login(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
