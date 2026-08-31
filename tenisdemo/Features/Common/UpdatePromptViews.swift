import SwiftUI

struct ForceUpdateView: View {
    let appStoreUrl: String
    let message: String
    
    private let brandColor = Color(red: 0.86, green: 0.98, blue: 0.22)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Neon arkaplan ışıkları
            VStack {
                Circle()
                    .fill(brandColor.opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 60)
                    .offset(y: -50)
                Spacer()
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                // İkon Grubu
                ZStack {
                    Circle()
                        .fill(brandColor.opacity(0.15))
                        .frame(width: 110, height: 110)
                    
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(brandColor)
                }
                
                // Başlık ve Açıklamalar
                VStack(spacing: 16) {
                    Text("GÜNCELLEME GEREKLİ")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                        .tracking(3)
                        .multilineTextAlignment(.center)
                    
                    Text(message)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                // Güncelle Butonu
                Button(action: {
                    openAppStore()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("App Store'da Güncelle")
                            .bold()
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(brandColor)
                    .cornerRadius(16)
                    .shadow(color: brandColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func openAppStore() {
        if let url = URL(string: appStoreUrl) {
            UIApplication.shared.open(url)
        }
    }
}

struct SoftUpdateView: View {
    let appStoreUrl: String
    let message: String
    let onDismiss: () -> Void
    
    private let brandColor = Color(red: 0.86, green: 0.98, blue: 0.22)
    @State private var isShowing = false
    
    var body: some View {
        ZStack {
            // Arkaplan karartma
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    // Boş alana tıklanırsa kapatılmasını engelliyoruz, kullanıcı kararı vermeli.
                }
            
            VStack {
                Spacer()
                
                // Güncelleme Kartı (Glassmorphic)
                VStack(spacing: 24) {
                    // Küçük Çizgi (Tasarım detayı)
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                    
                    // Başlık ve İkon
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(brandColor.opacity(0.2))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 22))
                                .foregroundColor(brandColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Yeni Özellikler Hazır!")
                                .font(.system(.headline, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Sürüm Güncellemesi Mevcut")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    // Mesaj
                    Text(message)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(3)
                    
                    // Butonlar
                    VStack(spacing: 12) {
                        // Güncelle Butonu
                        Button(action: {
                            openAppStore()
                        }) {
                            Text("Şimdi Güncelle")
                                .font(.system(.body, design: .rounded))
                                .bold()
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(brandColor)
                                .cornerRadius(14)
                        }
                        
                        // Daha Sonra Butonu
                        Button(action: {
                            withAnimation(.spring()) {
                                onDismiss()
                            }
                        }) {
                            Text("Daha Sonra")
                                .font(.system(.body, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
                .background(.ultraThinMaterial) // iOS 15+ Native Glassmorphism
                .cornerRadius(28)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .offset(y: isShowing ? 0 : 400)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8, blendDuration: 0)) {
                isShowing = true
            }
        }
    }
    
    private func openAppStore() {
        if let url = URL(string: appStoreUrl) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SoftUpdateView(
            appStoreUrl: "https://apps.apple.com",
            message: "Uygulamamıza heyecan verici lig maç takip ve yeni swing analiz istatistikleri eklendi! Hemen güncelleyin.",
            onDismiss: {}
        )
    }
}
