import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var uploadError: String? = nil
    @State private var showDeleteConfirmation = false
    @State private var deleteError: String? = nil
    @State private var showKvkkSheet = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Dekoratif Arka Plan Işığı
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.06))
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)
                        .offset(x: 50, y: -50)
                }
                Spacer()
            }
            
            VStack(spacing: 24) {
                // Başlık
                Text("PROFİLİM")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .tracking(2)
                    .padding(.top, 24)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Profil Bilgileri
                VStack(spacing: 16) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let user = authManager.currentUser,
                           let urlStr = user.profileImageUrl,
                           let url = URL(string: urlStr) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(red: 0.86, green: 0.98, blue: 0.22), lineWidth: 2))
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 90, height: 90)
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14))
                                        .padding(6)
                                        .background(Color.black)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                        .offset(x: 28, y: 28)
                                )
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                do {
                                    try await authManager.uploadProfileImage(imageData: data)
                                    uploadError = nil
                                } catch {
                                    uploadError = error.localizedDescription
                                }
                            }
                        }
                    }
                    
                    if let user = authManager.currentUser {
                        Text(user.fullName)
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                        
                        Text(user.email)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    if let uploadError = uploadError {
                        Text(uploadError)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 16)
                
                // İstatistikler Kartı
                VStack(spacing: 12) {
                    HStack {
                        Text("Aktif Sezon İstatistikleri")
                            .font(.system(.subheadline, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        StatBox(title: "Maçlar", value: "—")
                        StatBox(title: "Galibiyet", value: "—")
                        StatBox(title: "Kazanma %", value: "—")
                    }
                }
                .padding()
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                if let deleteError = deleteError {
                    Text(deleteError)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                // Oturum ve Hesap Yönetimi Butonları
                VStack(spacing: 12) {
                    // Hukuki Metinler ve KVKK Butonu
                    Button(action: {
                        showKvkkSheet = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 16, weight: .bold))
                            Text("Hukuki Metinler & KVKK")
                                .font(.system(.body, design: .rounded))
                                .bold()
                        }
                        .foregroundColor(.emerald)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.emerald.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.emerald.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Çıkış Yap Butonu
                    Button(action: {
                        authManager.logout()
                    }) {
                        HStack {
                            Image(systemName: "power")
                                .font(.system(size: 16, weight: .bold))
                            Text("Oturumu Kapat")
                                .font(.system(.body, design: .rounded))
                                .bold()
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    
                    // Hesabı Sil Butonu
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .bold))
                            Text("Hesabımı Sil")
                                .font(.system(.body, design: .rounded))
                                .bold()
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.red.opacity(0.12))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.red.opacity(0.25), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .alert("Hesabımı Sil", isPresented: $showDeleteConfirmation) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    deleteUserAccount()
                }
            } message: {
                Text("Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm maç/vuruş geçmişiniz kalıcı olarak silinir.")
            }
        }
        .sheet(isPresented: $showKvkkSheet) {
            LegalView()
        }
    }
    
    private func deleteUserAccount() {
        Task {
            do {
                try await authManager.deleteAccount()
            } catch {
                deleteError = error.localizedDescription
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(.title3, design: .rounded))
                .bold()
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(10)
    }
}
