//
//  Habit.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var emoji: String
    var createdAt: Date
    var isArchived: Bool
    var sortOrder: Int
    
    /// Cadence in hours (e.g., 72 for 3 days)
    var cadenceHours: Int
    
    /// Whether this habit is currently frozen (streak protected)
    var isFrozen: Bool
    
    /// When the habit was frozen
    var frozenAt: Date?
    
    /// Last milestone that awarded a streak freeze (to avoid double-awarding)
    var lastAwardedMilestone: Int
    
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion]
    
    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        createdAt: Date = Date(),
        isArchived: Bool = false,
        sortOrder: Int = 0,
        cadenceHours: Int = 24,
        isFrozen: Bool = false,
        frozenAt: Date? = nil,
        lastAwardedMilestone: Int = 0,
        completions: [HabitCompletion] = []
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.createdAt = createdAt
        self.isArchived = isArchived
        self.sortOrder = sortOrder
        self.cadenceHours = cadenceHours
        self.isFrozen = isFrozen
        self.frozenAt = frozenAt
        self.lastAwardedMilestone = lastAwardedMilestone
        self.completions = completions
    }
    
    // MARK: - Computed Properties
    
    /// The most recent completion date
    var lastCompletedAt: Date? {
        completions.map(\.completedAt).max()
    }
    
    /// Progress from 1.0 (just completed) to 0.0 (cadence expired)
    /// For the green phase (main cadence period)
    var progressRemaining: Double {
        // If frozen, show full progress (frozen in place)
        if isFrozen { return 1.0 }
        
        guard let lastCompleted = lastCompletedAt else { return 0.0 }
        
        let now = Date()
        let elapsed = now.timeIntervalSince(lastCompleted)
        
        let remaining = 1.0 - (elapsed / cadenceSeconds)
        return max(0, min(1, remaining))
    }
    
    /// Progress of the grace period (red phase)
    /// Returns 1.0 when grace period just started, 0.0 when expired
    var gracePeriodProgress: Double {
        guard let lastCompleted = lastCompletedAt else { return 0.0 }
        
        let now = Date()
        let elapsed = now.timeIntervalSince(lastCompleted)
        let elapsedAfterCadence = elapsed - cadenceSeconds
        
        if elapsedAfterCadence <= 0 { return 1.0 } // Still in green phase
        
        let remaining = 1.0 - (elapsedAfterCadence / gracePeriodSeconds)
        return max(0, min(1, remaining))
    }
    
    /// Habit state enum for UI rendering
    enum HabitState {
        case onTrack      // Green - within cadence period
        case gracePeriod  // Red - cadence expired but within 24h grace
        case frozen       // Icy blue - streak freeze active
        case streakLost   // Grey - grace period expired, streak gone
    }
    
    /// Current state of the habit
    var state: HabitState {
        if isFrozen { return .frozen }
        
        guard let lastCompleted = lastCompletedAt else { return .streakLost }
        
        let now = Date()
        let elapsed = now.timeIntervalSince(lastCompleted)
        
        if elapsed <= cadenceSeconds {
            return .onTrack
        } else if elapsed <= cadenceSeconds + gracePeriodSeconds {
            return .gracePeriod
        } else {
            return .streakLost
        }
    }
    
    /// Whether the habit is currently in a good state (on track or frozen)
    var isOnTrack: Bool {
        state == .onTrack || state == .frozen
    }
    
    /// Whether the habit is in the grace period (red, needs attention)
    var isInGracePeriod: Bool {
        state == .gracePeriod
    }
    
    /// Whether the streak has been lost (grey)
    var isStreakLost: Bool {
        state == .streakLost
    }
    
    /// Whether the grace period just expired and habit should be auto-frozen (if freezes available)
    /// Returns true when grace period is completely over, habit isn't already frozen,
    /// AND the habit had completions (we don't freeze habits that were never started)
    var needsAutoFreeze: Bool {
        guard !isFrozen else { return false }
        guard !completions.isEmpty else { return false } // Never started = no freeze needed
        return state == .streakLost
    }
    
    /// Seconds remaining until cadence expires
    var secondsRemaining: Double {
        if isFrozen { return cadenceSeconds } // Full time when frozen
        
        guard let lastCompleted = lastCompletedAt else { return 0 }
        
        let now = Date()
        let elapsed = now.timeIntervalSince(lastCompleted)
        
        return max(0, cadenceSeconds - elapsed)
    }
    
    /// Hours remaining until cadence expires
    var hoursRemaining: Double {
        return secondsRemaining / 3600
    }
    
    /// Formatted time remaining (e.g., "2d 5h" or "3h")
    var timeRemainingFormatted: String {
        switch state {
        case .frozen:
            return "Frozen ❄️"
        case .streakLost:
            return "Streak lost"
        case .gracePeriod:
            // Show grace period time remaining
            let graceSecondsLeft = gracePeriodProgress * gracePeriodSeconds
            let hoursLeft = graceSecondsLeft / 3600
            if hoursLeft >= 1 {
                return "\(Int(hoursLeft))h left!"
            } else {
                let minutesLeft = Int(graceSecondsLeft / 60)
                return "\(minutesLeft)m left!"
            }
        case .onTrack:
            let hours = hoursRemaining
            if hours >= 24 {
                let days = Int(hours / 24)
                let remainingHours = Int(hours.truncatingRemainder(dividingBy: 24))
                if remainingHours > 0 {
                    return "\(days)d \(remainingHours)h"
                }
                return "\(days)d"
            } else if hours >= 1 {
                return "\(Int(hours))h"
            } else {
                let minutes = Int(hours * 60)
                return "\(minutes)m"
            }
        }
    }
    
    /// Current streak = total completions (resets to 0 when streak is lost)
    var currentStreak: Int {
        // If streak is lost, return 0
        if state == .streakLost { return 0 }
        return completions.count
    }
    
    var totalCompletions: Int {
        completions.count
    }
    
    /// Check if a new streak freeze should be awarded (at milestones 5, 10, 15, etc.)
    /// Returns true only when crossing a new milestone
    func checkForNewStreakFreeze() -> Bool {
        let streak = completions.count // Use raw count, not currentStreak (which can be 0)
        
        // Award at milestones: 5, 10, 15, 20, etc.
        let currentMilestone = (streak / 5) * 5
        
        // Only award if we're exactly at a milestone and it's a new one
        if streak > 0 && streak % 5 == 0 && currentMilestone > lastAwardedMilestone {
            lastAwardedMilestone = currentMilestone
            return true
        }
        return false
    }
    
    /// Mark the habit as completed now (also unfreezes if frozen)
    func markCompleted() {
        // Unfreeze if frozen
        if isFrozen {
            isFrozen = false
            frozenAt = nil
        }
        
        // If streak was lost, reset completions and milestone tracker
        if state == .streakLost {
            completions.removeAll()
            lastAwardedMilestone = 0
        }
        
        let completion = HabitCompletion(completedAt: Date())
        completions.append(completion)
    }
    
    /// Freeze this habit to protect the streak
    func freeze() {
        isFrozen = true
        frozenAt = Date()
    }
}

