import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authManager = AuthManager.shared
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Koyu Arka Plan
            Color.black.ignoresSafeArea()
            
            // Dekoratif Arka Plan Işıkları (Premium Hissiyat)
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.emerald.opacity(0.08))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: 80, y: -80)
                }
                Spacer()
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Geri Dön Butonu
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Başlık
                    VStack(spacing: 8) {
                        Text("Kayıt Ol")
                            .font(.system(.largeTitle, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Kendi profilini oluştur ve rakiplerinle eşleş.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Kayıt Formu
                    VStack(spacing: 16) {
                        // Ad Soyad alanı
                        VStack(alignment: .leading, spacing: 6) {
                            Text("AD SOYAD")
                                .font(.system(.caption2, design: .rounded))
                                .bold()
                                .foregroundColor(.gray)
                            
                            TextField("Adınız Soyadınız", text: $fullName)
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
                        }
                        
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
                            
                            SecureField("En az 6 karakter", text: $password)
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
                        
                        // Şifre Tekrar alanı
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ŞİFRE TEKRAR")
                                .font(.system(.caption2, design: .rounded))
                                .bold()
                                .foregroundColor(.gray)
                            
                            SecureField("Şifrenizi tekrar girin", text: $confirmPassword)
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
                    
                    // Kayıt Ol Butonu
                    Button(action: {
                        registerUser()
                    }) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Hesap Oluştur")
                                    .font(.system(.body, design: .rounded))
                                    .bold()
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14))
                            }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.emerald)
                        .cornerRadius(16)
                        .shadow(color: Color.emerald.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(authManager.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 24)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func registerUser() {
        guard !fullName.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Şifreler uyuşmuyor."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Şifre en az 6 karakter olmalıdır."
            return
        }
        
        errorMessage = ""
        
        Task {
            do {
                try await authManager.register(email: email, password: password, fullName: fullName)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
