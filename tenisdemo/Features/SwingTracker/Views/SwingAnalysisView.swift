//
//  SwingAnalysisView.swift
//  tenisdemo
//
//  Created by Antigravity on 07.08.2026.
//  Refactored for Linear / Vercel Minimal Aesthetic
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
        NavigationStack {
            ZStack {
                Color.zinc950.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    if viewModel.isLoading && viewModel.records.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(.zinc400)
                        Text("Yükleniyor...")
                            .font(.system(size: 13))
                            .foregroundColor(.zinc500)
                        Spacer()
                    } else if let errorMessage = viewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 28))
                                .foregroundColor(.zinc500)
                            Text(errorMessage)
                                .foregroundColor(.zinc400)
                                .font(.system(size: 13))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            Button("Tekrar Dene") {
                                Task { await viewModel.loadHistory() }
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc950)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.zinc50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc300, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        Spacer()
                    } else {
                        // Summary Metric Bar (Wimbledon Court-Line Table)
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                            
                            HStack(spacing: 0) {
                                SummaryStatBox(
                                    title: "ORT. HIZ",
                                    value: viewModel.records.isEmpty ? "—" : String(format: "%.0f km/h", viewModel.averageSpeed)
                                )
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 1, height: 36)
                                
                                SummaryStatBox(
                                    title: "MAKS. HIZ",
                                    value: viewModel.records.isEmpty ? "—" : String(format: "%.0f km/h", viewModel.maxSpeed),
                                    accentColor: .tennisVolt
                                )
                                .padding(.leading, 12)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 1, height: 36)
                                
                                SummaryStatBox(
                                    title: "TOPLAM",
                                    value: "\(viewModel.records.count)"
                                )
                                .padding(.leading, 12)
                            }
                            .padding(.vertical, 8)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Swing Records List
                        if viewModel.records.isEmpty {
                            Spacer()
                            VStack(spacing: 6) {
                                Text("Henüz vuruş kaydı bulunamadı")
                                    .foregroundColor(.zinc300)
                                    .font(.system(size: 14, weight: .medium))
                                Text("Apple Watch uygulamasından vuruş analizi başlatıldığında burada listelenir.")
                                    .foregroundColor(.zinc500)
                                    .font(.system(size: 12))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(viewModel.records) { record in
                                        VStack(spacing: 0) {
                                            HStack(spacing: 12) {
                                                // Swing Type
                                                Text(record.swingType.uppercased())
                                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                    .foregroundColor(.zinc200)
                                                    .tracking(0.5)
                                                
                                                // Date
                                                Text(formatDate(record.recordedAt))
                                                    .font(.system(size: 11, design: .monospaced))
                                                    .foregroundColor(.zinc500)
                                                
                                                Spacer()
                                                
                                                // Metrics
                                                HStack(spacing: 12) {
                                                    Text(String(format: "%.0f km/h", record.speedKmh))
                                                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                                                        .foregroundColor(.zinc100)
                                                    
                                                    Text(String(format: "%.1f G", record.accelerationG))
                                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                        .foregroundColor(.zinc500)
                                                }
                                            }
                                            .padding(.vertical, 11)
                                            
                                            Rectangle()
                                                .fill(Color.white.opacity(0.08))
                                                .frame(height: 1)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                                .padding(.bottom, 24)
                            }
                            .refreshable {
                                await viewModel.loadHistory()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Vuruş Analizi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.zinc950, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await viewModel.loadHistory() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.zinc400)
                    }
                }
            }
            .task {
                await viewModel.loadHistory()
            }
        }
    }
    
    private func formatDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd.MM.yy HH:mm"
        
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

// MARK: - Minimal Summary Metric Box (Cardless)
struct SummaryStatBox: View {
    let title: String
    let value: String
    var accentColor: Color? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.zinc500)
                .tracking(1.0)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(accentColor ?? .zinc100)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
