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
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.zinc400)
                    .padding(.top, 2)
                
                if !tracker.isTracking {
                    // Takip Başlatma Ekranı
                    VStack(spacing: 6) {
                        Image(systemName: "gauge.with.needle.fill")
                            .font(.system(size: 24))
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
                                    .font(.system(size: 11))
                                Text("Takibi Başlat")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.zinc950)
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .background(Color.zinc50)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 2)
                        
                        Text("⚠️ Saati raketi tuttuğunuz baskın kolunuza takmalısınız.")
                            .font(.system(size: 8))
                            .foregroundColor(.zinc500)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 2)
                    }
                    .padding(.top, 4)
                } else {
                    // Takip Ekranı (Canlı Veri)
                    VStack(spacing: 6) {
                        // Son Vuruş Kartı
                        VStack(spacing: 2) {
                            Text("SON VURUŞ HIZI")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(.zinc500)
                            
                            Text(tracker.lastSwingSpeedKmh > 0 ? String(format: "%.0f km/h", tracker.lastSwingSpeedKmh) : "- km/h")
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(.zinc50)
                            
                            HStack(spacing: 12) {
                                Text("Tür: \(tracker.lastSwingType)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.zinc200)
                                
                                Text("İvme: \(String(format: "%.1fG", tracker.lastAccelerationG))")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.zinc400)
                            }
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.zinc900)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.zinc800, lineWidth: 1)
                        )
                        
                        // Takibi Durdurma Butonu
                        Button(action: {
                            tracker.stopTracking()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 10))
                                Text("Takibi Durdur")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.statusRed)
                            .frame(maxWidth: .infinity, minHeight: 28)
                            .background(Color.zinc900)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.zinc800, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Son Vuruşlar Listesi (Görsel Log)
                        if !tracker.recentSwings.isEmpty {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("SON VURUŞLAR")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(.zinc500)
                                    .padding(.top, 2)
                                
                                ForEach(tracker.recentSwings) { swing in
                                    HStack {
                                        Text(swing.swingType)
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.zinc200)
                                        Spacer()
                                        Text(String(format: "%.0f km/h", swing.speedKmh))
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(.zinc100)
                                        Text(String(format: "%.1fG", swing.accelerationG))
                                            .font(.system(size: 8, design: .monospaced))
                                            .foregroundColor(.zinc500)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.zinc900)
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.zinc850, lineWidth: 1)
                                    )
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
