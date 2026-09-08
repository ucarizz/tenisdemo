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
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.zinc400)
                    .tracking(1.0)
                    .padding(.top, 2)
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                
                if !tracker.isTracking {
                    // Takip Başlatma Ekranı
                    VStack(spacing: 8) {
                        Image(systemName: "gauge.with.needle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.zinc500)
                        
                        Text("Vuruş hızınızı ve ivmenizi anlık ölçün.")
                            .font(.system(size: 10))
                            .foregroundColor(.zinc400)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            tracker.startTracking()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10))
                                Text("TAKİBİ BAŞLAT")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .background(Color.tennisVolt)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 2)
                        
                        Text("⚠️ Saati baskın kolunuza takmalısınız.")
                            .font(.system(size: 8))
                            .foregroundColor(.zinc500)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                    .padding(.top, 4)
                } else {
                    // Takip Ekranı (Canlı Veri)
                    VStack(spacing: 8) {
                        // Son Vuruş (Hero Hız Göstergesi)
                        VStack(spacing: 2) {
                            Text("SON VURUŞ HIZI")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .tracking(0.5)
                            
                            Text(tracker.lastSwingSpeedKmh > 0 ? String(format: "%.0f", tracker.lastSwingSpeedKmh) : "—")
                                .font(.system(size: 38, weight: .bold, design: .monospaced))
                                .foregroundColor(tracker.lastSwingSpeedKmh > 0 ? .tennisVolt : .zinc50)
                            
                            Text("KM / H")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc500)
                                .tracking(1.0)
                            
                            HStack(spacing: 12) {
                                Text(tracker.lastSwingType.uppercased())
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.zinc200)
                                
                                Text(String(format: "%.1f G", tracker.lastAccelerationG))
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(.zinc500)
                            }
                            .padding(.top, 2)
                        }
                        .padding(.vertical, 4)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 1)
                        
                        // Takibi Durdurma Butonu
                        Button(action: {
                            tracker.stopTracking()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 9))
                                Text("TAKİBİ DURDUR")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.statusRed)
                            .frame(maxWidth: .infinity, minHeight: 26)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.statusRed.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Son Vuruşlar Listesi (Kort Çizgili Log)
                        if !tracker.recentSwings.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SON VURUŞLAR")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundColor(.zinc500)
                                    .tracking(0.5)
                                    .padding(.top, 2)
                                
                                ForEach(tracker.recentSwings) { swing in
                                    VStack(spacing: 0) {
                                        HStack {
                                            Text(swing.swingType.uppercased())
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(.zinc200)
                                            Spacer()
                                            Text(String(format: "%.0f km/h", swing.speedKmh))
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(.zinc100)
                                            Text(String(format: "%.1fG", swing.accelerationG))
                                                .font(.system(size: 8, design: .monospaced))
                                                .foregroundColor(.zinc500)
                                        }
                                        .padding(.vertical, 3)
                                        
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
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    SwingTrackerView()
}
