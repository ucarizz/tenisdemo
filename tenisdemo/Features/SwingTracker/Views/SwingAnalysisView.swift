//
//  SwingAnalysisView.swift
//  tenisdemo
//
//  Created by Antigravity on 07.08.2026.
//

import SwiftUI

struct SwingRecordItem: Decodable, Identifiable {
    let id: Int
    let userId: Int
    let speedKmh: Double
    let accelerationG: Double
    let swingType: String
    let recordedAt: String // ISO String
}

class SwingAnalysisViewModel: ObservableObject {
    @Published var records: [SwingRecordItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    @MainActor
    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let client = URLSessionAPIClient()
            self.records = try await client.request(SwingEndpoint.getHistory(limit: 50))
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

struct SwingAnalysisView: View {
    @StateObject private var viewModel = SwingAnalysisViewModel()
    
    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 16) {
                    if viewModel.isLoading && viewModel.records.isEmpty {
                        ProgressView("Yükleniyor...")
                            .foregroundColor(.white)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Tekrar Dene") {
                                Task { await viewModel.loadHistory() }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 0.86, green: 0.98, blue: 0.22))
                            .foregroundColor(.black)
                        }
                    } else {
                        // Özet İstatistik Paneli
                        HStack(spacing: 12) {
                            SummaryStatBox(title: "Ort. Hız", value: viewModel.records.isEmpty ? "—" : String(format: "%.0f km/h", viewModel.averageSpeed), color: Color(red: 0.86, green: 0.98, blue: 0.22))
                            SummaryStatBox(title: "Maks Hız", value: viewModel.records.isEmpty ? "—" : String(format: "%.0f km/h", viewModel.maxSpeed), color: Color(red: 0.1, green: 0.8, blue: 0.5))
                            SummaryStatBox(title: "Toplam", value: "\(viewModel.records.count) Vuruş", color: .orange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Liste
                        if viewModel.records.isEmpty {
                            Spacer()
                            Text("Henüz vuruş kaydı bulunamadı.")
                                .foregroundColor(.white)
                                .font(.system(.headline, design: .rounded))
                            Text("Apple Watch uygulamasından Vuruş Analizi'ni başlatıp deneme yapın.")
                                .foregroundColor(.gray)
                                .font(.system(.caption, design: .rounded))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            Spacer()
                        } else {
                            List {
                                ForEach(viewModel.records) { record in
                                    HStack(spacing: 12) {
                                        // Vuruş türüne göre renk ve ikon
                                        Circle()
                                            .fill(typeColor(record.swingType).opacity(0.15))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "tennis.racket")
                                                    .foregroundColor(typeColor(record.swingType))
                                                    .font(.system(size: 16))
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(record.swingType.uppercased())
                                                .font(.system(.subheadline, design: .rounded))
                                                .bold()
                                                .foregroundColor(.white)
                                            Text(formatDate(record.recordedAt))
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(String(format: "%.0f km/h", record.speedKmh))
                                                .font(.system(.body, design: .monospaced))
                                                .bold()
                                                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                                            Text(String(format: "%.1f G", record.accelerationG))
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    .listRowBackground(Color.white.opacity(0.04))
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .refreshable {
                                await viewModel.loadHistory()
                            }
                        }
                    }
                }
            }
            .navigationTitle("VURUŞ ANALİZİ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await viewModel.loadHistory() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                    }
                }
            }
            .task {
                await viewModel.loadHistory()
            }
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
    
    private func formatDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
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

struct SummaryStatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .rounded))
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
