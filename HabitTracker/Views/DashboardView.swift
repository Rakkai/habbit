//
//  DashboardView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.sortOrder)
    private var habits: [Habit]
    
    @State private var selectedMonth: Date = Date()
    @State private var selectedHabitID: UUID? = nil // nil = all habits
    @State private var showFilterSheet = false
    
    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Stats Overview
                    statsOverview
                    
                    // Filter Button
                    filterButton
                    
                    // Monthly Calendar
                    monthlyCalendar
                    
                    // Habit Breakdown
                    habitBreakdown
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showFilterSheet) {
            HabitFilterSheet(
                habits: habits,
                selectedHabitID: $selectedHabitID
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Filter Button
    
    private var filterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            HStack(spacing: 12) {
                // Selected habit emoji or filter icon
                if let habitID = selectedHabitID,
                   let habit = habits.first(where: { $0.id == habitID }) {
                    Text(habit.emoji)
                        .font(.system(size: 24))
                } else {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primaryText)
                }
                
                Text(filterDisplayName)
                    .font(.custom("PTSans-Regular", size: 16))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(.primaryText.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.cardWhite)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var filterDisplayName: String {
        if let habitID = selectedHabitID,
           let habit = habits.first(where: { $0.id == habitID }) {
            return habit.name
        }
        return "All Habits"
    }
    
    // MARK: - Stats Overview
    
    private var statsOverview: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Completions",
                value: "\(totalCompletions)",
                icon: "✅"
            )
            
            StatCard(
                title: "Best Streak",
                value: "\(bestStreak)",
                icon: "🔥"
            )
        }
    }
    
    // MARK: - Monthly Calendar
    
    private var monthlyCalendar: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                // Previous Year
                Button {
                    changeMonth(by: -12)
                } label: {
                    Image(systemName: "chevron.left.2")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryText.opacity(0.5))
                }
                
                // Previous Month
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryText)
                }
                
                Spacer()
                
                // Month & Year
                Text(monthYearString)
                    .font(.custom("PTSans-Regular", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                // Next Month
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryText)
                }
                
                // Next Year
                Button {
                    changeMonth(by: 12)
                } label: {
                    Image(systemName: "chevron.right.2")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryText.opacity(0.5))
                }
            }
            .padding(.horizontal, 8)
            
            // Day Labels
            HStack(spacing: 0) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(.custom("PTSans-Regular", size: 12))
                        .foregroundColor(.primaryText.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isCompleted: isDateCompleted(date),
                            isCurrentMonth: isCurrentMonth(date),
                            isToday: Calendar.current.isDateInToday(date)
                        )
                    } else {
                        // Empty cell for padding
                        Color.clear
                            .frame(height: 36)
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
    
    // MARK: - Habit Breakdown
    
    private var habitBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Breakdown")
                .font(.custom("PTSans-Regular", size: 20))
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            ForEach(habits, id: \.id) { habit in
                HabitRowView(habit: habit)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.cardWhite)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
    }
    
    // MARK: - Computed Properties
    
    private var totalCompletions: Int {
        filteredHabits.reduce(0) { $0 + $1.totalCompletions }
    }
    
    private var bestStreak: Int {
        filteredHabits.map { $0.currentStreak }.max() ?? 0
    }
    
    private var filteredHabits: [Habit] {
        if let habitID = selectedHabitID {
            return habits.filter { $0.id == habitID }
        }
        return Array(habits)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        
        // Get the first day of the month
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let firstOfMonth = calendar.date(from: components) else { return [] }
        
        // Get the weekday of the first day (1 = Sunday, 2 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        // Adjust for Monday start (1 = Monday, 7 = Sunday)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 + 1
        
        // Get the number of days in the month
        guard let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return [] }
        let daysInMonth = range.count
        
        // Build the array with nil padding for days before the first
        var days: [Date?] = Array(repeating: nil, count: adjustedFirstWeekday - 1)
        
        // Add actual days
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // MARK: - Helper Methods
    
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMonth = newDate
            }
        }
    }
    
    private func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        
        // Check if any filtered habit was completed on this date
        return filteredHabits.contains { habit in
            habit.completions.contains { completion in
                calendar.isDate(completion.completedAt, inSameDayAs: date)
            }
        }
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let date: Date
    let isCompleted: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(backgroundColor)
                .frame(width: 36, height: 36)
            
            // Day number
            Text(dayNumber)
                .font(.custom("PTSans-Regular", size: 14))
                .foregroundColor(textColor)
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return .successGreen
        } else if isToday {
            return .neutralGray.opacity(0.3)
        } else {
            return .neutralGray.opacity(0.15)
        }
    }
    
    private var textColor: Color {
        if isCompleted {
            return .white
        } else if !isCurrentMonth {
            return .primaryText.opacity(0.3)
        } else {
            return .primaryText
        }
    }
}

// MARK: - Habit Filter Sheet

struct HabitFilterSheet: View {
    let habits: [Habit]
    @Binding var selectedHabitID: UUID?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // All Habits option
                        FilterOptionRow(
                            emoji: "📊",
                            name: "All Habits",
                            isSelected: selectedHabitID == nil
                        ) {
                            selectedHabitID = nil
                            dismiss()
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        // Individual habits
                        ForEach(habits, id: \.id) { habit in
                            FilterOptionRow(
                                emoji: habit.emoji,
                                name: habit.name,
                                isSelected: selectedHabitID == habit.id
                            ) {
                                selectedHabitID = habit.id
                                dismiss()
                            }
                            
                            if habit.id != habits.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardWhite)
                    )
                    .padding(20)
                }
            }
            .navigationTitle("Filter by Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
            }
        }
    }
}

struct FilterOptionRow: View {
    let emoji: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 24))
                
                Text(name)
                    .font(.custom("PTSans-Regular", size: 16))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.successGreen)
                        .font(.system(size: 22))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            
            Text(value)
                .font(.custom("PTSans-Regular", size: 28))
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text(title)
                .font(.custom("PTSans-Regular", size: 14))
                .foregroundColor(.primaryText.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.cardWhite)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
    }
}

struct HabitRowView: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 16) {
            Text(habit.emoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.custom("PTSans-Regular", size: 16))
                    .foregroundColor(.primaryText)
                
                Text("\(habit.totalCompletions) completions • \(habit.currentStreak) day streak")
                    .font(.custom("PTSans-Regular", size: 12))
                    .foregroundColor(.primaryText.opacity(0.6))
            }
            
            Spacer()
            
            if habit.isOnTrack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.successGreen)
                    .font(.system(size: 24))
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DashboardView()
            .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
    }
}
