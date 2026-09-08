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
                    // 1. Maç Detayı & Skor Tahtası (Editorial Wimbledon Bulletin)
                    VStack(spacing: 0) {
                        // Üst Bilgi Barı
                        HStack {
                            Text(match.matchDate)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.zinc500)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(match.isDouble ? "ÇİFTLER" : "TEKLER")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.zinc400)
                                    .tracking(1.0)
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(match.isCompleted ? Color.courtGreen : Color.badgeAmber)
                                        .frame(width: 5, height: 5)
                                    Text(match.isCompleted ? "TAMAMLANDI" : "BEKLENİYOR")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(match.isCompleted ? .courtGreen : .badgeAmber)
                                        .tracking(0.5)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                        
                        // Detaylı Set Skorları (Scoreboard) veya Karşılaşma Başlığı
                        if let score = match.score, !score.isEmpty {
                            TennisScoreboardView(
                                player1Name: match.player1Name,
                                player1Partner: match.isDouble ? match.player1PartnerName : nil,
                                player2Name: match.player2Name,
                                player2Partner: match.isDouble ? match.player2PartnerName : nil,
                                scoreString: score
                            )
                            .padding(.vertical, 12)
                        } else {
                            // Henüz skor girilmemiş maç
                            VStack(spacing: 12) {
                                HStack(spacing: 8) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(match.player1Name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.zinc100)
                                        if match.isDouble, let p1Partner = match.player1PartnerName {
                                            Text("& \(p1Partner)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.zinc500)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("vs")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.zinc500)
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(match.player2Name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.zinc100)
                                        if match.isDouble, let p2Partner = match.player2PartnerName {
                                            Text("& \(p2Partner)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.zinc500)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                    }
                    
                    // 1.5. Sayı Geçmişi (Puan Akışı)
                    if let history = match.pointHistories, !history.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SAYI GEÇMİŞİ")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .tracking(1.0)
                                .padding(.top, 8)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                            
                            VStack(spacing: 0) {
                                ForEach(history.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })) { pt in
                                    let isP1Server = pt.server.lowercased() == "p1" || pt.server.lowercased() == "player1" || pt.server == "SİZ"
                                    VStack(spacing: 0) {
                                        HStack(spacing: 8) {
                                            Text(String(format: "#%02d", pt.sequenceNumber + 1))
                                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                .foregroundColor(.zinc500)
                                                .frame(width: 32, alignment: .leading)
                                            
                                            Circle()
                                                .fill(Color.tennisVolt)
                                                .frame(width: 5, height: 5)
                                            
                                            Text(isP1Server ? "\(match.player1Name)" : "\(match.player2Name)")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.zinc200)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                            
                                            Text("\(pt.p1Points) — \(pt.p2Points)")
                                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                .foregroundColor(.zinc100)
                                                .tracking(1.0)
                                        }
                                        .padding(.vertical, 8)
                                        
                                        Rectangle()
                                            .fill(Color.white.opacity(0.06))
                                            .frame(height: 1)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 2. Koşu Mesafesi ve Isı Haritası
                    VStack(alignment: .leading, spacing: 8) {
                        Text("KORT HAREKET ANALİZİ")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc500)
                            .tracking(1.0)
                            .padding(.top, 8)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                        
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
                            .padding(.vertical, 24)
                        } else if !locations.isEmpty {
                            VStack(spacing: 12) {
                                HStack(alignment: .lastTextBaseline) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("TOPLAM KOŞU MESAFESİ")
                                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.zinc500)
                                            .tracking(1.0)
                                        Text(formatDistance(calculateTotalDistance(for: locations)))
                                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                                            .foregroundColor(.tennisVolt)
                                    }
                                    Spacer()
                                    Image(systemName: "figure.run")
                                        .font(.system(size: 15))
                                        .foregroundColor(.zinc400)
                                }
                                .padding(.vertical, 4)
                                
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
                            .padding(.vertical, 24)
                        }
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                    }
                    
                    // 3. Vuruş Hızları ve Analizi
                    VStack(alignment: .leading, spacing: 8) {
                        Text("VURUŞ ANALİZİ (APPLE WATCH)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc500)
                            .tracking(1.0)
                            .padding(.top, 8)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                        
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
                            .padding(.vertical, 24)
                        } else if viewModel.records.isEmpty {
                            HStack {
                                Spacer()
                                Text("Bu maça ait kayıtlı vuruş verisi bulunamadı.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.zinc500)
                                Spacer()
                            }
                            .padding(.vertical, 24)
                        } else {
                            VStack(spacing: 12) {
                                // 3 Kolonlu Metrik Tablosu
                                HStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("ORT. HIZ")
                                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                                            .foregroundColor(.zinc500)
                                            .tracking(1.0)
                                        Text(String(format: "%.0f km/h", viewModel.averageSpeed))
                                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                                            .foregroundColor(.zinc100)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(width: 1, height: 32)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("MAKS. HIZ")
                                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                                            .foregroundColor(.zinc500)
                                            .tracking(1.0)
                                        Text(String(format: "%.0f km/h", viewModel.maxSpeed))
                                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                                            .foregroundColor(.tennisVolt)
                                    }
                                    .padding(.leading, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(width: 1, height: 32)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("TOPLAM")
                                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                                            .foregroundColor(.zinc500)
                                            .tracking(1.0)
                                        Text("\(viewModel.records.count)")
                                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                                            .foregroundColor(.zinc100)
                                    }
                                    .padding(.leading, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.vertical, 8)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(height: 1)
                                
                                // Vuruş Kayıtları Listesi
                                VStack(spacing: 0) {
                                    ForEach(viewModel.records) { record in
                                        VStack(spacing: 0) {
                                            HStack {
                                                Text(record.swingType.uppercased())
                                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                    .foregroundColor(.zinc200)
                                                    .tracking(0.5)
                                                
                                                Text(formatTime(record.recordedAt))
                                                    .font(.system(size: 11, design: .monospaced))
                                                    .foregroundColor(.zinc500)
                                                    .padding(.leading, 6)
                                                
                                                Spacer()
                                                
                                                HStack(spacing: 12) {
                                                    Text(String(format: "%.0f km/h", record.speedKmh))
                                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                        .foregroundColor(.zinc100)
                                                    
                                                    Text(String(format: "%.1f G", record.accelerationG))
                                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                        .foregroundColor(.zinc500)
                                                }
                                            }
                                            .padding(.vertical, 8)
                                            
                                            Rectangle()
                                                .fill(Color.white.opacity(0.06))
                                                .frame(height: 1)
                                        }
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

// MARK: - Minimal Table Scoreboard (Wimbledon Style)
struct TennisScoreboardView: View {
    let player1Name: String
    var player1Partner: String? = nil
    let player2Name: String
    var player2Partner: String? = nil
    let scoreString: String
    
    var body: some View {
        let sets = parseScore(scoreString)
        
        VStack(spacing: 8) {
            // Sütun Başlıkları (S1, S2, S3...)
            HStack(spacing: 0) {
                Text("OYUNCULAR")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.zinc500)
                    .tracking(1.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 16) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        Text("S\(idx + 1)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.zinc500)
                            .frame(width: 24, alignment: .center)
                    }
                }
            }
            .padding(.bottom, 2)
            
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
            
            // Oyuncu 1 Satırı
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(player1Name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.zinc100)
                        .lineLimit(1)
                    if let p1Partner = player1Partner {
                        Text("& \(p1Partner)")
                            .font(.system(size: 11))
                            .foregroundColor(.zinc500)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 16) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        let s1 = Int(sets[idx].0) ?? 0
                        let s2 = Int(sets[idx].1) ?? 0
                        let won = s1 > s2
                        Text(sets[idx].0)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(won ? .courtGreen : .zinc400)
                            .frame(width: 24, alignment: .center)
                    }
                }
            }
            .padding(.vertical, 4)
            
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
            
            // Oyuncu 2 Satırı
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(player2Name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.zinc100)
                        .lineLimit(1)
                    if let p2Partner = player2Partner {
                        Text("& \(p2Partner)")
                            .font(.system(size: 11))
                            .foregroundColor(.zinc500)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 16) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        let s1 = Int(sets[idx].0) ?? 0
                        let s2 = Int(sets[idx].1) ?? 0
                        let won = s2 > s1
                        Text(sets[idx].1)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(won ? .courtGreen : .zinc400)
                            .frame(width: 24, alignment: .center)
                    }
                }
            }
            .padding(.vertical, 4)
        }
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
