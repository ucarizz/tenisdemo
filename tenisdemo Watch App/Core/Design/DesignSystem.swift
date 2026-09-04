//
//  DesignSystem.swift
//  tenisdemo Watch App
//
//  Created for Linear / Vercel Minimal Aesthetic on Apple Watch
//

import SwiftUI

// MARK: - Zinc / Slate Color Palette
extension Color {
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

    // Restrained Functional Accents
    static let statusGreen = Color(red: 34/255, green: 197/255, blue: 94/255)  // #22c55e - Completed / Success / P1
    static let statusOrange = Color(red: 249/255, green: 115/255, blue: 22/255) // #f97316 - In Progress / P2
    static let statusRed = Color(red: 239/255, green: 68/255, blue: 68/255)    // #ef4444 - Alert / Destructive
}

// MARK: - View Modifiers for Linear/Vercel Components
struct WatchZincCardModifier: ViewModifier {
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

struct WatchZincBorderModifier: ViewModifier {
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
    /// Applies Linear-style flat surface with a crisp 1px border.
    func zincCard(cornerRadius: CGFloat = 6, backgroundColor: Color = .zinc900, borderColor: Color = .zinc800) -> some View {
        self.modifier(WatchZincCardModifier(cornerRadius: cornerRadius, backgroundColor: backgroundColor, borderColor: borderColor))
    }

    func zincCard(radius: CGFloat, backgroundColor: Color = .zinc900, borderColor: Color = .zinc800) -> some View {
        self.modifier(WatchZincCardModifier(cornerRadius: radius, backgroundColor: backgroundColor, borderColor: borderColor))
    }

    /// Applies 1px border with constrained corner radius.
    func zincBorder(cornerRadius: CGFloat = 6, borderColor: Color = .zinc800) -> some View {
        self.modifier(WatchZincBorderModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }

    func zincBorder(radius: CGFloat, borderColor: Color = .zinc800) -> some View {
        self.modifier(WatchZincBorderModifier(cornerRadius: radius, borderColor: borderColor))
    }
}
