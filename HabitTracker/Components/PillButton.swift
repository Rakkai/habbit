//
//  PillButton.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct PillButton: View {
    let title: String
    var icon: String? = nil
    var iconPosition: IconPosition = .leading
    let action: () -> Void
    
    enum IconPosition {
        case leading
        case trailing
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if iconPosition == .leading, let icon {
                    Text(icon)
                        .font(.system(size: 20))
                }
                
                Text(title)
                    .font(.custom("PTSans-Regular", size: 18))
                    .foregroundColor(.primaryText)
                
                if iconPosition == .trailing, let icon {
                    Text(icon)
                        .font(.system(size: 20))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(Color.cardWhite)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Add Habit Button") {
    ZStack {
        Color.backgroundCream
            .ignoresSafeArea()
        
        PillButton(title: "Add / edit habit", icon: "✏️") {
            print("Tapped")
        }
        .padding()
    }
}

#Preview("Dashboard Button") {
    ZStack {
        Color.backgroundCream
            .ignoresSafeArea()
        
        PillButton(title: "Go to analysis dashboard") {
            print("Tapped")
        }
        .padding()
    }
}
