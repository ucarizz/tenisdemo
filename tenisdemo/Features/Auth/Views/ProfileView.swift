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
                                VStack(spacing: 2) {
                                    Text(user.fullName)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.zinc100)
                                    
                                    Text(user.email)
                                        .font(.system(size: 13))
                                        .foregroundColor(.zinc500)
                                }
                            }
                            
                            if let uploadError = uploadError {
                                Text(uploadError)
                                    .font(.system(size: 12))
                                    .foregroundColor(.statusRed)
                            }
                        }
                        .padding(.top, 16)
                        
                        // İstatistikler Kartı
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SEZON İSTATİSTİKLERİ")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.zinc500)
                            
                            HStack(spacing: 8) {
                                StatBox(title: "MAÇLAR", value: "—")
                                StatBox(title: "GALİBİYET", value: "—")
                                StatBox(title: "KAZANMA %", value: "—")
                            }
                        }
                        .padding(14)
                        .background(Color.zinc900)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .padding(.horizontal, 16)
                        
                        // Menü Butonları
                        VStack(spacing: 8) {
                            // Hukuki Metinler ve KVKK Butonu
                            Button(action: {
                                showKvkkSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 13))
                                    Text("Hukuki Metinler & KVKK")
                                        .font(.system(size: 13, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11))
                                        .foregroundColor(.zinc600)
                                }
                                .foregroundColor(.zinc200)
                                .padding(.horizontal, 14)
                                .frame(height: 42)
                                .background(Color.zinc900)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc800, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            
                            // Çıkış Yap Butonu
                            Button(action: {
                                authManager.logout()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.square")
                                        .font(.system(size: 13))
                                    Text("Oturumu Kapat")
                                        .font(.system(size: 13, weight: .medium))
                                    Spacer()
                                }
                                .foregroundColor(.zinc300)
                                .padding(.horizontal, 14)
                                .frame(height: 42)
                                .background(Color.zinc900)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc800, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            
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
                                .frame(height: 38)
                            }
                            .disabled(isDeleting)
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
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
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.zinc100)
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.zinc500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.zinc850)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.zinc800, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
