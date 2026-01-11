//
//  HabbitWidget.swift
//  HabbitWidget
//
//  Created by Luis Amrein
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - App Group
let appGroupID = "group.com.luisamrein.habbit"

func sharedDefaults() -> UserDefaults {
    UserDefaults(suiteName: appGroupID) ?? .standard
}

// MARK: - Complete Habit Intent

@available(iOS 17.0, *)
struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    static var description = IntentDescription("Marks a habit as complete")
    
    @Parameter(title: "Habit ID")
    var habitIDString: String
    
    init() {
        self.habitIDString = ""
    }
    
    init(habitID: UUID) {
        self.habitIDString = habitID.uuidString
    }
    
    func perform() async throws -> some IntentResult {
        let defaults = sharedDefaults()
        
        // Load current habits
        guard let data = defaults.data(forKey: "widgetHabits"),
              var habits = try? JSONDecoder().decode([WidgetHabit].self, from: data) else {
            return .result()
        }
        
        // Find and update the habit
        if let index = habits.firstIndex(where: { $0.id.uuidString == habitIDString }) {
            habits[index].streak += 1
            habits[index].progress = 1.0
            habits[index].state = "onTrack"
            habits[index].lastCompletedAt = Date()
            
            // Save updated habits
            if let encoded = try? JSONEncoder().encode(habits) {
                defaults.set(encoded, forKey: "widgetHabits")
            }
            
            // Mark as pending for main app sync
            var pending = defaults.dictionary(forKey: "pendingCompletions") as? [String: Double] ?? [:]
            pending[habitIDString] = Date().timeIntervalSince1970
            defaults.set(pending, forKey: "pendingCompletions")
            defaults.synchronize()
        }
        
        // Force widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "HabbitWidget")
        
        return .result()
    }
}

// MARK: - Data Model

struct WidgetHabit: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var emoji: String
    var streak: Int
    var progress: Double
    var state: String
    var lastCompletedAt: Date?
    var cadenceSeconds: Double
    var gracePeriodSeconds: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: WidgetHabit, rhs: WidgetHabit) -> Bool {
        lhs.id == rhs.id
    }
    
    var habitState: HabitDisplayState {
        switch state {
        case "gracePeriod": return .gracePeriod
        case "frozen": return .frozen  
        case "streakLost": return .streakLost
        default: return .onTrack
        }
    }
    
    enum HabitDisplayState {
        case onTrack, gracePeriod, frozen, streakLost
        
        var color: Color {
            switch self {
            case .onTrack: return Color(red: 57/255, green: 212/255, blue: 92/255)
            case .gracePeriod: return Color(red: 212/255, green: 66/255, blue: 77/255)
            case .frozen: return Color(red: 173/255, green: 216/255, blue: 230/255)
            case .streakLost: return Color.gray.opacity(0.5)
            }
        }
    }
    
    var streakIcon: String {
        switch habitState {
        case .frozen: return "❄️"
        case .streakLost: return ""
        default: return streak > 0 ? "🔥" : ""
        }
    }
    
    var streakColor: Color {
        switch habitState {
        case .frozen: return Color(red: 100/255, green: 149/255, blue: 237/255)
        case .streakLost: return .gray
        default: return .primary
        }
    }
}

// MARK: - Timeline

struct HabbitEntry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabit]
    
    static var placeholder: HabbitEntry {
        HabbitEntry(date: Date(), habits: WidgetHabit.samples)
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Habbit Configuration"
    static var description = IntentDescription("Configure which habits to show.")
}

