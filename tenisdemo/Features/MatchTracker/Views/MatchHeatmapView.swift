//
//  MatchHeatmapView.swift
//  tenisdemo
//
//  Created by Antigravity on 09.08.2026.
//

import SwiftUI
import CoreLocation

struct HeatmapPoint: Identifiable {
    let id = UUID()
    let x: CGFloat // Relative X position on court canvas (0.0 to 1.0)
    let y: CGFloat // Relative Y position on court canvas (0.0 to 1.0)
    let weight: Double
}

struct MatchHeatmapView: View {
    let locations: [TrackedLocation]
    
    private let gridPrecision = 0.000015
    
    var heatmapPoints: [HeatmapPoint] {
        guard !locations.isEmpty else { return [] }
        
        let lats = locations.map { $0.latitude }
        let lons = locations.map { $0.longitude }
        
        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLon = lons.min(), let maxLon = lons.max() else { return [] }
        
        let latRange = (maxLat - minLat) == 0 ? 0.00001 : (maxLat - minLat)
        let lonRange = (maxLon - minLon) == 0 ? 0.00001 : (maxLon - minLon)
        
        // Group points for density calculation
        var grid: [String: (count: Int, lat: Double, lon: Double)] = [:]
        for loc in locations {
            let roundedLat = (loc.latitude / gridPrecision).rounded() * gridPrecision
            let roundedLon = (loc.longitude / gridPrecision).rounded() * gridPrecision
            let key = String(format: "%.6f,%.6f", roundedLat, roundedLon)
            
            if let existing = grid[key] {
                grid[key] = (count: existing.count + 1, lat: existing.lat, lon: existing.lon)
            } else {
                grid[key] = (count: 1, lat: roundedLat, lon: roundedLon)
            }
        }
        
        guard let maxCount = grid.values.map({ $0.count }).max(), maxCount > 0 else { return [] }
        
        return grid.values.map { item in
            let weight = Double(item.count) / Double(maxCount)
            
            // Map GPS to relative court canvas coordinates (0.0 to 1.0)
            let relativeX = CGFloat((item.lon - minLon) / lonRange)
            let relativeY = CGFloat((item.lat - minLat) / latRange)
            
            return HeatmapPoint(
                x: relativeX,
                // Invert Y because screen coordinates flow top-to-bottom, whereas latitude flows bottom-to-top
                y: 1.0 - relativeY,
                weight: max(0.1, weight)
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("KORT HAREKET ISI HARİTASI")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.zinc400)
                        .tracking(1)
                    
                    Text("\(locations.count) veri noktası analiz edildi")
                        .font(.system(size: 11))
                        .foregroundColor(.zinc500)
                }
                
                Spacer()
                
                // Color Legend
                HStack(spacing: 8) {
                    LegendItem(color: .statusRed, label: "Yoğun")
                    LegendItem(color: .statusOrange, label: "Orta")
                    LegendItem(color: .statusGreen, label: "Az")
                }
            }
            .padding(.horizontal, 4)
            
