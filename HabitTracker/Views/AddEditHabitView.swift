//
//  AddEditHabitView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI
import SwiftData

struct AddEditHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit?
    
    @State private var name: String
    @State private var selectedEmoji: String
    @State private var selectedCadence: Habit.CadencePreset
    @State private var customCadenceHours: Int
    @State private var useCustomCadence: Bool
    @State private var showDeleteConfirmation = false
    @State private var showAllEmojis = false
    @State private var testMode = false // 30-second cadence for testing
    
    private let suggestedEmojis = [
        "🧘", "💪", "🏃", "🚴", "📚", "💧", "🥗", "😴",
        "✍️", "🎨", "🎹", "🧠", "🌱", "❄️", "🎯", "⭐"
    ]
    
    init(habit: Habit?) {
        self.habit = habit
        
        if let habit {
            _name = State(initialValue: habit.name)
            _selectedEmoji = State(initialValue: habit.emoji)
            
            // Check for test mode (negative hours)
            if habit.cadenceHours < 0 {
                _testMode = State(initialValue: true)
                _selectedCadence = State(initialValue: .daily)
                _useCustomCadence = State(initialValue: false)
                _customCadenceHours = State(initialValue: 24)
            } else if let preset = Habit.CadencePreset.allCases.first(where: { $0.hours == habit.cadenceHours }) {
                _selectedCadence = State(initialValue: preset)
                _useCustomCadence = State(initialValue: false)
                _customCadenceHours = State(initialValue: 24)
                _testMode = State(initialValue: false)
            } else {
                _selectedCadence = State(initialValue: .daily)
                _useCustomCadence = State(initialValue: true)
                _customCadenceHours = State(initialValue: habit.cadenceHours)
                _testMode = State(initialValue: false)
            }
        } else {
            _name = State(initialValue: "")
            _selectedEmoji = State(initialValue: "🎯")
            _selectedCadence = State(initialValue: .daily)
            _customCadenceHours = State(initialValue: 24)
            _useCustomCadence = State(initialValue: false)
            _testMode = State(initialValue: false)
        }
    }
    
    var isEditing: Bool {
        habit != nil
    }
    
    var currentCadenceHours: Int {
        if testMode { return -30 } // 30 seconds for testing
        return useCustomCadence ? customCadenceHours : selectedCadence.hours
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundCream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        emojiPicker
                        nameField
                        cadencePicker
                        Spacer(minLength: 20)
                        actionButtons
                    }
                    .padding(24)
                }
            }
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
            }
            .alert("Delete Habit?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteHabit()
                }
            } message: {
                Text("This will permanently delete this habit and all its history.")
            }
            .sheet(isPresented: $showAllEmojis) {
                FullEmojiPicker(selectedEmoji: $selectedEmoji)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Emoji Picker
    
    private var emojiPicker: some View {
        VStack(spacing: 16) {
            Text(selectedEmoji)
                .font(.system(size: 56))
                .frame(width: 90, height: 90)
                .background(
                    Circle()
                        .fill(Color.cardWhite)
                )
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                ForEach(suggestedEmojis, id: \.self) { emoji in
                    Button {
                        selectedEmoji = emoji
                    } label: {
                        Text(emoji)
                            .font(.system(size: 24))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(selectedEmoji == emoji ? Color.successGreen.opacity(0.2) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Button {
                showAllEmojis = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 16))
                    Text("More emojis")
                        .font(.custom("PTSans-Regular", size: 14))
                }
                .foregroundColor(.primaryText.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.cardWhite)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Name Field
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Habit Name")
                .font(.custom("PTSans-Regular", size: 14))
                .foregroundColor(.primaryText.opacity(0.6))
            
            TextField("e.g., Meditation", text: $name)
                .font(.custom("PTSans-Regular", size: 18))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardWhite)
                )
        }
    }
    
    // MARK: - Cadence Picker
    
    private var cadencePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How often?")
                .font(.custom("PTSans-Regular", size: 14))
                .foregroundColor(.primaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                ForEach(Habit.CadencePreset.allCases, id: \.hours) { preset in
                    CadenceOptionRow(
                        title: preset.displayName,
                        subtitle: formatCadenceSubtitle(hours: preset.hours),
                        isSelected: !useCustomCadence && selectedCadence == preset
                    ) {
                        selectedCadence = preset
                        useCustomCadence = false
                    }
                }
                
                CadenceOptionRow(
                    title: "Custom",
                    subtitle: useCustomCadence ? formatCadenceSubtitle(hours: customCadenceHours) : "Set your own",
                    isSelected: useCustomCadence
                ) {
                    useCustomCadence = true
                }
            }
            
            if useCustomCadence {
                HStack {
                    Text("Every")
                        .font(.custom("PTSans-Regular", size: 16))
                        .foregroundColor(.primaryText)
                    
                    Stepper(value: $customCadenceHours, in: 1...336, step: customCadenceHours < 24 ? 1 : 12) {
                        Text("\(customCadenceHours) hours")
                            .font(.custom("PTSans-Regular", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cardWhite)
                )
            }
            
            // Test mode toggle (for development)
            Toggle(isOn: $testMode) {
                HStack {
                    Text("⚠️")
                    Text("Test Mode (30 sec)")
                        .font(.custom("PTSans-Regular", size: 14))
                        .foregroundColor(.primaryText.opacity(0.6))
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .dangerRed))
            .padding(.top, 8)
        }
    }
    
    private func formatCadenceSubtitle(hours: Int) -> String {
        // Negative hours = seconds (test mode)
        if hours < 0 {
            return "\(-hours) seconds"
        } else if hours < 24 {
            return "\(hours) hours"
        } else if hours == 24 {
            return "24 hours"
        } else if hours % 24 == 0 {
            let days = hours / 24
            return "\(days) day\(days > 1 ? "s" : "")"
        } else {
            let days = hours / 24
            let remainingHours = hours % 24
            return "\(days)d \(remainingHours)h"
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                saveHabit()
            } label: {
                Text(isEditing ? "Save Changes" : "Create Habit")
                    .font(.custom("PTSans-Regular", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(name.isEmpty ? Color.neutralGray : Color.successGreen)
                    )
            }
            .disabled(name.isEmpty)
            .buttonStyle(.plain)
            
            if isEditing {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Habit")
                        .font(.custom("PTSans-Regular", size: 16))
                        .foregroundColor(.dangerRed)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveHabit() {
        if let habit {
            habit.name = name
            habit.emoji = selectedEmoji
            habit.cadenceHours = currentCadenceHours
        } else {
            let allHabits = (try? modelContext.fetch(FetchDescriptor<Habit>())) ?? []
            let maxSortOrder = allHabits.map(\.sortOrder).max() ?? -1
            let newHabit = Habit(
                name: name,
                emoji: selectedEmoji,
                sortOrder: maxSortOrder + 1,
                cadenceHours: currentCadenceHours
            )
            modelContext.insert(newHabit)
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteHabit() {
        if let habit {
            modelContext.delete(habit)
            try? modelContext.save()
        }
        dismiss()
    }
}

// MARK: - Full Emoji Picker

struct FullEmojiPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmoji: String
    @State private var selectedCategory: EmojiCategory = .smileys
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(EmojiCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Text(category.icon)
                                    .font(.system(size: 24))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedCategory == category ? Color.successGreen.opacity(0.2) : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
                .background(Color.cardWhite)
                
                // Emoji grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                        ForEach(selectedCategory.emojis, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                                dismiss()
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 40, height: 40)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .background(Color.backgroundCream)
            .navigationTitle("Choose Emoji")
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

// MARK: - Emoji Categories

enum EmojiCategory: CaseIterable {
    case smileys
    case people
    case nature
    case food
    case activities
    case travel
    case objects
    case symbols
    
    var icon: String {
        switch self {
        case .smileys: return "😀"
        case .people: return "👋"
        case .nature: return "🌿"
        case .food: return "🍎"
        case .activities: return "⚽"
        case .travel: return "✈️"
        case .objects: return "💡"
        case .symbols: return "❤️"
        }
    }
    
    var emojis: [String] {
        switch self {
        case .smileys:
            return ["😀", "😃", "😄", "😁", "😅", "😂", "🤣", "😊", "😇", "🙂", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "😮‍💨", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "🥸", "😎", "🤓", "🧐"]
        case .people:
            return ["👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤌", "🤏", "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "💪", "🦾", "🦿", "🦵", "🦶", "👂", "🦻", "👃", "🧠", "🫀", "🫁", "🦷", "🦴", "👀", "👁️", "👅", "👄", "👶", "🧒", "👦", "👧", "🧑", "👱", "👨", "🧔", "👩", "🧓", "👴", "👵"]
        case .nature:
            return ["🌿", "🌱", "🌲", "🌳", "🌴", "🌵", "🎋", "🎍", "🌾", "🌷", "🌹", "🥀", "🌺", "🌸", "🌼", "🌻", "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜", "🦟", "🦗", "🕷️", "🦂", "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡"]
        case .food:
            return ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑", "🥦", "🥬", "🥒", "🌶️", "🫑", "🌽", "🥕", "🫒", "🧄", "🧅", "🥔", "🍠", "🥐", "🥯", "🍞", "🥖", "🥨", "🧀", "🥚", "🍳", "🧈", "🥞", "🧇", "🥓", "🥩", "🍗", "🍖", "🦴", "🌭", "🍔", "🍟", "🍕", "🫓", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗", "🥘", "🫕", "🥫", "🍝", "🍜"]
        case .activities:
            return ["⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🏑", "🥍", "🏏", "🪃", "🥅", "⛳", "🪁", "🏹", "🎣", "🤿", "🥊", "🥋", "🎽", "🛹", "🛼", "🛷", "⛸️", "🥌", "🎿", "⛷️", "🏂", "🪂", "🏋️", "🤼", "🤸", "🤺", "⛹️", "🤾", "🏌️", "🏇", "🧘", "🏄", "🏊", "🤽", "🚣", "🧗", "🚴", "🚵", "🎖️", "🏆", "🥇", "🥈", "🥉", "🏅", "🎪", "🎭", "🎨", "🎬", "🎤", "🎧"]
        case .travel:
            return ["✈️", "🚀", "🛸", "🚁", "🛶", "⛵", "🚤", "🛥️", "🛳️", "⛴️", "🚢", "🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐", "🛻", "🚚", "🚛", "🚜", "🏍️", "🛵", "🚲", "🛴", "🛹", "🚏", "🛣️", "🛤️", "🛢️", "⛽", "🚨", "🚥", "🚦", "🛑", "🚧", "⚓", "🗺️", "🗿", "🗽", "🗼", "🏰", "🏯", "🏟️", "🎡", "🎢", "🎠", "⛲", "⛱️", "🏖️", "🏝️", "🏜️", "🌋", "⛰️", "🏔️", "🗻", "🏕️", "⛺", "🛖", "🏠", "🏡"]
        case .objects:
            return ["💡", "🔦", "🏮", "📱", "💻", "🖥️", "🖨️", "⌨️", "🖱️", "💾", "💿", "📀", "🎥", "📷", "📸", "📹", "📼", "🔍", "🔎", "🔬", "🔭", "📡", "🕯️", "💎", "🔧", "🔨", "⚒️", "🛠️", "⛏️", "🔩", "⚙️", "🧱", "⛓️", "🧲", "🔫", "💣", "🧨", "🪓", "🔪", "🗡️", "⚔️", "🛡️", "🚬", "⚰️", "🪦", "⚱️", "🏺", "🔮", "📿", "🧿", "💈", "⚗️", "🔭", "🧫", "🧪", "🌡️", "🧹", "🧺", "🧻", "🚽", "🚰", "🚿", "🛁", "🛀"]
        case .symbols:
            return ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💟", "☮️", "✝️", "☪️", "🕉️", "☸️", "✡️", "🔯", "🕎", "☯️", "☦️", "🛐", "⛎", "♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓", "🆔", "⚛️", "🉑", "☢️", "☣️", "📴", "📳", "🈶", "🈚", "🈸", "🈺", "🈷️", "✴️", "🆚", "💮", "🉐", "㊙️", "㊗️", "🈴", "🈵", "🈹"]
        }
    }
}

// MARK: - Cadence Option Row

struct CadenceOptionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("PTSans-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    Text(subtitle)
                        .font(.custom("PTSans-Regular", size: 13))
                        .foregroundColor(.primaryText.opacity(0.5))
                }
                
                Spacer()
                
                Circle()
                    .stroke(isSelected ? Color.successGreen : Color.neutralGray, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color.successGreen : Color.clear)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardWhite)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Add Habit") {
    AddEditHabitView(habit: nil)
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
