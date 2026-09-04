import SwiftUI

struct ForceUpdateView: View {
    let appStoreUrl: String
    let message: String
    
    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // İkon Grubu
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.zinc900)
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                    
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.zinc100)
                }
                
                // Başlık ve Açıklamalar
                VStack(spacing: 12) {
                    Text("Güncelleme Gerekli")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.zinc50)
                        .multilineTextAlignment(.center)
                    
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(.zinc400)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineSpacing(3)
                }
                
                Spacer()
                
                // Güncelle Butonu
                Button(action: {
                    openAppStore()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 13, weight: .semibold))
                        Text("App Store'da Güncelle")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.zinc950)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.zinc50)
                    .cornerRadius(6)
                }
                .padding(.horizontal, 24)
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
                
                // Güncelleme Kartı
                VStack(spacing: 20) {
                    // Küçük Çizgi
                    Capsule()
                        .fill(Color.zinc700)
                        .frame(width: 36, height: 4)
                        .padding(.top, 10)
                    
                    // Başlık ve İkon
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.zinc800)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc700, lineWidth: 1)
                                )
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                                .foregroundColor(.zinc100)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Yeni Sürüm Mevcut")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.zinc50)
                            
                            Text("Yeni özellikler ve iyileştirmeler")
                                .font(.system(size: 12))
                                .foregroundColor(.zinc400)
                        }
                        Spacer()
                    }
                    
                    // Mesaj
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(.zinc300)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(3)
                    
                    // Butonlar
                    VStack(spacing: 8) {
                        Button(action: {
                            openAppStore()
                        }) {
                            Text("Şimdi Güncelle")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.zinc950)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(Color.zinc50)
                                .cornerRadius(6)
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                onDismiss()
                            }
                        }) {
                            Text("Daha Sonra")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.zinc300)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(Color.zinc800)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc700, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .background(Color.zinc900)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .offset(y: isShowing ? 0 : 400)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8, blendDuration: 0)) {
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
        Color.zinc950.ignoresSafeArea()
        SoftUpdateView(
            appStoreUrl: "https://apps.apple.com",
            message: "Uygulamamıza heyecan verici lig maç takip ve yeni swing analiz istatistikleri eklendi! Hemen güncelleyin.",
            onDismiss: {}
        )
    }
}
