# Habbit 🐰

A personal habit tracking app for iOS built with SwiftUI and SwiftData.

## Features

- **Circular Progress Tracking** - Visual countdown showing time until your next habit is due
- **Flexible Cadence** - Set habits for daily, every 2 days, weekly, or custom intervals
- **Streak Freezes** - Earn freezes at milestones (5, 10, 15...) to protect your streaks
- **Grace Period** - 24-hour buffer when you miss a habit before losing your streak
- **Progress Tracking** - View your completion history with habit filtering
- **Habit Manual** - Built-in guide on habit psychology and best practices
- **Interactive Widget** - Complete habits directly from your home screen
- **Dark Mode** - Full support for light and dark appearance

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

## Installation & Getting Started

### Prerequisites

- **macOS** with Xcode 15.0+ installed
- **iPhone** running iOS 17.0+ (iPhone 8 or newer recommended)
- **Apple ID** for code signing

### Step 1: Download the Project

```bash
git clone https://github.com/luis-amrein/Habbit.git
cd Habbit
```

### Step 2: Open in Xcode

1. Double-click `HabitTracker.xcodeproj` to open in Xcode
2. Wait for Xcode to finish indexing and loading dependencies

### Step 3: Prepare Your iPhone for Development

#### Enable Developer Mode on iPhone

1. Connect your iPhone to your Mac using a USB cable
2. On your iPhone, go to **Settings → Privacy & Security**
3. Scroll down to **Developer Mode** and tap it
4. Toggle **Developer Mode** ON
5. Restart your iPhone when prompted
6. After restart, confirm **Developer Mode** is enabled

#### Trust Your Computer

1. On your iPhone, you'll see a "Trust This Computer?" popup
2. Tap **Trust** and enter your passcode if prompted
3. Your iPhone should now appear in Xcode's device list

### Step 4: Change Bundle Identifier

**Important:** Each developer needs a unique bundle identifier. The default `com.luisamrein.HabitTracker` may already be taken.

1. In Xcode, select the **HabitTracker** project in the navigator
2. Select the **HabitTracker** target (not the widget)
3. Go to the **General** tab
4. Under **Identity**, change the **Bundle Identifier** to something unique (e.g., `com.yourname.HabitTracker` or `com.yourname.Habbit`)
5. Select the **HabbitWidgetExtension** target
6. Change its **Bundle Identifier** to match (e.g., `com.yourname.HabitTracker.HabbitWidget`)

### Step 5: Configure Code Signing

1. With the **HabitTracker** target selected, go to the **Signing & Capabilities** tab
2. Check **Automatically manage signing**
3. Select your Apple ID from the **Team** dropdown (or "Add an Account..." if needed)
4. Repeat for the **HabbitWidgetExtension** target
5. Xcode will automatically create provisioning profiles for your bundle identifiers

### Step 6: Build and Run

1. Select your iPhone from the device dropdown (next to the play button)
2. Press `Cmd + R` or click the play button to build and run
3. The app will install on your iPhone automatically

### Widget Setup

The interactive widget requires App Groups to share data:

1. In Xcode, select the **HabitTracker** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** and add **App Groups**
4. Use group ID: `group.com.yourname.habbit` (replace `yourname` with your bundle identifier prefix, e.g., if your bundle ID is `com.john.HabitTracker`, use `group.com.john.habbit`)
5. Repeat for the **HabbitWidgetExtension** target with the **same group ID** (must match exactly)
6. **Important:** If you manually edited the entitlements files, ensure both `HabitTracker.entitlements` and `HabbitWidgetExtension.entitlements` have the same App Group ID
7. Add the widget to your home screen: Long press on home screen → + → search for "Habbit"

### Troubleshooting

#### "iPhone is not available" Error
- Ensure Developer Mode is enabled on iPhone
- Try unplugging and replugging the USB cable
- Restart both Mac and iPhone

#### Build Fails with Signing Issues
- **Change the bundle identifier** - The default `com.luisamrein.HabitTracker` may already be registered. Use a unique identifier like `com.yourname.HabitTracker`
- Ensure you're signed into Xcode with your Apple ID (Xcode → Settings → Accounts)
- Ensure **Automatically manage signing** is checked in Signing & Capabilities
- Try cleaning the project: `Cmd + Shift + K`
- Delete Derived Data: `Cmd + Shift + Option + K`

#### "Bundle Identifier Cannot Be Registered" Error
- This means the bundle identifier is already taken. Change it to something unique:
  1. Select the **HabitTracker** target → **General** tab
  2. Change **Bundle Identifier** to `com.yourname.HabitTracker` (use your own name/domain)
  3. Select **HabbitWidgetExtension** target → Change to `com.yourname.HabitTracker.HabbitWidget`

#### Widget Not Appearing
- Ensure App Groups capability is added to both targets
- Build and run the main app first, then add the widget
- Restart your iPhone if needed

#### No Space Left on Device
If Xcode shows disk space errors:
```bash
# Clean Xcode cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

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
