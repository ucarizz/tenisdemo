//
//  LeagueMatchDetailView.swift
//  tenisdemo
//
//  Created by Antigravity on 07.08.2026.
//  Refactored for Linear / Vercel Minimal Aesthetic
//

import SwiftUI
import CoreLocation

class MatchSwingViewModel: ObservableObject {
    @Published var records: [SwingRecordItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    @MainActor
    func loadSwings(for matchId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let client = URLSessionAPIClient()
            self.records = try await client.request(SwingEndpoint.getHistoryByMatch(matchId: matchId))
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    var averageSpeed: Double {
        guard !records.isEmpty else { return 0.0 }
        let total = records.reduce(0.0) { $0 + $1.speedKmh }
        return total / Double(records.count)
    }
    
    var maxSpeed: Double {
        return records.map { $0.speedKmh }.max() ?? 0.0
    }
}

struct LeagueMatchDetailView: View {
    let match: LeagueMatch
    @StateObject private var viewModel = MatchSwingViewModel()
    
    @State private var locations: [TrackedLocation] = []
    @State private var isLoadingLocations = false
    @State private var locationsError: String? = nil
    
    var body: some View {
        ZStack {
            Color.zinc950.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Maç Kartı Detayı
                    VStack(spacing: 12) {
                        HStack {
                            Text(match.matchDate)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.zinc500)
                            
                            Spacer()
                            
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(match.isCompleted ? Color.statusGreen : Color.statusOrange)
                                    .frame(width: 5, height: 5)
                                
                                Text(match.isCompleted ? "TAMAMLANDI" : "BEKLENİYOR")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(match.isCompleted ? .zinc300 : .zinc400)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.zinc850)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                        }
                        
                        Divider()
                            .background(Color.zinc800)
                        
                        HStack(spacing: 8) {
                            // Oyuncu 1
                            VStack(spacing: 4) {
                                Text(match.player1Name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.zinc100)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                if match.isDouble, let p1Partner = match.player1PartnerName {
                                    Text("& \(p1Partner)")
                                        .font(.system(size: 11))
                                        .foregroundColor(.zinc500)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Text("vs")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.zinc850)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.zinc800, lineWidth: 1)
                                )
                            
                            // Oyuncu 2
                            VStack(spacing: 4) {
                                Text(match.player2Name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.zinc100)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                if match.isDouble, let p2Partner = match.player2PartnerName {
                                    Text("& \(p2Partner)")
                                        .font(.system(size: 11))
                                        .foregroundColor(.zinc500)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 6)
                        
                        // Detaylı Set Skorları (Scoreboard)
                        if let score = match.score, !score.isEmpty {
                            Divider()
                                .background(Color.zinc800)
                            
                            TennisScoreboardView(
                                player1Name: match.player1Name,
                                player2Name: match.player2Name,
                                scoreString: score
                            )
                        }
                    }
                    .padding(14)
                    .background(Color.zinc900)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.zinc800, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    
                    // 1.5. Sayı Geçmişi (Puan Akışı)
                    if let history = match.pointHistories, !history.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SAYI GEÇMİŞİ")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 4) {
                                ForEach(history.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })) { pt in
                                    HStack {
                                        Text("#\(pt.sequenceNumber + 1)")
                                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                                            .foregroundColor(.zinc500)
                                            .frame(width: 32, alignment: .leading)
                                        
                                        Circle()
                                            .fill(pt.server.lowercased() == "p1" || pt.server.lowercased() == "player1" || pt.server == "SİZ" ? Color.zinc100 : Color.zinc600)
                                            .frame(width: 5, height: 5)
                                        
                                        Text(pt.server.lowercased() == "p1" || pt.server.lowercased() == "player1" || pt.server == "SİZ" ? "\(match.player1Name)" : "\(match.player2Name)")
                                            .font(.system(size: 12))
                                            .foregroundColor(.zinc300)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Text("\(pt.p1Points) - \(pt.p2Points)")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(.zinc100)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.zinc850)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(Color.zinc800, lineWidth: 1)
                                            )
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.zinc900)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.zinc850, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    
                    // 2. Koşu Mesafesi ve Isı Haritası
                    VStack(alignment: .leading, spacing: 8) {
                        Text("KORT KONUM ANALİZİ")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.zinc500)
                            .padding(.horizontal, 4)
                        
