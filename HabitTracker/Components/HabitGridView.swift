//
//  HabitGridView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct HabitGridView: View {
    let habits: [Habit]
    let onHabitTap: (Habit) -> Void
    let onHabitLongPress: (Habit) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(habits, id: \.id) { habit in
                HabitTileView(habit: habit) {
                    onHabitTap(habit)
                }
                .contextMenu {
                    Button {
                        onHabitLongPress(habit)
                    } label: {
                        Label("Edit Habit", systemImage: "pencil")
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 45)
                .fill(Color.cardWhite)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.backgroundCream
            .ignoresSafeArea()
        
        HabitGridView(
            habits: Habit.sampleHabits,
            onHabitTap: { _ in },
            onHabitLongPress: { _ in }
        )
        .padding()
    }
}
