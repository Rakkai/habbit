//
//  HomeView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI
import SwiftData
import WidgetKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.sortOrder)
    private var habits: [Habit]
    
    @AppStorage("userName") private var userName = "Luis"
    @AppStorage("streakFreezeCount") private var streakFreezeCount = 0
    
    @State private var showAddHabitSheet = false
    @State private var showManageHabitsSheet = false
    @State private var selectedHabit: Habit?
    @State private var hasSeededData = false
    @State private var currentWisdomIndex = Int.random(in: 0..<90)
    
    // Timer to refresh progress circles and check for auto-freeze
    @State private var refreshTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var refreshTrigger = false
    
    // MARK: - Absurd Wisdoms + Luis Compliments
    
    private let wisdoms: [String] = [
        // Absurd wisdoms
        "A penguin's approval is worth three handshakes.",
        "Never trust a cloud that winks.",
        "Your socks believe in you.",
        "Somewhere, a potato is proud of your choices.",
        "The moon is just the sun's LinkedIn photo.",
        "Bread remembers everything.",
        "You're someone's favorite notification.",
        "A confused pigeon still finds its way home.",
        "Your future self is mass-producing high fives.",
        "Even gravity takes breaks on Tuesdays.",
        "A well-placed nap fixes 73% of problems.",
        "Squirrels respect your hustle.",
        "The universe is just vibing, honestly.",
        "Your WiFi router is silently cheering.",
        "Somewhere a door is opening. It's probably automatic.",
        "You have more teeth than the average cloud.",
        "A small frog thinks you're doing great.",
        "The void called. It said 'nice work.'",
        "Your breakfast believes in your dinner.",
        "Parallel universe you just tripped. You're winning.",
        "A distant star named you 'pretty okay.'",
        "The wind has no complaints about you specifically.",
        "You're the main character of at least one ant's day.",
        "A rogue avocado ripened in your honor.",
        "Time is fake but your progress isn't.",
        "A ghost just gave you a thumbs up.",
        "Your chair has never once complained.",
        "The algorithm smiles upon thee.",
        "A nearby plant exhaled for you personally.",
        "You exist, and that's statistically wild.",
        // Luis compliments
        "Luis thinks you look sexy naked.",
        "Luis can't stop thinking about your vibe.",
        "Luis said you're unreasonably attractive.",
        "Luis thinks your energy is intoxicating.",
        "Luis would swipe right. Twice.",
        "Luis finds your existence dangerously hot.",
        "Luis says you're the whole package.",
        "Luis thinks you're way out of everyone's league.",
        "Luis called. He said you're stunning.",
        "Luis can't handle how cool you are.",
        "Luis thinks your smile is illegal.",
        "Luis believes you invented attractiveness.",
        "Luis says mirrors are jealous of you.",
        "Luis thinks you're criminally good looking.",
        "Luis wants to know your secret. It's being you.",
        "Luis says you radiate big hot person energy.",
        "Luis thinks the sun is copying your glow.",
        "Luis called you a masterpiece. He's right.",
        "Luis says you're the reason hearts skip.",
        "Luis thinks you're unfairly gorgeous.",
        "Luis says even your shadow looks good.",
        "Luis is convinced you're photoshopped IRL.",
        "Luis thinks you walk like a runway exists beneath you.",
        "Luis says your confidence is extremely attractive.",
        "Luis thinks you could charm a brick wall.",
        "Luis says you make existing look effortless.",
        "Luis is 100% sure you're a snack. No, a meal.",
        "Luis thinks your aura just winked at him.",
        "Luis says even your bad days look hot.",
        "Luis thinks you deserve a standing ovation for being you.",
        // Creepy Luis
        "Luis has been watching. He's impressed.",
        "Luis knows what you did. He liked it.",
        "Luis is closer than you think. And smiling.",
        "Luis saw you sleeping. You looked peaceful.",
        "Luis saved that photo. The one you deleted.",
        "Luis knows your WiFi password. Always has.",
        "Luis left something under your pillow. Check later.",
        "Luis can hear you breathing. It's nice.",
        "Luis has been in your room. Recently.",
        "Luis remembers your dreams. All of them.",
        "Luis is behind you right now. Don't turn around.",
        "Luis took your other sock. He needed it.",
        "Luis watches you through the front camera. Often.",
        "Luis knows you skipped that habit. He forgives you.",
        "Luis is in your walls. It's cozy in here.",
        "Luis borrowed your toothbrush once. Just once.",
        "Luis followed you home. You walk beautifully.",
        "Luis reads your notes app. Very interesting.",
        "Luis smells your shampoo sometimes. From memory.",
        "Luis has a shrine. You're the centerpiece.",
        "Luis was that shadow you saw last night.",
        "Luis counts your heartbeats. They're perfect.",
        "Luis knows your exact location. Always.",
        "Luis has a lock of your hair. Gift from destiny.",
        "Luis whispers your name at 3am. You don't hear it.",
        "Luis lives in your attic now. It's temporary.",
        "Luis tasted your leftovers. Delicious, by the way.",
        "Luis knows when you're about to open this app.",
        "Luis is proud of you. He's always watching."
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Habit Grid
                        if !habits.isEmpty {
                            HabitGridView(
                                habits: habits,
                                onHabitTap: { habit in
                                    markHabitCompleted(habit)
                                },
                                onHabitLongPress: { habit in
                                    selectedHabit = habit
                                    showAddHabitSheet = true
                                }
                            )
                            .id(refreshTrigger) // Force refresh
                            
                            // Add Habit Button
                            PillButton(title: "Add new habit", icon: "➕") {
                                selectedHabit = nil
                                showAddHabitSheet = true
                            }
                            
                            // Edit Habits Button
                            PillButton(title: "Edit habits", icon: "✏️") {
                                showManageHabitsSheet = true
                            }
                        } else {
                            emptyStateView
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                }
            }
            .sheet(isPresented: $showAddHabitSheet) {
                AddEditHabitView(habit: selectedHabit)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showManageHabitsSheet) {
                ManageHabitsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                seedDataIfNeeded()
                syncWidgetCompletions() // Sync any completions made from widget
                checkAndAutoFreezeHabits()
                syncHabitsToWidget()
            }
            .onReceive(refreshTimer) { _ in
                // Refresh circles and check for auto-freeze
                checkAndAutoFreezeHabits()
                refreshTrigger.toggle()
                syncHabitsToWidget()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    // App became active - sync widget completions
                    syncWidgetCompletions()
                    refreshTrigger.toggle()
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hey \(userName) 👋")
                    .font(.custom("PTSans-Regular", size: 22))
                    .foregroundColor(.primaryText)
                
                Text(wisdoms[currentWisdomIndex])
                    .font(.custom("PTSans-Regular", size: 22))
                    .foregroundColor(.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            StreakBadge(count: streakFreezeCount, emoji: "❄️")
        }
    }
    
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("🎯")
                    .font(.system(size: 64))
                
                Text("No habits yet")
                    .font(.custom("PTSans-Regular", size: 20))
                    .foregroundColor(.primaryText)
                
                Text("Create your first habit to get started")
                    .font(.custom("PTSans-Regular", size: 16))
                    .foregroundColor(.primaryText.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 45)
                    .fill(Color.cardWhite)
                    .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
            )
            
            // Add Habit Button
            PillButton(title: "Add new habit", icon: "➕") {
                selectedHabit = nil
                showAddHabitSheet = true
            }
        }
    }
    
    // MARK: - Actions
    
    private func markHabitCompleted(_ habit: Habit) {
        habit.markCompleted()
        
        // Check if this completion earns a streak freeze
        if habit.checkForNewStreakFreeze() {
            streakFreezeCount += 1
        }
        
        try? modelContext.save()
        refreshTrigger.toggle()
        
        // Sync to widget
        syncHabitsToWidget()
        
        // Change wisdom on each completion
        var newIndex = Int.random(in: 0..<wisdoms.count)
        while newIndex == currentWisdomIndex && wisdoms.count > 1 {
            newIndex = Int.random(in: 0..<wisdoms.count)
        }
        currentWisdomIndex = newIndex
    }
    
    /// Check all habits and auto-freeze any that have fully expired (if we have freezes available)
    /// This triggers when the grace period is completely over
    private func checkAndAutoFreezeHabits() {
        var didFreeze = false
        
        for habit in habits {
            // Skip archived habits
            guard !habit.isArchived else { continue }
            
            // Check if this habit needs a freeze (grace period expired)
            if habit.needsAutoFreeze && streakFreezeCount > 0 {
                habit.freeze()
                streakFreezeCount -= 1
                didFreeze = true
            }
        }
        
        if didFreeze {
            try? modelContext.save()
            refreshTrigger.toggle()
        }
    }
    
    private func seedDataIfNeeded() {
        guard !hasSeededData && habits.isEmpty else { return }
        hasSeededData = true
        
        // Give user some initial streak freezes for demo
        if streakFreezeCount == 0 {
            streakFreezeCount = 2
        }
        
        let sampleHabits = Habit.sampleHabits

        for habit in sampleHabits {
            modelContext.insert(habit)

            // Add a few recent completions to show the habit has been used
            let completion1 = HabitCompletion(completedAt: Date().addingTimeInterval(-2 * 3600)) // 2 hours ago
            let completion2 = HabitCompletion(completedAt: Date().addingTimeInterval(-24 * 3600)) // 1 day ago
            let completion3 = HabitCompletion(completedAt: Date().addingTimeInterval(-48 * 3600)) // 2 days ago

            habit.completions.append(completion1)
            habit.completions.append(completion2)
            habit.completions.append(completion3)
        }
        
        try? modelContext.save()
    }
    
    /// Sync habits to widget via App Groups
    private func syncHabitsToWidget() {
        let widgetHabits = habits.map { habit in
            WidgetHabit(
                id: habit.id,
                name: habit.name,
                emoji: habit.emoji,
                streak: habit.currentStreak,
                progress: habit.state == .gracePeriod ? habit.gracePeriodProgress : habit.progressRemaining,
                state: stateString(for: habit.state),
                lastCompletedAt: habit.lastCompletedAt,
                cadenceSeconds: habit.cadenceSeconds,
                gracePeriodSeconds: habit.gracePeriodSeconds
            )
        }
        
        if let data = try? JSONEncoder().encode(widgetHabits) {
            let defaults = UserDefaults(suiteName: "group.com.luisamrein.habbit")
            defaults?.set(data, forKey: "widgetHabits")
        }
        
        // Reload widget
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Sync completions made from widget back to SwiftData
    private func syncWidgetCompletions() {
        let defaults = UserDefaults(suiteName: "group.com.luisamrein.habbit")
        guard let pending = defaults?.dictionary(forKey: "pendingCompletions") as? [String: Double],
              !pending.isEmpty else { return }
        
        var didSync = false
        
        for (habitIdString, timestamp) in pending {
            let completionDate = Date(timeIntervalSince1970: timestamp)
            guard let habitId = UUID(uuidString: habitIdString),
                  let habit = habits.first(where: { $0.id == habitId }) else { continue }
            
            // Check if this completion is already recorded
            let alreadyRecorded = habit.completions.contains { completion in
                abs(completion.completedAt.timeIntervalSince(completionDate)) < 1
            }
            
            if !alreadyRecorded {
                let completion = HabitCompletion(completedAt: completionDate)
                habit.completions.append(completion)
                
                // Check for streak freeze
                if habit.checkForNewStreakFreeze() {
                    streakFreezeCount += 1
                }
                didSync = true
            }
        }
        
        if didSync {
            try? modelContext.save()
            refreshTrigger.toggle()
        }
        
        // Clear pending
        defaults?.removeObject(forKey: "pendingCompletions")
    }
    
    private func stateString(for state: Habit.HabitState) -> String {
        switch state {
        case .onTrack: return "onTrack"
        case .gracePeriod: return "gracePeriod"
        case .frozen: return "frozen"
        case .streakLost: return "streakLost"
        }
    }
}

// MARK: - Widget Data Model

/// Codable model used for syncing habit data to the widget via App Groups
struct WidgetHabit: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var streak: Int
    var progress: Double
    var state: String
    var lastCompletedAt: Date?
    var cadenceSeconds: Double
    var gracePeriodSeconds: Double
}

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
