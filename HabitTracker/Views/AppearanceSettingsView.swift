//
//  AppearanceSettingsView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct AppearanceSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearanceMode") private var appearanceMode: String = AppearanceMode.system.rawValue
    
    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Options
                VStack(spacing: 0) {
                    ForEach(AppearanceMode.allCases, id: \.rawValue) { mode in
                        AppearanceOptionRow(
                            mode: mode,
                            isSelected: appearanceMode == mode.rawValue
                        ) {
                            appearanceMode = mode.rawValue
                        }
                        
                        if mode != AppearanceMode.allCases.last {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardWhite)
                )
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppearanceOptionRow: View {
    let mode: AppearanceMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: mode.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.successGreen)
                    .frame(width: 28)
                
                Text(mode.displayName)
                    .font(.custom("PTSans-Regular", size: 16))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.successGreen)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
