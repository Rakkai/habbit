//
//  ProfileView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("userName") private var userName = "Luis"
    @State private var isEditingName = false
    @State private var tempName = ""
    @State private var showAppearanceSettings = false
    @State private var showNotifications = false
    @State private var showHelpFeedback = false
    @State private var showAboutHabits = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader
                        
                        // Learn Section (About habits, Help & Feedback)
                        learnSection
                        
                        // Settings Section (Notifications, Appearance)
                        settingsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationDestination(isPresented: $showAppearanceSettings) {
                AppearanceSettingsView()
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationsComingSoonView()
            }
            .navigationDestination(isPresented: $showHelpFeedback) {
                HelpFeedbackView()
            }
            .navigationDestination(isPresented: $showAboutHabits) {
                AboutHabitsView()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar - Rabbit emoji
            ZStack {
                Circle()
                    .fill(Color.cardWhite)
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                
                Text("🐰")
                    .font(.system(size: 44))
            }
            
            // Name
            if isEditingName {
                HStack {
                    TextField("Your name", text: $tempName)
                        .font(.custom("PTSans-Regular", size: 24))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 200)
                    
                    Button {
                        userName = tempName
                        isEditingName = false
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.successGreen)
                            .font(.system(size: 24))
                    }
                }
            } else {
                Button {
                    tempName = userName
                    isEditingName = true
                } label: {
                    HStack(spacing: 8) {
                        Text(userName)
                            .font(.custom("PTSans-Regular", size: 24))
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                        
                        Text("✏️")
                            .font(.system(size: 14))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.cardWhite)
        )
    }
    
    // MARK: - General Section
    
    private var learnSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General")
                .font(.custom("PTSans-Regular", size: 18))
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 0) {
                SettingsRow(icon: "book.fill", title: "About habits", showChevron: true) {
                    showAboutHabits = true
                }
                
                Divider()
                    .padding(.leading, 52)
                
                SettingsRow(icon: "questionmark.circle.fill", title: "Help & Feedback", showChevron: true) {
                    showHelpFeedback = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardWhite)
            )
        }
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.custom("PTSans-Regular", size: 18))
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 0) {
                SettingsRow(icon: "bell.fill", title: "Notifications", showChevron: true) {
                    showNotifications = true
                }
                
                Divider()
                    .padding(.leading, 52)
                
                SettingsRow(icon: "paintbrush.fill", title: "Appearance", showChevron: true) {
                    showAppearanceSettings = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardWhite)
            )
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let showChevron: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.successGreen)
                    .frame(width: 24)
                
                Text(title)
                    .font(.custom("PTSans-Regular", size: 16))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryText.opacity(0.3))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notifications Coming Soon

struct NotificationsComingSoonView: View {
    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🔔")
                    .font(.system(size: 80))
                
                Text("Coming soon...")
                    .font(.custom("PTSans-Regular", size: 28))
                    .fontWeight(.medium)
                    .foregroundColor(.primaryText)
                
                Text("Push notifications will be available in a future update.")
                    .font(.custom("PTSans-Regular", size: 16))
                    .foregroundColor(.primaryText.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Help & Feedback

struct HelpFeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var showMailError = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("I'd love to hear from you!")
                        .font(.custom("PTSans-Regular", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    Text("Share your feedback, report a bug, suggest a feature or write me a poem.")
                        .font(.custom("PTSans-Regular", size: 16))
                        .foregroundColor(.primaryText.opacity(0.6))
                    
                    // Feedback text field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your message")
                            .font(.custom("PTSans-Regular", size: 14))
                            .foregroundColor(.primaryText.opacity(0.6))
                        
                        TextEditor(text: $feedbackText)
                            .font(.custom("PTSans-Regular", size: 16))
                            .frame(minHeight: 200)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6).opacity(0.8))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.neutralGray.opacity(0.3), lineWidth: 1)
                            )
                            .scrollContentBackground(.hidden)
                    }
                    
                    // Send button
                    Button {
                        sendFeedback()
                    } label: {
                        Text("Send Feedback")
                            .font(.custom("PTSans-Regular", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(feedbackText.isEmpty ? Color.neutralGray : Color.successGreen)
                            )
                    }
                    .disabled(feedbackText.isEmpty)
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(20)
            }
        }
        .navigationTitle("Help & Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Email Not Available", isPresented: $showMailError) {
            Button("Copy Email", role: .none) {
                UIPasteboard.general.string = "luis.amrein@icloud.com"
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Mail is not configured on this device. You can email us at luis.amrein@icloud.com")
        }
        .alert("Thank You! 🎉", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your feedback has been sent. We appreciate you taking the time to help us improve Habbit!")
        }
    }
    
    private func sendFeedback() {
        let email = "luis.amrein@icloud.com"
        let subject = "Habbit Feedback"
        let body = feedbackText
        
        // Try to open Mail app
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                showSuccessAlert = true
            } else {
                showMailError = true
            }
        } else {
            showMailError = true
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
