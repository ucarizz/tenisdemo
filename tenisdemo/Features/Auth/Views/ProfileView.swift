import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    
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
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                    
                    if let user = authManager.currentUser {
                        Text(user.fullName)
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                        
                        Text(user.email)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
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
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
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
