//
//  ChatDesignSystem.swift
//  Pine
//
//  Created by Bing-Chang Lai on 1/10/26.
//

import SwiftUI

// Extension to support light/dark mode colors
extension Color {
    init(light: Color, dark: Color) {
        self.init(NSColor(name: nil) { appearance in
            switch appearance.name {
            case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
                return NSColor(dark)
            default:
                return NSColor(light)
            }
        })
    }
}

struct ChatColors {
    // User messages
    static let userBubble = Color(red: 0.0, green: 0.48, blue: 1.0)  // iOS blue (same in both modes)
    static let userText = Color.white  // White text on blue works in both modes

    // Assistant messages
    static let assistantBubble = Color(
        light: Color(white: 0.95),  // Light gray for light mode
        dark: Color(white: 0.20)    // Dark gray for dark mode
    )
    static let assistantText = Color.primary

    // System messages
    static let systemBubble = Color(
        light: Color(white: 0.97),  // Very light gray for light mode
        dark: Color(white: 0.15)    // Darker gray for dark mode
    )
    static let systemText = Color.secondary

    // Tool sections
    static let toolBubble = Color(
        light: Color(red: 0.98, green: 0.96, blue: 0.90),  // Warm beige for light mode
        dark: Color(red: 0.25, green: 0.23, blue: 0.18)    // Dark warm brown for dark mode
    )
    static let toolAccent = Color(
        light: Color(red: 0.8, green: 0.6, blue: 0.2),   // Amber for light mode
        dark: Color(red: 0.9, green: 0.7, blue: 0.3)     // Brighter amber for dark mode
    )
    static let toolText = Color.primary
}

struct ChatTypography {
    static let messageFont = Font.system(.body)
    static let messageLineSpacing: CGFloat = 4

    static let labelFont = Font.system(.caption, weight: .medium)
    static let labelText = Color.secondary

    static let toolFont = Font.system(.caption, design: .monospaced)
}

struct ChatLayout {
    static let bubbleCornerRadius: CGFloat = 16
    static let bubblePadding: CGFloat = 12
    static let maxBubbleWidth: CGFloat = 600
    static let bubbleSpacing: CGFloat = 8
    static let shadowRadius: CGFloat = 2
    static let shadowOpacity: CGFloat = 0.1
}
