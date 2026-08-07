//
//  SwingTrackerView.swift
//  tenisdemo Watch App
//
//  Created by Antigravity on 07.08.2026.
//

import SwiftUI

struct SwingTrackerView: View {
    @StateObject private var tracker = SwingTracker()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Başlık
                Text("VURUŞ ANALİZİ")
                    .font(.system(.footnote, design: .rounded))
                    .bold()
                    .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22)) // Neon sarı/yeşil
                
                if !tracker.isTracking {
                    // Takip Başlatma Ekranı
                    VStack(spacing: 6) {
                        Image(systemName: "gauge.with.needle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                        
                        Text("Vuruş hızınızı ve ivmenizi anlık ölçün.")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            tracker.startTracking()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Takibi Başlat")
                            }
                            .font(.system(.body, design: .rounded).bold())
                        }
                        .tint(Color(red: 0.1, green: 0.8, blue: 0.5)) // Yeşil buton
                        
                        Text("⚠️ Doğru analiz için saati raketi tuttuğunuz (baskın) kolunuza takmalısınız.")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .padding(.top, 4)
                } else {
                    // Takip Ekranı (Canlı Veri)
                    VStack(spacing: 4) {
                        // Son Vuruş Kartı
                        VStack(spacing: 2) {
                            Text("SON VURUŞ HIZI")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                            
                            Text(tracker.lastSwingSpeedKmh > 0 ? String(format: "%.0f km/h", tracker.lastSwingSpeedKmh) : "- km/h")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                            
                            HStack(spacing: 12) {
                                Text("Tür: \(tracker.lastSwingType)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("İvme: \(String(format: "%.1fG", tracker.lastAccelerationG))")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.86, green: 0.98, blue: 0.22).opacity(0.3), lineWidth: 1)
                        )
                        
                        // Takibi Durdurma Butonu
                        Button(action: {
                            tracker.stopTracking()
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Takibi Durdur")
                            }
                            .font(.system(.caption, design: .rounded).bold())
                        }
                        .tint(.red)
                        .frame(height: 28)
                        
                        // Son Vuruşlar Listesi (Görsel Log)
                        if !tracker.recentSwings.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SON VURUŞLAR")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                                    .bold()
                                    .padding(.top, 4)
                                
                                ForEach(tracker.recentSwings) { swing in
                                    HStack {
                                        Text(swing.swingType)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(String(format: "%.0f km/h", swing.speedKmh))
                                            .font(.system(size: 10, design: .monospaced))
                                            .bold()
                                            .foregroundColor(Color(red: 0.86, green: 0.98, blue: 0.22))
                                        Text(String(format: "%.1fG", swing.accelerationG))
                                            .font(.system(size: 8))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    SwingTrackerView()
}