            if locations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.zinc500)
                    Text("Konum verisi bulunamadı.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.zinc300)
                    Text("Maç esnasında konum takibi kapalıydı veya yeterli GPS sinyali alınamadı.")
                        .font(.system(size: 11))
                        .foregroundColor(.zinc500)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .zincCard(radius: 8)
            } else {
                // Tennis Court Drawing
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    
                    ZStack {
                        // Court Dark Clay Green Background
                        Color(red: 0.08, green: 0.12, blue: 0.10)
                            .cornerRadius(8)
                        
                        // Tennis Court Lines Canvas
                        Canvas { context, size in
                            let width = size.width
                            let height = size.height
                            
                            // 8% padding on margins
                            let marginX = width * 0.08
                            let marginY = height * 0.06
                            
                            let cw = width - (2 * marginX)  // Court inner width
                            let ch = height - (2 * marginY) // Court inner height
                            
                            // 1. Doubles Sidelines & Baselines (Outer Boundaries)
                            let outerRect = CGRect(x: marginX, y: marginY, width: cw, height: ch)
                            context.stroke(Path(outerRect), with: .color(.white.opacity(0.55)), lineWidth: 2)
                            
                            // 2. Singles Sidelines (Inner Vertical Lines)
                            let singlesOffset = cw * 0.125
                            var singlesPath = Path()
                            singlesPath.move(to: CGPoint(x: marginX + singlesOffset, y: marginY))
                            singlesPath.addLine(to: CGPoint(x: marginX + singlesOffset, y: marginY + ch))
                            
                            singlesPath.move(to: CGPoint(x: marginX + cw - singlesOffset, y: marginY))
                            singlesPath.addLine(to: CGPoint(x: marginX + cw - singlesOffset, y: marginY + ch))
                            context.stroke(singlesPath, with: .color(.white.opacity(0.4)), lineWidth: 1.5)
                            
                            // 3. Center Net Line
                            var netPath = Path()
                            netPath.move(to: CGPoint(x: marginX, y: marginY + (ch / 2)))
                            netPath.addLine(to: CGPoint(x: marginX + cw, y: marginY + (ch / 2)))
                            context.stroke(netPath, with: .color(.white.opacity(0.85)), lineWidth: 3)
                            
                            // 4. Service Lines (Horizontal lines at 6.4m from net)
                            let serviceOffset = (ch / 2) * 0.538
                            var servicePath = Path()
                            // Top service line
                            servicePath.move(to: CGPoint(x: marginX + singlesOffset, y: marginY + (ch / 2) - serviceOffset))
                            servicePath.addLine(to: CGPoint(x: marginX + cw - singlesOffset, y: marginY + (ch / 2) - serviceOffset))
                            // Bottom service line
                            servicePath.move(to: CGPoint(x: marginX + singlesOffset, y: marginY + (ch / 2) + serviceOffset))
                            servicePath.addLine(to: CGPoint(x: marginX + cw - singlesOffset, y: marginY + (ch / 2) + serviceOffset))
                            context.stroke(servicePath, with: .color(.white.opacity(0.5)), lineWidth: 2)
                            
                            // 5. Center Service Line
                            var centerServicePath = Path()
                            centerServicePath.move(to: CGPoint(x: marginX + (cw / 2), y: marginY + (ch / 2) - serviceOffset))
                            centerServicePath.addLine(to: CGPoint(x: marginX + (cw / 2), y: marginY + (ch / 2) + serviceOffset))
                            context.stroke(centerServicePath, with: .color(.white.opacity(0.5)), lineWidth: 1.5)
                            
                            // 6. Center Marks (Small notches on top and bottom baselines)
                            let markLength = ch * 0.02
                            var centerMarks = Path()
                            // Top baseline center mark
                            centerMarks.move(to: CGPoint(x: marginX + (cw / 2), y: marginY))
                            centerMarks.addLine(to: CGPoint(x: marginX + (cw / 2), y: marginY + markLength))
                            // Bottom baseline center mark
                            centerMarks.move(to: CGPoint(x: marginX + (cw / 2), y: marginY + ch))
                            centerMarks.addLine(to: CGPoint(x: marginX + (cw / 2), y: marginY + ch - markLength))
                            context.stroke(centerMarks, with: .color(.white.opacity(0.55)), lineWidth: 2)
                        }
                        
                        // Overlay density-based heatmap coordinate dots
                        ForEach(heatmapPoints) { pt in
                            let marginX = w * 0.08
                            let marginY = h * 0.06
                            let cw = w - (2 * marginX)
                            let ch = h - (2 * marginY)
                            
                            let posX = marginX + (pt.x * cw)
                            let posY = marginY + (pt.y * ch)
                            
                            let opacity = pt.weight * 0.75 + 0.15
                            let color = pt.weight > 0.65 ? Color.statusRed : (pt.weight > 0.3 ? Color.statusOrange : Color.statusGreen)
                            let size = w * 0.07 // responsive dot diameter
                            
                            Circle()
                                .fill(color.opacity(opacity))
                                .frame(width: size, height: size)
                                .blur(radius: size * 0.45)
                                .position(x: posX, y: posY)
                        }
                    }
                }
                .frame(height: 380) // Standard tennis court visual ratio height
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.zinc800, lineWidth: 1)
                )
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.zinc400)
        }
    }
}
