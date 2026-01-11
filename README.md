# Habbit 🐰

A beautiful, personal habit tracking app for iOS built with SwiftUI and SwiftData.

## Features

- **Circular Progress Tracking** - Visual countdown showing time until your next habit is due
- **Flexible Cadence** - Set habits for daily, every 2 days, weekly, or custom intervals
- **Streak Freezes** - Earn freezes at milestones (5, 10, 15...) to protect your streaks
- **Grace Period** - 24-hour buffer when you miss a habit before losing your streak
- **Interactive Widget** - Complete habits directly from your home screen
- **Dark Mode** - Full support for light and dark appearance
- **Monthly Calendar** - View your completion history with habit filtering
- **Habit Manual** - Built-in guide on habit psychology and best practices

## Screenshots

The app features a warm, friendly design with:
- Cream background in light mode, dark grey in dark mode
- Circular progress indicators (green → red → grey)
- Emoji-based habit icons
- Native iOS tab bar navigation

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Open `HabitTracker.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

### Widget Setup

The widget requires App Groups to share data between the app and widget:
- App Group ID: `group.com.luisamrein.habbit`
- Ensure both the main app and widget extension have this capability enabled

## Project Structure

```
HabitTracker/
├── App/
│   ├── HabitTrackerApp.swift    # App entry point
│   └── ContentView.swift        # Tab navigation
├── Models/
│   ├── Habit.swift              # Habit data model with state logic
│   └── HabitCompletion.swift    # Completion records
├── Views/
│   ├── HomeView.swift           # Main habits screen
│   ├── DashboardView.swift      # Analytics & calendar
│   ├── ProfileView.swift        # Settings & profile
│   ├── AddEditHabitView.swift   # Create/edit habits
│   ├── ManageHabitsView.swift   # Reorder & delete habits
│   ├── AboutHabitsView.swift    # Habit psychology guide
│   └── AppearanceSettingsView.swift
├── Components/
│   ├── CircularProgressView.swift
│   ├── HabitTileView.swift
│   ├── HabitGridView.swift
│   ├── PillButton.swift
│   └── StreakBadge.swift
├── Extensions/
│   └── Color+Extensions.swift
└── Resources/
    └── Assets.xcassets/

HabbitWidget/
├── HabbitWidget.swift           # Widget with interactive buttons
├── Assets.xcassets/
└── Info.plist
```

## Key Concepts

### Habit States
- **On Track** (green): Within cadence period
- **Grace Period** (red): Cadence expired, 24h to complete before streak loss
- **Frozen** (icy blue): Streak protected by a freeze
- **Streak Lost** (grey): Grace period expired, streak reset to 0

### Streak Freezes
- Earned at milestones: 5, 10, 15, 20... completions
- Automatically applied when grace period expires (if available)
- Click a frozen habit to unfreeze and continue the streak

## Design

- Warm cream background (`#F5F4F1`) / Dark mode (`#1A1A1A`)
- White/dark cards with rounded corners
- PT Sans typography
- Green success color (`#39D45C`)
- Red danger color (`#D4424D`)
- Icy blue for frozen state (`#ADD8E6`)

## License

Personal use only.
