//
//  StreakBadge.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct StreakBadge: View {
    let count: Int
    let emoji: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .font(.custom("PTSans-Regular", size: 18))
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            Text(emoji)
                .font(.system(size: 24))
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        StreakBadge(count: 4, emoji: "❄️")
        StreakBadge(count: 30, emoji: "🔥")
    }
    .padding()
    .background(Color.backgroundCream)
}
