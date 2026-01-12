//
//  ContentView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

// MARK: - Tab Navigation

enum Tab: String, CaseIterable {
    case habits
    case dashboard
    case profile
}

// MARK: - Content View

struct ContentView: View {
    @State private var selectedTab: Tab = .habits
    @AppStorage("appearanceMode") private var appearanceMode: String = AppearanceMode.system.rawValue

    private var colorScheme: ColorScheme? {
        AppearanceMode(rawValue: appearanceMode)?.colorScheme
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Habits", systemImage: "circle.circle.fill")
                }
                .tag(Tab.habits)
            
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            .tag(Tab.dashboard)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .tint(.successGreen)
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
