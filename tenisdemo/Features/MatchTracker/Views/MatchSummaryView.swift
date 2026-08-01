//
//  MatchSummaryView.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import SwiftUI

struct MatchSummaryView: View {
    @ObservedObject var viewModel: TennisMatchViewModel
    
    @State private var showShareSheet = false
    @State private var shareImage: UIImage? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Başarı Görseli
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(viewModel.state.winner == .player1 ? Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.15) : Color.orange.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: viewModel.state.winner == .player1 ? "trophy.fill" : "hand.thumbsup.fill")
                        .font(.system(size: 48))
                        .foregroundColor(viewModel.state.winner == .player1 ? Color(red: 0.86, green: 0.98, blue: 0.22) : .orange)
                }
                
                Text(viewModel.state.winner == .player1 ? "MAÇI KAZANDINIZ!" : "RAKİP KAZANDI")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .tracking(1)
            }
            .padding(.top)
            
            // Set Skor Kartı
            VStack(alignment: .leading, spacing: 16) {
                Text("SET SKORLARI")
                    .font(.system(.caption, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.state.setScores.enumerated()), id: \.offset) { index, setScore in
                        HStack {
                            Text("\(index + 1). Set")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Text("\(setScore.p1Games)")
                                    .font(.system(.title3, design: .monospaced))
                                    .bold()
                                    .foregroundColor(setScore.p1Games > setScore.p2Games ? Color.emerald : .white)
                                
                                Text("-")
                                    .font(.system(.title3, design: .rounded))
                                    .foregroundColor(.gray)
                                
                                Text("\(setScore.p2Games)")
                                    .font(.system(.title3, design: .monospaced))
                                    .bold()
                                    .foregroundColor(setScore.p2Games > setScore.p1Games ? Color.orange : .white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            // İstatistik Kartı
            VStack(alignment: .leading, spacing: 12) {
                Text("İSTATİSTİKLER")
                    .font(.system(.caption, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                
                let totalGamesP1 = viewModel.state.setScores.reduce(0) { $0 + $1.p1Games }
                let totalGamesP2 = viewModel.state.setScores.reduce(0) { $0 + $1.p2Games }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Toplam Alınan Game")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                        Text("Siz: \(totalGamesP1)  /  Rakip: \(totalGamesP2)")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Aksiyon Butonları
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.reset()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Aynı Kurallarla Yeniden Oyna")
                    }
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                    .cornerRadius(14)
                }
                
                Button(action: {
                    if let image = renderShareCard() {
                        shareToInstagramStories(image: image)
                    }
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Instagram Story'de Paylaş")
                    }
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.51, green: 0.20, blue: 0.69),
                                Color(red: 0.87, green: 0.16, blue: 0.48),
                                Color(red: 0.96, green: 0.52, blue: 0.16)
                            ]),
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .cornerRadius(14)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.newMatch()
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Yeni Maç Kur")
                    }
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            }
        }
    }
    
    @MainActor
    private func renderShareCard() -> UIImage? {
        let card = MatchShareCardView(
            p1: viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name,
            p2: viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name,
            isDouble: viewModel.isDouble,
            p1Partner: viewModel.player1PartnerName,
            p2Partner: viewModel.player2PartnerName,
            winner: viewModel.state.winner,
            setScores: viewModel.state.setScores,
            p1Sets: viewModel.state.p1Sets,
            p2Sets: viewModel.state.p2Sets
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3.0
        return renderer.uiImage
    }
    
    private func shareToInstagramStories(image: UIImage) {
        guard let urlScheme = URL(string: "instagram-stories://share?source_application=disip.tenisdemo") else { return }
        
        if UIApplication.shared.canOpenURL(urlScheme) {
            guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }
            let pasteboardItems: [[String: Any]] = [
                ["com.instagram.sharedSticker.backgroundImage": imageData]
            ]
            let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
                .expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
        } else {
            // Instagram yüklü değilse standart paylaşım sayfasını göster
            self.shareImage = image
            self.showShareSheet = true
        }
    }
}

// Instagram Paylaşım Kartı Tasarımı (1080x1920 Piksel)
struct MatchShareCardView: View {
    let p1: String
    let p2: String
    let isDouble: Bool
    let p1Partner: String?
    let p2Partner: String?
    let winner: Player?
    let setScores: [SetScore]
    let p1Sets: Int
    let p2Sets: Int
    
    var body: some View {
        VStack(spacing: 48) {
            Spacer()
            
            // Logo ve Başlık
            VStack(spacing: 12) {
                Image(systemName: "tennisball.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                
                Text("TENİS LİGİ")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(6)
            }
            .padding(.top, 60)
            
            // Ana Skor Kartı
            VStack(spacing: 36) {
                Text("MAÇ SONUCU")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                    .tracking(4)
                
                // Oyuncular ve Genel Set Skorları
                HStack(spacing: 16) {
                    // Oyuncu 1
                    VStack(spacing: 8) {
                        Text(p1)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                        if isDouble, let partner = p1Partner, !partner.isEmpty {
                            Text("& \(partner)")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        // Genel Set Skoru
                        Text("\(p1Sets)")
                            .font(.system(size: 64, weight: .black, design: .monospaced))
                            .foregroundColor(p1Sets > p2Sets ? Color(red: 0.86, green: 0.98, blue: 0.22) : .white)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("VS")
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.top, 40)
                    
                    // Oyuncu 2
                    VStack(spacing: 8) {
                        Text(p2)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                        if isDouble, let partner = p2Partner, !partner.isEmpty {
                            Text("& \(partner)")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        // Genel Set Skoru
                        Text("\(p2Sets)")
                            .font(.system(size: 64, weight: .black, design: .monospaced))
                            .foregroundColor(p2Sets > p1Sets ? Color(red: 0.86, green: 0.98, blue: 0.22) : .white)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                // Set Skorları
                HStack(spacing: 24) {
                    ForEach(Array(setScores.enumerated()), id: \.offset) { idx, score in
                        VStack(spacing: 12) {
                            Text("\(idx + 1). Set")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Text("\(score.p1Games) - \(score.p2Games)")
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(16)
                    }
                }
            }
            .padding(48)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(white: 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 48)
            
            // Kazanan Rozeti
            if let winner = winner {
                let winnerName = winner == .player1 ? p1 : p2
                HStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                    Text("KAZANAN: \(winnerName.uppercased())")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                }
                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                .padding(.horizontal, 36)
                .padding(.vertical, 18)
                .background(Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.12))
                .cornerRadius(24)
            }
            
            Spacer()
            
            // Alt Bilgi
            Text("tenisdemo uygulaması ile oluşturuldu")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray.opacity(0.4))
                .padding(.bottom, 60)
        }
        .frame(width: 1080, height: 1920)
        .background(
            ZStack {
                Color.black
                RadialGradient(
                    colors: [Color(red: 0.15, green: 0.28, blue: 0.10), Color.black],
                    center: .center,
                    startRadius: 200,
                    endRadius: 950
                )
            }
        )
    }
}

// Standart Paylaşım Sayfası (Activity Controller) Sarmalayıcısı
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

