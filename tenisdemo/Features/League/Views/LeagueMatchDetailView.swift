//
//  LeagueMatchDetailView.swift
//  tenisdemo
//
//  Created by Antigravity on 07.08.2026.
//

import SwiftUI

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
    
    var body: some View {
        ZStack {
            // Premium Koyu Arka Plan
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.12), Color(red: 0.03, green: 0.04, blue: 0.06)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Maç Kartı Detayı
                    VStack(spacing: 16) {
                        HStack {
                            Label(match.matchDate, systemImage: "calendar")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(match.isCompleted ? "TAMAMLANDI" : "BEKLENİYOR")
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(match.isCompleted ? Color.emerald.opacity(0.15) : Color.orange.opacity(0.15))
                                .foregroundColor(match.isCompleted ? Color.emerald : Color.orange)
                                .cornerRadius(4)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.08))
                        
                        HStack(spacing: 12) {
                            // Oyuncu 1
                            VStack(spacing: 6) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text(match.player1Name)
                                    .font(.system(.body, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // VS Ortadaki Rozet
                            Text("VS")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .frame(width: 32, height: 32)
                                .background(Color(red: 0.86, green: 0.98, blue: 0.22))
                                .clipShape(Circle())
                            
                            // Oyuncu 2
                            VStack(spacing: 6) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text(match.player2Name)
                                    .font(.system(.body, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 8)
                        
                        // Detaylı Set Skorları (Scoreboard)
                        if let score = match.score, !score.isEmpty {
                            Divider()
                                .background(Color.white.opacity(0.08))
                            
                            TennisScoreboardView(
                                player1Name: match.player1Name,
                                player2Name: match.player2Name,
                                scoreString: score
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    
                    // 1.5. Sayı Geçmişi (Puan Akışı)
                    if let history = match.pointHistories, !history.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("MAÇ SAYI GEÇMİŞİ")
                                .font(.system(.subheadline, design: .rounded))
                                .bold()
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(history.sorted(by: { $0.sequenceNumber < $1.sequenceNumber })) { pt in
                                        HStack {
                                            Text("#\(pt.sequenceNumber)")
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(.gray)
                                                .frame(width: 28, alignment: .leading)
                                            
                                            // Servis atan ikonu
                                            Image(systemName: "tennisball.fill")
                                                .font(.system(size: 8))
                                                .foregroundColor(pt.server.lowercased() == "p1" ? Color(red: 0.86, green: 0.98, blue: 0.22) : .orange)
                                            
                                            Text(pt.server.lowercased() == "p1" ? "\(match.player1Name)" : "\(match.player2Name)")
                                                .font(.system(size: 11, design: .rounded))
                                                .foregroundColor(.white.opacity(0.8))
                                                .lineLimit(1)
                                            
                                            Spacer()
                                            
                                            // Sayı Skoru (Örn: 40 - 15)
                                            Text("\(pt.p1Points) - \(pt.p2Points)")
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.white.opacity(0.06))
                                                .cornerRadius(4)
                                            
                                            // Oyun durum bilgisi (Örn: Oyun: 2-1)
                                            Text("Set: \(pt.p1Sets)-\(pt.p2Sets) (Oyun: \(pt.p1Games)-\(pt.p2Games))")
                                                .font(.system(size: 9, design: .rounded))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 8)
                                        .background(Color.white.opacity(0.02))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .frame(maxHeight: 180)
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                    }
                    
                    // 2. Vuruş Analizi Bölümü
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MAÇ VURUŞ ANALİZİ")
                            .font(.system(.subheadline, design: .rounded))
                            .bold()
                            .foregroundColor(.gray)
                            .tracking(1)
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView("Vuruşlar yükleniyor...")
                                    .tint(Color(red: 0.86, green: 0.98, blue: 0.22))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.vertical, 24)
                        } else if let errorMessage = viewModel.errorMessage {
                            Text("Hata: \(errorMessage)")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.vertical, 12)
                        } else if viewModel.records.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "gauge.badge.minus")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                                Text("Bu maç için kaydedilmiş vuruş bulunamadı.")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color.white.opacity(0.02))
                            .cornerRadius(12)
                        } else {
                            // İstatistik Kartları
                            HStack(spacing: 12) {
                                SummaryStatBox(title: "Ort. Hız", value: String(format: "%.0f km/h", viewModel.averageSpeed), color: Color(red: 0.86, green: 0.98, blue: 0.22))
                                SummaryStatBox(title: "Maks Hız", value: String(format: "%.0f km/h", viewModel.maxSpeed), color: Color(red: 0.1, green: 0.8, blue: 0.5))
                                SummaryStatBox(title: "Toplam", value: "\(viewModel.records.count) Vuruş", color: .orange)
                            }
                            
                            // Vuruş Kayıtları Listesi
                            VStack(spacing: 10) {
                                ForEach(viewModel.records) { record in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(typeColor(record.swingType).opacity(0.15))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Image(systemName: "tennis.racket")
                                                    .foregroundColor(typeColor(record.swingType))
                                                    .font(.system(size: 14))
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(record.swingType.uppercased())
                                                .font(.system(.caption, design: .rounded))
                                                .bold()
                                                .foregroundColor(.white)
                                            Text(formatTime(record.recordedAt))
                                                .font(.system(size: 9))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(String(format: "%.0f km/h", record.speedKmh))
                                                .font(.system(.subheadline, design: .monospaced))
                                                .bold()
                                                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                                            Text(String(format: "%.1f G", record.accelerationG))
                                                .font(.system(size: 9))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.02))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Maç Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSwings(for: match.id)
        }
    }
    
    private func typeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "forehand":
            return Color(red: 0.1, green: 0.8, blue: 0.5)
        case "backhand":
            return .orange
        case "servis":
            return Color(red: 0.86, green: 0.98, blue: 0.22)
        default:
            return .gray
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

struct TennisScoreboardView: View {
    let player1Name: String
    let player2Name: String
    let scoreString: String
    
    var body: some View {
        let sets = parseScore(scoreString)
        
        VStack(spacing: 8) {
            // Sütun Başlıkları (S1, S2, S3...)
            HStack(spacing: 0) {
                Text("Set Dağılımı")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        Text("S\(idx + 1)")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .frame(width: 30, alignment: .center)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            // Oyuncu 1 Satırı
            HStack(spacing: 0) {
                Text(player1Name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        Text(sets[idx].0)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            // Oyuncu 2 Satırı
            HStack(spacing: 0) {
                Text(player2Name)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    ForEach(0..<sets.count, id: \.self) { idx in
                        Text(sets[idx].1)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
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