                        if isLoadingLocations {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.zinc400)
                                Text("Konumlar yükleniyor...")
                                    .font(.system(size: 12))
                                    .foregroundColor(.zinc500)
                                Spacer()
                            }
                            .padding(20)
                            .background(Color.zinc900)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.zinc800, lineWidth: 1))
                        } else if !locations.isEmpty {
                            VStack(spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Toplam Koşu Mesafesi")
                                            .font(.system(size: 11))
                                            .foregroundColor(.zinc500)
                                        Text(formatDistance(calculateTotalDistance(for: locations)))
                                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                                            .foregroundColor(.zinc100)
                                    }
                                    Spacer()
                                    Image(systemName: "figure.run")
                                        .font(.system(size: 13))
                                        .foregroundColor(.zinc400)
                                }
                                .padding(12)
                                .background(Color.zinc900)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.zinc800, lineWidth: 1))
                                
                                MatchHeatmapView(locations: locations)
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("Bu maça ait GPS konum verisi bulunamadı.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.zinc500)
                                Spacer()
                            }
                            .padding(20)
                            .background(Color.zinc900)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.zinc800, lineWidth: 1))
                        }
                    }
                    
                    // 3. Vuruş Hızları ve Analizi
                    VStack(alignment: .leading, spacing: 8) {
                        Text("VURUŞ ANALİZİ (APPLE WATCH)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.zinc500)
                            .padding(.horizontal, 4)
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.zinc400)
                                Text("Vuruşlar yükleniyor...")
                                    .font(.system(size: 12))
                                    .foregroundColor(.zinc500)
                                Spacer()
                            }
                            .padding(20)
                            .background(Color.zinc900)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.zinc800, lineWidth: 1))
                        } else if viewModel.records.isEmpty {
                            HStack {
                                Spacer()
                                Text("Bu maça ait kayıtlı vuruş verisi bulunamadı.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.zinc500)
                                Spacer()
                            }
                            .padding(20)
                            .background(Color.zinc900)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.zinc800, lineWidth: 1))
                        } else {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    SummaryStatBox(
                                        title: "ORT. HIZ",
                                        value: String(format: "%.0f km/h", viewModel.averageSpeed)
                                    )
                                    SummaryStatBox(
                                        title: "MAKS. HIZ",
                                        value: String(format: "%.0f km/h", viewModel.maxSpeed)
                                    )
                                    SummaryStatBox(
                                        title: "TOPLAM",
                                        value: "\(viewModel.records.count)"
                                    )
                                }
                                
                                VStack(spacing: 4) {
                                    ForEach(viewModel.records) { record in
                                        HStack {
                                            Text(record.swingType.uppercased())
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(.zinc300)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.zinc850)
                                                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.zinc800, lineWidth: 1))
                                            
                                            Text(formatTime(record.recordedAt))
                                                .font(.system(size: 11, design: .monospaced))
                                                .foregroundColor(.zinc500)
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 8) {
                                                Text(String(format: "%.0f km/h", record.speedKmh))
                                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                                    .foregroundColor(.zinc100)
                                                
                                                Text(String(format: "%.1f G", record.accelerationG))
                                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                                    .foregroundColor(.zinc500)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 1)
                                                    .background(Color.zinc850)
                                                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.zinc800, lineWidth: 1))
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(Color.zinc900)
                                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.zinc850, lineWidth: 1))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Maç Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.zinc950, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.loadSwings(for: match.id)
            await loadLocations(for: match.id)
        }
    }
    
    private func loadLocations(for matchId: Int) async {
        isLoadingLocations = true
        locationsError = nil
        do {
            let service = LeagueService()
            self.locations = try await service.fetchMatchLocations(matchId: matchId)
        } catch {
            self.locationsError = error.localizedDescription
        }
        isLoadingLocations = false
    }
    
    private func calculateTotalDistance(for locs: [TrackedLocation]) -> Double {
        guard locs.count > 1 else { return 0.0 }
        var total: Double = 0.0
        for i in 1..<locs.count {
            let prev = CLLocation(latitude: locs[i-1].latitude, longitude: locs[i-1].longitude)
            let curr = CLLocation(latitude: locs[i].latitude, longitude: locs[i].longitude)
            let d = curr.distance(from: prev)
            if d > 0.3 && d < 20.0 {
                total += d
            }
        }
        return total
    }
    
    private func formatDistance(_ distanceMeters: Double) -> String {
        if distanceMeters >= 1000 {
            return String(format: "%.2f km", distanceMeters / 1000.0)
        } else {
            return String(format: "%.0f metre", distanceMeters)
        }
    }
    
    private func formatTime(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        
        if let date = formatter.date(from: dateStr) {
            return outputFormatter.string(from: date)
        }
        
        let formatter2 = ISO8601DateFormatter()
        if let date = formatter2.date(from: dateStr) {
            return outputFormatter.string(from: date)
        }
        
        return dateStr
    }
}

// MARK: - Minimal Table Scoreboard
struct TennisScoreboardView: View {
    let player1Name: String
    let player2Name: String
    let scoreString: String
    
    var body: some View {
        let sets = parseScore(scoreString)
        
        VStack(spacing: 6) {
            // Sütun Başlıkları (S1, S2, S3...)
            HStack(spacing: 0) {
                Text("Set Dağılımı")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.zinc500)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 6) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        Text("S\(idx + 1)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc500)
                            .frame(width: 28, alignment: .center)
                    }
                }
            }
            .padding(.horizontal, 2)
            
            // Oyuncu 1 Satırı
            HStack(spacing: 0) {
                Text(player1Name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.zinc100)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 6) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        Text(sets[idx].0)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc50)
                            .frame(width: 28, height: 26)
                            .background(Color.zinc850)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.zinc800, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 2)
            
            // Oyuncu 2 Satırı
            HStack(spacing: 0) {
                Text(player2Name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.zinc400)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 6) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        Text(sets[idx].1)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc300)
                            .frame(width: 28, height: 26)
                            .background(Color.zinc850)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.zinc800, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 2)
        }
        .padding(.vertical, 4)
    }
    
    private func parseScore(_ score: String) -> [(String, String)] {
        let setStrings = score.components(separatedBy: ", ")
        return setStrings.map { setStr in
            let parts = setStr.components(separatedBy: "-")
            if parts.count == 2 {
                return (parts[0], parts[1])
            }
            return ("-", "-")
        }
    }
}
