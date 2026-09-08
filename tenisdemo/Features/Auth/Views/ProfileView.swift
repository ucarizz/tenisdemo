//
//  ProfileView.swift
//  tenisdemo
//
//  Created by Antigravity on 07.08.2026.
//  Refactored for Linear / Vercel Minimal Aesthetic
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var uploadError: String? = nil
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    @State private var deleteError: String? = nil
    @State private var showKvkkSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.zinc950.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profil Bilgileri
                        VStack(spacing: 12) {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                if let user = authManager.currentUser,
                                   let urlStr = user.profileImageUrl,
                                   let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 72, height: 72)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.zinc700, lineWidth: 1))
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 72, height: 72)
                                    }
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 64))
                                        .foregroundColor(.zinc600)
                                        .overlay(
                                            Image(systemName: "camera")
                                                .font(.system(size: 11))
                                                .padding(5)
                                                .background(Color.zinc850)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.zinc700, lineWidth: 1))
                                                .foregroundColor(.zinc300)
                                                .offset(x: 22, y: 22)
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
                                VStack(spacing: 3) {
                                    Text(user.fullName)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.zinc100)
                                    
                                    Text(user.email)
                                        .font(.system(size: 13))
                                        .foregroundColor(.zinc500)
                                    
                                    HStack(spacing: 6) {
                                        SportBadge(text: "NTRP 4.0", color: .badgeBlue)
                                        SportBadge(text: "LİG ÜYESİ", color: .courtGreen)
                                        SportBadge(text: "SAĞ EL", color: .zinc400)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            
                            if let uploadError = uploadError {
                                Text(uploadError)
                                    .font(.system(size: 12))
                                    .foregroundColor(.statusRed)
                            }
                        }
                        .padding(.top, 16)
                        
                        // İstatistikler (Wimbledon Court-Line Table)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SEZON İSTATİSTİKLERİ")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .tracking(1.0)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                            
                            HStack(spacing: 0) {
                                StatBox(title: "MAÇLAR", value: "—")
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 1, height: 36)
                                
                                StatBox(title: "GALİBİYET", value: "—")
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 1, height: 36)
                                
                                StatBox(title: "KAZANMA %", value: "—")
                            }
                            .padding(.vertical, 8)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Menü Satırları (Kort Çizgili Liste)
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                            
                            // Hukuki Metinler ve KVKK Butonu
                            Button(action: {
                                showKvkkSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 13))
                                        .foregroundColor(.zinc400)
                                    Text("Hukuki Metinler & KVKK")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.zinc200)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11))
                                        .foregroundColor(.zinc600)
                                }
                                .padding(.vertical, 14)
                            }
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 1)
                            
                            // Çıkış Yap Butonu
                            Button(action: {
                                authManager.logout()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.square")
                                        .font(.system(size: 13))
                                        .foregroundColor(.zinc400)
                                    Text("Oturumu Kapat")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.zinc200)
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                            }
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                            
                            // Hesabımı Sil Butonu
                            Button(action: {
                                showDeleteAlert = true
                            }) {
                                HStack {
                                    if isDeleting {
                                        ProgressView()
                                            .tint(.statusRed)
                                    } else {
                                        Text("Hesabımı ve Verilerimi Sil")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                }
                                .foregroundColor(.statusRed.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                            }
                            .disabled(isDeleting)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        
                        if let deleteError = deleteError {
                            Text(deleteError)
                                .font(.system(size: 12))
                                .foregroundColor(.statusRed)
                                .padding(.horizontal, 16)
                        }
                        
                        Spacer(minLength: 24)
                    }
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.zinc950, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showKvkkSheet) {
                LegalView()
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Hesabınızı Silmek İstediğinize Emin Misiniz?"),
                    message: Text("Bu işlem geri alınamaz. KVKK ve Gizlilik Politikamız uyarınca tüm kişisel verileriniz, maç geçmişiniz ve sunuculardaki hesap kaydınız kalıcı olarak silinecektir."),
                    primaryButton: .destructive(Text("Evet, Sil")) {
                        performAccountDeletion()
                    },
                    secondaryButton: .cancel(Text("Vazgeç"))
                )
            }
        }
    }
    
    private func performAccountDeletion() {
        isDeleting = true
        deleteError = nil
        
        Task {
            do {
                try await authManager.deleteAccount()
                isDeleting = false
            } catch {
                isDeleting = false
                deleteError = error.localizedDescription
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    var accentColor: Color? = nil
    
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(accentColor ?? .zinc100)
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.zinc500)
                .tracking(1.0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}