struct HabbitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HabbitEntry {
        .placeholder
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> HabbitEntry {
        HabbitEntry(date: Date(), habits: loadHabits())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<HabbitEntry> {
        let entry = HabbitEntry(date: Date(), habits: loadHabits())
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        return timeline
    }
    
    private func loadHabits() -> [WidgetHabit] {
        guard let data = sharedDefaults().data(forKey: "widgetHabits"),
              let habits = try? JSONDecoder().decode([WidgetHabit].self, from: data) else {
            return WidgetHabit.samples
        }
        return habits
    }
}

extension WidgetHabit {
    static var samples: [WidgetHabit] {
        [
            WidgetHabit(id: UUID(), name: "Meditate", emoji: "🧘", streak: 12, progress: 0.8, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Exercise", emoji: "💪", streak: 5, progress: 0.3, state: "gracePeriod", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Read", emoji: "📚", streak: 8, progress: 0.6, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Journal", emoji: "✍️", streak: 3, progress: 1.0, state: "frozen", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Water", emoji: "💧", streak: 15, progress: 0.9, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Walk", emoji: "🚶", streak: 7, progress: 0.5, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Sleep", emoji: "😴", streak: 4, progress: 0.7, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Vitamins", emoji: "💊", streak: 20, progress: 0.4, state: "gracePeriod", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Stretch", emoji: "🤸", streak: 6, progress: 0.85, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Piano", emoji: "🎹", streak: 2, progress: 0.2, state: "gracePeriod", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Code", emoji: "💻", streak: 30, progress: 0.95, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Cook", emoji: "🍳", streak: 11, progress: 0.6, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Clean", emoji: "🧹", streak: 1, progress: 0.1, state: "gracePeriod", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Floss", emoji: "🦷", streak: 9, progress: 0.75, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "Gratitude", emoji: "🙏", streak: 14, progress: 0.55, state: "onTrack", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
            WidgetHabit(id: UUID(), name: "No Phone", emoji: "📵", streak: 0, progress: 0.0, state: "streakLost", lastCompletedAt: nil, cadenceSeconds: 86400, gracePeriodSeconds: 86400),
        ]
    }
}

// MARK: - Widget Views

struct HabbitWidgetView: View {
    let entry: HabbitEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark 
            ? Color(white: 0.1)  // Dark mode background
            : Color(red: 245/255, green: 244/255, blue: 241/255)  // Light mode background
    }
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            case .systemMedium:
                mediumView
            case .systemLarge:
                largeView
            default:
                smallView
            }
        }
        .containerBackground(for: .widget) {
            backgroundColor
        }
    }
    
    // Small: 2×2 grid (4 habits)
    private var smallView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(entry.habits.prefix(4)) { habit in
                HabitButton(habit: habit, size: 52)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }
    
    // Medium: 2×4 grid (8 habits - 2 rows, 4 columns)
    private var mediumView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            ForEach(entry.habits.prefix(8)) { habit in
                HabitButton(habit: habit, size: 56)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
    }
    
    // Large: 4×4 grid (16 habits)
    private var largeView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            ForEach(entry.habits.prefix(16)) { habit in
                HabitButton(habit: habit, size: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
    }
}

// MARK: - Interactive Habit Button

struct HabitButton: View {
    let habit: WidgetHabit
    let size: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    private var trackColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.2) : Color.gray.opacity(0.2)
    }
    
    var body: some View {
        Button(intent: CompleteHabitIntent(habitID: habit.id)) {
            ZStack {
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(trackColor, lineWidth: size * 0.07)
                    
                    Circle()
                        .trim(from: 0, to: habit.progress)
                        .stroke(habit.habitState.color, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(x: -1, y: 1)
                    
                    Circle()
                        .fill(habit.habitState.color.opacity(0.15))
                        .padding(size * 0.035)
                }
                
                // Content
                VStack(spacing: 2) {
                    Text(habit.emoji)
                        .font(.system(size: size * 0.32))
                    
                    HStack(spacing: 1) {
                        Text("\(habit.streak)")
                            .font(.system(size: size * 0.14, weight: .medium))
                            .foregroundStyle(habit.streakColor)
                        
                        if !habit.streakIcon.isEmpty {
                            Text(habit.streakIcon)
                                .font(.system(size: size * 0.11))
                        }
                    }
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Widget

@main
struct HabbitWidget: Widget {
    let kind = "HabbitWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: HabbitProvider()) { entry in
            HabbitWidgetView(entry: entry)
        }
        .configurationDisplayName("Habbit")
        .description("Track and complete your habits.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
