//
//  Color+Extensions.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

extension Color {
    // MARK: - App Colors (Adaptive for Dark Mode)
    
    /// Background cream (light) / dark gray (dark)
    static let backgroundCream = Color("BackgroundColor")
    
    /// Card white (light) / dark card (dark)
    static let cardWhite = Color("CardColor")
    
    /// Primary text - adapts automatically
    static let primaryText = Color("TextColor")
    
    /// Success green: #39D45C
    static let successGreen = Color(red: 57/255, green: 212/255, blue: 92/255)
    
    /// Danger red: #D4424D
    static let dangerRed = Color(red: 212/255, green: 66/255, blue: 77/255)
    
    /// Neutral gray: #D9D9D9
    static let neutralGray = Color(red: 217/255, green: 217/255, blue: 217/255)
    
    /// Icy blue for frozen habits: #7DD3FC
    static let icyBlue = Color(red: 125/255, green: 211/255, blue: 252/255)
    
    /// Darker icy blue: #38BDF8
    static let icyBlueDark = Color(red: 56/255, green: 189/255, blue: 248/255)
    
    // MARK: - Semantic Colors
    
    static let habitTileBackground = cardWhite
    static let habitTileCompleted = successGreen
    static let habitTileIncomplete = neutralGray
    static let habitTileFrozen = icyBlue
    
    static let streakFire = Color.orange
}

// MARK: - Gradient Extensions

extension LinearGradient {
    static let habitCardGradient = LinearGradient(
        colors: [Color.cardWhite, Color.cardWhite.opacity(0.95)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let frozenGradient = LinearGradient(
        colors: [Color.icyBlue, Color.icyBlueDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
