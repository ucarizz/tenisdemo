//
//  DesignSystem.swift
//  tenisdemo
//
//  Created for Modern Sports Analytics & Linear / Vercel Minimal Aesthetic
//

import SwiftUI
import UIKit

// MARK: - Zinc / Slate Color Palette & Sports Analytics Accents
extension Color {
    // Nötr Taban (Arka Plan & Kartlar)
    static let zinc950 = Color(red: 9/255, green: 9/255, blue: 11/255)   // #09090b - Primary canvas background
    static let zinc900 = Color(red: 24/255, green: 24/255, blue: 27/255) // #18181b - Surface / card background
    static let zinc850 = Color(red: 32/255, green: 32/255, blue: 36/255) // #202024 - Elevated surface / active state
    static let zinc800 = Color(red: 39/255, green: 39/255, blue: 42/255) // #27272a - Default 1px crisp border
    static let zinc700 = Color(red: 63/255, green: 63/255, blue: 70/255) // #3f3f46 - Strong border / separator
    static let zinc600 = Color(red: 82/255, green: 82/255, blue: 91/255) // #52525b - Subtle icons / muted labels
    static let zinc500 = Color(red: 113/255, green: 113/255, blue: 122/255) // #71717a - Secondary labels / placeholders
    static let zinc400 = Color(red: 161/255, green: 161/255, blue: 170/255) // #a1a1aa - Secondary text
    static let zinc300 = Color(red: 212/255, green: 212/255, blue: 216/255) // #d4d4d8 - Primary icons / active controls
    static let zinc200 = Color(red: 228/255, green: 228/255, blue: 231/255) // #e4e4e7 - High-contrast text
    static let zinc100 = Color(red: 244/255, green: 244/255, blue: 245/255) // #f4f4f5 - High-emphasis foreground
    static let zinc50  = Color(red: 250/255, green: 250/255, blue: 250/255) // #fafafa - Pure contrast white

    // MARK: - Noktasal Aksan Renkleri
    // 1. Birincil Enerji / Canlı Durum (#CCFF00 / Lime-400) - Ana CTA, Canlı Rozetler, Servis Vurgusu
    static let tennisVolt = Color(red: 204/255, green: 255/255, blue: 0/255)
    
    // 2. Başarı / Kort Tonu (#15803D / Emerald-500/700) - Galibiyetler, Tamamlanmış Setler, Onay
    static let courtGreen = Color(red: 21/255, green: 128/255, blue: 61/255)
    
    // 3. Sosyal / Seviye Mini Rozetleri (Soft renkli metin, koyu/transparan arka plan)
    static let badgeBlue = Color(red: 56/255, green: 189/255, blue: 248/255)   // NTRP seviyesi / Bilgi
    static let badgeAmber = Color(red: 251/255, green: 191/255, blue: 36/255)  // Bekleyen / Dikkat
    static let badgeRed = Color(red: 248/255, green: 113/255, blue: 113/255)   // Hata / Uyarı

    // Fonksiyonel Uyumluluk
    static let statusGreen = courtGreen
    static let statusOrange = badgeAmber
    static let statusRed = badgeRed
}

extension UIColor {
    static let zinc950 = UIColor(red: 9/255, green: 9/255, blue: 11/255, alpha: 1.0)
    static let zinc900 = UIColor(red: 24/255, green: 24/255, blue: 27/255, alpha: 1.0)
    static let zinc800 = UIColor(red: 39/255, green: 39/255, blue: 42/255, alpha: 1.0)
    static let zinc500 = UIColor(red: 113/255, green: 113/255, blue: 122/255, alpha: 1.0)
    static let zinc50  = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
    static let tennisVolt = UIColor(red: 204/255, green: 255/255, blue: 0/255, alpha: 1.0)
    static let courtGreen = UIColor(red: 21/255, green: 128/255, blue: 61/255, alpha: 1.0)
}

// MARK: - Mini Soft Rozet Bileşeni (NTRP / Maç Tipi / Canlı Durum)
struct SportBadge: View {
    let text: String
    var color: Color = .tennisVolt
    var isLive: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            if isLive {
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
            }
            Text(text)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2.5)
        .background(color.opacity(0.10))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - View Modifiers for Linear/Vercel Components
struct ZincCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 6
    var backgroundColor: Color = .zinc900
    var borderColor: Color = .zinc800

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

struct ZincBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = 6
    var borderColor: Color = .zinc800

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

extension View {
    /// Applies Linear-style flat surface with a crisp 1px border. No shadows.
    func zincCard(cornerRadius: CGFloat = 6, backgroundColor: Color = .zinc900, borderColor: Color = .zinc800) -> some View {
        self.modifier(ZincCardModifier(cornerRadius: cornerRadius, backgroundColor: backgroundColor, borderColor: borderColor))
    }

    func zincCard(radius: CGFloat, backgroundColor: Color = .zinc900, borderColor: Color = .zinc800) -> some View {
        self.modifier(ZincCardModifier(cornerRadius: radius, backgroundColor: backgroundColor, borderColor: borderColor))
    }

    /// Applies 1px border with constrained corner radius.
    func zincBorder(cornerRadius: CGFloat = 6, borderColor: Color = .zinc800) -> some View {
        self.modifier(ZincBorderModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }

    func zincBorder(radius: CGFloat, borderColor: Color = .zinc800) -> some View {
        self.modifier(ZincBorderModifier(cornerRadius: radius, borderColor: borderColor))
    }
}
