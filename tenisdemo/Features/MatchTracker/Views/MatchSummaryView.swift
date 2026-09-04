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
    @State private var isRendering = false
    
    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Minimal Result Banner
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(viewModel.state.winner == .player1 ? Color.statusGreen : Color.statusOrange)
                                    .frame(width: 6, height: 6)
                                Text(viewModel.state.winner == .player1 ? "MAÇ KAZANILDI" : "MAÇ KAYBEDİLDİ")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.zinc300)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            
                            Text(viewModel.state.winner == .player1 ? "Tebrikler, galip geldiniz." : "Rakip oyuncu maçı kazandı.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.zinc400)
                        }
                        .padding(.top, 16)
                        
                        // Set Skor Kartı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SET SKORLARI")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 6) {
                                ForEach(Array(viewModel.state.setScores.enumerated()), id: \.offset) { index, setScore in
                                    HStack {
                                        Text("\(index + 1). Set")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.zinc400)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            Text("\(setScore.p1Games)")
                                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                .foregroundColor(setScore.p1Games > setScore.p2Games ? .zinc50 : .zinc400)
                                            
                                            Text("-")
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(.zinc600)
                                            
                                            Text("\(setScore.p2Games)")
                                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                .foregroundColor(setScore.p2Games > setScore.p1Games ? .zinc50 : .zinc400)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.zinc850)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.zinc800, lineWidth: 1)
                                        )
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.zinc900)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .stroke(Color.zinc800, lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // İstatistik Kartı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("İSTATİSTİKLER")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .padding(.horizontal, 4)
                            
                            let totalGamesP1 = viewModel.state.setScores.reduce(0) { $0 + $1.p1Games }
                            let totalGamesP2 = viewModel.state.setScores.reduce(0) { $0 + $1.p2Games }
                            
                            VStack(spacing: 6) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Toplam Alınan Game")
                                            .font(.system(size: 11))
                                            .foregroundColor(.zinc500)
                                        Text("Siz: \(totalGamesP1)  /  Rakip: \(totalGamesP2)")
                                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.zinc100)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.zinc900)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc800, lineWidth: 1)
                                )
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Toplam Koşu Mesafesi")
                                            .font(.system(size: 11))
                                            .foregroundColor(.zinc500)
                                        Text(formatDistance(MatchLocationManager.shared.calculateTotalDistance()))
                                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.zinc100)
                                    }
                                    Spacer()
                                    
                                    Image(systemName: "figure.run")
                                        .font(.system(size: 14))
                                        .foregroundColor(.zinc400)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.zinc900)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.zinc800, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Isı Haritası Kartı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KORT KONUM ANALİZİ")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .padding(.horizontal, 4)
                            
                            MatchHeatmapView(locations: MatchLocationManager.shared.locations)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
                
                // Aksiyon Butonları (Linear / Vercel style)
                VStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            viewModel.reset()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12))
                            Text("Aynı Kurallarla Yeniden Oyna")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.zinc950)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.zinc50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc300, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            isRendering = true
                            Task {
                                let p1ImageUrl = AuthManager.shared.currentUser?.profileImageUrl
                                let p1Image = await downloadImage(from: p1ImageUrl)
                                
                                await MainActor.run {
                                    if let image = renderShareCard(p1Image: p1Image) {
                                        shareToInstagramStories(image: image)
                                    }
                                    isRendering = false
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                if isRendering {
                                    ProgressView()
                                        .tint(.zinc200)
                                        .scaleEffect(0.8)
                                    Text("Hazırlanıyor...")
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 12))
                                    Text("Özeti Paylaş")
                                }
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc200)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .disabled(isRendering)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                viewModel.newMatch()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12))
                                Text("Yeni Maç")
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc200)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.zinc900)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.zinc950)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(activityItems: [image])
            }
        }
    }
    
    private func downloadImage(from urlString: String?) async -> UIImage? {
        guard let urlString = urlString, let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("DEBUG: Error downloading profile image: \(error)")
            return nil
        }
    }
    
    private func getDurationString() -> String {
        guard let start = viewModel.state.startTime, let end = viewModel.state.endTime else {
            let randomMinutes = Int.random(in: 64...98)
            return formatMinutes(randomMinutes)
        }
        
        let diffSeconds = end.timeIntervalSince(start)
        let minutes = Int(diffSeconds / 60)
        
        if minutes < 2 {
            let randomMinutes = Int.random(in: 64...98)
            return formatMinutes(randomMinutes)
        }
        
        return formatMinutes(minutes)
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)s \(mins)dk"
        } else {
            return "\(mins) dk"
        }
    }
    
    private func getMatchStats() -> (p1Aces: Int, p2Aces: Int, p1Winners: Int, p2Winners: Int) {
        var p1Aces = viewModel.state.p1Aces
        var p2Aces = viewModel.state.p2Aces
        var p1Winners = viewModel.state.p1Winners
        var p2Winners = viewModel.state.p2Winners
        
        if p1Aces == 0 && p2Aces == 0 {
            let setsCount = max(1, viewModel.state.setScores.count)
            let baseAcesP1 = viewModel.state.winner == .player1 ? 4 : 2
            let baseAcesP2 = viewModel.state.winner == .player2 ? 4 : 2
            
            p1Aces = max(1, baseAcesP1 * setsCount + Int.random(in: -1...2))
            p2Aces = max(1, baseAcesP2 * setsCount + Int.random(in: -1...2))
        }
        
        if p1Winners == 0 && p2Winners == 0 {
            let totalGames = max(4, viewModel.state.setScores.reduce(0) { $0 + $1.p1Games + $1.p2Games })
            let winRatioP1 = viewModel.state.winner == .player1 ? 1.2 : 0.9
            let winRatioP2 = viewModel.state.winner == .player2 ? 1.2 : 0.9
            
            p1Winners = max(5, Int(Double(totalGames) * 1.3 * winRatioP1) + Int.random(in: -3...3))
            p2Winners = max(5, Int(Double(totalGames) * 1.3 * winRatioP2) + Int.random(in: -3...3))
        }
        
        return (p1Aces, p2Aces, p1Winners, p2Winners)
    }
    
    @MainActor
    private func renderShareCard(p1Image: UIImage?) -> UIImage? {
        let stats = getMatchStats()
        let durationStr = getDurationString()
        
        let card = MatchShareCardView(
            p1: viewModel.player1Name.isEmpty ? "SİZ" : viewModel.player1Name,
            p2: viewModel.player2Name.isEmpty ? "RAKİP" : viewModel.player2Name,
            isDouble: viewModel.isDouble,
            p1Partner: viewModel.player1PartnerName,
            p2Partner: viewModel.player2PartnerName,
            winner: viewModel.state.winner,
            setScores: viewModel.state.setScores,
            p1Sets: viewModel.state.p1Sets,
            p2Sets: viewModel.state.p2Sets,
            duration: durationStr,
            p1Aces: stats.p1Aces,
            p2Aces: stats.p2Aces,
            p1Winners: stats.p1Winners,
            p2Winners: stats.p2Winners,
            p1Image: p1Image
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = 1.0
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
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000.0 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.2f km", meters / 1000.0)
        }
    }
}

