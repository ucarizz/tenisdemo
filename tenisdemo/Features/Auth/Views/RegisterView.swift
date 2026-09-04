import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authManager = AuthManager.shared
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isKvkkAccepted = false
    @State private var showKvkkSheet = false
    
    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Geri Dön Butonu
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.zinc300)
                                .frame(width: 32, height: 32)
                                .background(Color.zinc900)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc800, lineWidth: 1)
                                )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Başlık
                    VStack(spacing: 8) {
                        Text("Kayıt Ol")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.zinc50)
                        
                        Text("Kendi profilini oluştur ve rakiplerinle eşleş.")
                            .font(.system(size: 13))
                            .foregroundColor(.zinc400)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Kayıt Formu
                    VStack(spacing: 16) {
                        // Ad Soyad alanı
                        VStack(alignment: .leading, spacing: 6) {
                            Text("AD SOYAD")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.zinc400)
                            
                            TextField("Adınız Soyadınız", text: $fullName)
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
                        }
                        
                        // E-posta alanı
                        VStack(alignment: .leading, spacing: 6) {
                            Text("E-POSTA")
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
                        }
                        
                        // Şifre alanı
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ŞİFRE")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.zinc400)
                            
                            SecureField("En az 6 karakter", text: $password)
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
                        }
                        
                        // Şifre Tekrar alanı
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ŞİFRE TEKRAR")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.zinc400)
                            
                            SecureField("Şifrenizi tekrar girin", text: $confirmPassword)
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
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // KVKK ve Onay Kutusu
                    HStack(alignment: .top, spacing: 10) {
                        Button(action: {
                            isKvkkAccepted.toggle()
                        }) {
                            Image(systemName: isKvkkAccepted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 16))
                                .foregroundColor(isKvkkAccepted ? .zinc100 : .zinc500)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Kayıt olarak ")
                                .font(.system(size: 12))
                                .foregroundColor(.zinc400)
                            + Text("Kullanım Koşulları'nı")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.zinc200)
                            + Text(" ve ")
                                .font(.system(size: 12))
                                .foregroundColor(.zinc400)
                            + Text("KVKK Aydınlatma Metni'ni")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.zinc200)
                            + Text(" okuduğumu ve kabul ettiğimi onaylıyorum.")
                                .font(.system(size: 12))
                                .foregroundColor(.zinc400)
                        }
                        .onTapGesture {
                            showKvkkSheet = true
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 4)
                    
                    // Hata Mesajı
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.statusRed)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Kayıt Ol Butonu
                    Button(action: {
                        registerUser()
                    }) {
                        HStack(spacing: 8) {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .zinc950))
                            } else {
                                Text("Hesap Oluştur")
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
                    .disabled(authManager.isLoading)
                    .opacity(authManager.isLoading ? 0.5 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    
                    Spacer(minLength: 24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showKvkkSheet) {
            LegalView()
        }
    }
    
    private func registerUser() {
        guard !fullName.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun."
            return
        }
        
        guard isKvkkAccepted else {
            errorMessage = "Devam etmek için KVKK Aydınlatma Metni'ni kabul etmelisiniz."
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
                try await authManager.register(email: email, password: password, fullName: fullName, isKvkkAccepted: isKvkkAccepted)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
