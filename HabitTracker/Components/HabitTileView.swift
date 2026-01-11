//
//  HabitTileView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct HabitTileView: View {
    let habit: Habit
    let onTap: () -> Void
    
    /// The progress to display based on habit state
    private var displayProgress: Double {
        switch habit.state {
        case .onTrack:
            return habit.progressRemaining
        case .gracePeriod:
            return habit.gracePeriodProgress
        case .frozen:
            return 1.0
        case .streakLost:
            return 0.0
        }
    }
    
    /// The streak icon to display
    private var streakIcon: String {
        switch habit.state {
        case .frozen:
            return "❄️"
        case .streakLost:
            return ""
        default:
            return habit.currentStreak > 0 ? "🔥" : ""
        }
    }
    
    /// The text color for the streak
    private var streakColor: Color {
        switch habit.state {
        case .frozen:
            return .icyBlueDark
        case .streakLost:
            return .neutralGray
        default:
            return .primaryText
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Circular progress background
                CircularProgressView(
                    progress: displayProgress,
                    habitState: habit.state,
                    lineWidth: 6,
                    size: 100
                )
                
                // Content overlay
                VStack(spacing: 4) {
                    // Habit emoji
                    Text(habit.emoji)
                        .font(.system(size: 28))
                    
                    // Streak with icon
                    HStack(spacing: 2) {
                        Text("\(habit.currentStreak)")
                            .font(.custom("PTSans-Regular", size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(streakColor)
                        
                        if !streakIcon.isEmpty {
                            Text(streakIcon)
                                .font(.system(size: 10))
                        }
                    }
                }
            }
            .frame(width: 100, height: 100)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: habit.lastCompletedAt)
    }
}

// MARK: - Preview

#Preview("Habit Tiles") {
    let onTrackHabit = Habit(name: "Meditation", emoji: "🧘", cadenceHours: 24)
    let frozenHabit = Habit(name: "Reading", emoji: "📚", cadenceHours: 24, isFrozen: true)
    let gracePeriodHabit = Habit(name: "Exercise", emoji: "🤸", cadenceHours: 24)
    let streakLostHabit = Habit(name: "Piano", emoji: "🎹", cadenceHours: 24)
    
    // On track - completed recently
    onTrackHabit.completions.append(HabitCompletion(completedAt: Date()))
    // Frozen
    frozenHabit.completions.append(HabitCompletion(completedAt: Date().addingTimeInterval(-48 * 3600)))
    // Grace period - completed 25 hours ago (past 24h cadence, within 24h grace)
    gracePeriodHabit.completions.append(HabitCompletion(completedAt: Date().addingTimeInterval(-25 * 3600)))
    // Streak lost - completed 50 hours ago (past both cadence and grace)
    streakLostHabit.completions.append(HabitCompletion(completedAt: Date().addingTimeInterval(-50 * 3600)))
    
    return ZStack {
        Color.backgroundCream
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                HabitTileView(habit: onTrackHabit) { }
                HabitTileView(habit: frozenHabit) { }
            }
            HStack(spacing: 16) {
                HabitTileView(habit: gracePeriodHabit) { }
                HabitTileView(habit: streakLostHabit) { }
            }
        }
    }
}