// MARK: - Cadence Presets

extension Habit {
    enum CadencePreset: CaseIterable {
        case daily
        case everyOtherDay
        case twiceWeekly
        case weekly
        
        var hours: Int {
            switch self {
            case .daily: return 24
            case .everyOtherDay: return 48
            case .twiceWeekly: return 84  // ~3.5 days
            case .weekly: return 168
            }
        }
        
        var displayName: String {
            switch self {
            case .daily: return "Daily"
            case .everyOtherDay: return "Every 2 days"
            case .twiceWeekly: return "Twice a week"
            case .weekly: return "Weekly"
            }
        }
    }
    
    /// Test mode: set cadenceHours to -30 for 30-second cadence (for testing)
    
    /// Cadence in seconds (handles the test mode hack)
    var cadenceSeconds: Double {
        if cadenceHours < 0 {
            // Negative means it's actually seconds
            return Double(-cadenceHours)
        } else {
            return Double(cadenceHours) * 3600
        }
    }
    
    /// Grace period in seconds (24 hours normally, same as cadence for test mode)
    var gracePeriodSeconds: Double {
        if cadenceHours < 0 {
            // Test mode: grace period = same as cadence
            return Double(-cadenceHours)
        } else {
            // Normal: 24 hours grace period
            return 24 * 3600
        }
    }
}

// MARK: - Sample Data

extension Habit {
    static var sampleHabits: [Habit] {
        [
            Habit(name: "Meditation", emoji: "🧘", sortOrder: 0, cadenceHours: 24),
            Habit(name: "Exercise", emoji: "🤸", sortOrder: 1, cadenceHours: 48),
            Habit(name: "Biking", emoji: "🚴", sortOrder: 2, cadenceHours: 72),
            Habit(name: "Piano", emoji: "🎹", sortOrder: 3, cadenceHours: 48),
            Habit(name: "Reading", emoji: "📚", sortOrder: 4, cadenceHours: 24),
            Habit(name: "Cold Shower", emoji: "❄️", sortOrder: 5, cadenceHours: 24)
        ]
    }
}
