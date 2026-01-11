//
//  HabitCompletion.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import Foundation
import SwiftData

@Model
final class HabitCompletion {
    var id: UUID
    var completedAt: Date
    var notes: String?
    
    var habit: Habit?
    
    init(
        id: UUID = UUID(),
        completedAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.completedAt = completedAt
        self.notes = notes
    }
}