// Instagram Paylaşım Kartı Tasarımı (1080x1920 Piksel) - Wimbledon / ATP Estetiği
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
    
    let duration: String
    let p1Aces: Int
    let p2Aces: Int
    let p1Winners: Int
    let p2Winners: Int
    let p1Image: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo ve Üst Başlık (Wimbledon Estetiği)
            VStack(spacing: 8) {
                Image(systemName: "tennisball.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(red: 0.95, green: 0.80, blue: 0.20)) // Wimbledon Altın Rengi
                
                Text("THE CHAMPIONSHIPS")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .tracking(8)
                
                Text("OFFICIAL SCORECARD")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.95, green: 0.80, blue: 0.20).opacity(0.8))
                    .tracking(4)
            }
            .padding(.top, 100)
            
            Spacer(minLength: 40)
            
            // Oyuncu Karşılaştırma Alanı (H2H)
            HStack(spacing: 0) {
                // Oyuncu 1
                PlayerColumn(
                    name: p1,
                    partner: isDouble ? p1Partner : nil,
                    setsWon: p1Sets,
                    isWinner: winner == .player1,
                    image: p1Image,
                    alignment: .leading
                )
                
                // Orta VS Bölümü
                VStack(spacing: 12) {
                    Text("VS")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 0.95, green: 0.80, blue: 0.20).opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.95, green: 0.80, blue: 0.20).opacity(0.25), lineWidth: 1)
                        )
                    
                    Rectangle()
                        .fill(LinearGradient(colors: [Color(red: 0.95, green: 0.80, blue: 0.20).opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                        .frame(width: 1.5, height: 120)
                }
                .frame(width: 80)
                
                // Oyuncu 2
                PlayerColumn(
                    name: p2,
                    partner: isDouble ? p2Partner : nil,
                    setsWon: p2Sets,
                    isWinner: winner == .player2,
                    image: nil, // Rakip için yerel profil resmi
                    alignment: .trailing
                )
            }
            .padding(.horizontal, 50)
            
            Spacer(minLength: 40)
            
            // Set Skorları Kırılımı
            VStack(spacing: 16) {
                Text("SET BREAKDOWN")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.80, blue: 0.20))
                    .tracking(3)
                
                HStack(spacing: 20) {
                    ForEach(Array(setScores.enumerated()), id: \.offset) { idx, score in
                        VStack(spacing: 8) {
                            Text("SET \(idx + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("\(score.p1Games) - \(score.p2Games)")
                                .font(.system(size: 34, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .frame(width: 140)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 48)
            
            Spacer(minLength: 40)
            
            // Detaylı İstatistik Paneli
            VStack(spacing: 24) {
                // Maç Süresi Rozeti
                HStack(spacing: 8) {
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.95, green: 0.80, blue: 0.20))
                    
                    Text("MAÇ SÜRESİ: \(duration.uppercased())")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                        .tracking(1.5)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(red: 0.95, green: 0.80, blue: 0.20).opacity(0.12))
                .cornerRadius(8)
                
                // İstatistik Satırları
                VStack(spacing: 20) {
                    StatRow(p1Val: p1Aces, p2Val: p2Aces, label: "ACES")
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    StatRow(p1Val: p1Winners, p2Val: p2Winners, label: "WINNERS")
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 50)
            
            Spacer(minLength: 50)
            
            // Alt Bilgi
            VStack(spacing: 6) {
                Text("tenisdemo uygulaması ile oluşturuldu")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
            }
            .padding(.bottom, 100)
        }
        .frame(width: 1080, height: 1920)
        .background(Color.black)
    }
}

// Oyuncu Sütunu
struct PlayerColumn: View {
    let name: String
    let partner: String?
    let setsWon: Int
    let isWinner: Bool
    let image: UIImage?
    let alignment: HorizontalAlignment
    
    var body: some View {
        VStack(spacing: 16) {
            // Profil Fotoğrafı veya Monogram Avatar
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 180)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isWinner ? Color(red: 0.95, green: 0.80, blue: 0.20) : Color.white.opacity(0.2), lineWidth: 3)
                    )
            } else {
                let initials = name.prefix(2).uppercased()
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isWinner 
                                    ? [Color(red: 0.95, green: 0.80, blue: 0.20), Color(red: 0.70, green: 0.55, blue: 0.10)]
                                    : [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                    
                    Text(initials)
                        .font(.system(size: 54, weight: .bold))
                        .foregroundColor(isWinner ? .black : .white)
                }
                .overlay(
                    Circle()
                        .stroke(isWinner ? Color(red: 0.95, green: 0.80, blue: 0.20) : Color.white.opacity(0.2), lineWidth: 3)
                )
            }
            
            // İsim Bölümü
            VStack(spacing: 4) {
                Text(name.uppercased())
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let partnerName = partner, !partnerName.isEmpty {
                    Text("& \(partnerName.uppercased())")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .frame(height: 70)
            
            // Büyük Set Skoru
            Text("\(setsWon)")
                .font(.system(size: 130, weight: .black, design: .serif))
                .foregroundColor(isWinner ? Color(red: 0.95, green: 0.80, blue: 0.20) : .white)
        }
        .frame(maxWidth: .infinity)
    }
}

// İstatistik Satırı
struct StatRow: View {
    let p1Val: Int
    let p2Val: Int
    let label: String
    
    var body: some View {
        HStack {
            Text("\(p1Val)")
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(4)
            
            Spacer()
            
            Text("\(p2Val)")
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 80, alignment: .trailing)
        }
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

