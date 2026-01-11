//
//  ManageHabitsView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI
import SwiftData

struct ManageHabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.sortOrder)
    private var habits: [Habit]
    
    @State private var editingHabit: Habit?
    @State private var habitToDelete: Habit?
    @State private var showDeleteConfirmation = false
    @State private var orderedHabits: [Habit] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundCream
                    .ignoresSafeArea()
                
                if orderedHabits.isEmpty {
                    ScrollView {
                        emptyState
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }
                } else {
                    VStack(spacing: 0) {
                        List {
                            ForEach(orderedHabits) { habit in
                                HabitEditRow(
                                    habit: habit,
                                    onTap: {
                                        editingHabit = habit
                                    },
                                    onDelete: {
                                        habitToDelete = habit
                                        showDeleteConfirmation = true
                                    }
                                )
                                .listRowBackground(Color.cardWhite)
                                .listRowSeparatorTint(Color.neutralGray.opacity(0.3))
                            }
                            .onMove(perform: moveHabits)
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                        .environment(\.editMode, .constant(.active))
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Edit Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
            }
            .sheet(item: $editingHabit) { habit in
                AddEditHabitView(habit: habit)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .alert("Delete Habit?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    habitToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let habit = habitToDelete {
                        deleteHabit(habit)
                    }
                }
            } message: {
                Text("This will permanently delete this habit and all its history.")
            }
            .onAppear {
                orderedHabits = habits
            }
            .onChange(of: habits) { _, newHabits in
                // Only update if not currently reordering
                if orderedHabits.count != newHabits.count {
                    orderedHabits = newHabits
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("📝")
                .font(.system(size: 64))
            
            Text("No habits to edit")
                .font(.custom("PTSans-Regular", size: 20))
                .foregroundColor(.primaryText)
            
            Text("Add some habits first from the home screen")
                .font(.custom("PTSans-Regular", size: 16))
                .foregroundColor(.primaryText.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 29)
                .fill(Color.cardWhite)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
    }
    
    // MARK: - Actions
    
    private func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        try? modelContext.save()
        habitToDelete = nil
        orderedHabits.removeAll { $0.id == habit.id }
    }
    
    private func moveHabits(from source: IndexSet, to destination: Int) {
        orderedHabits.move(fromOffsets: source, toOffset: destination)
        
        // Update sort order for all habits
        for (index, habit) in orderedHabits.enumerated() {
            habit.sortOrder = index
        }
        
        try? modelContext.save()
    }
}

// MARK: - Habit Edit Row

struct HabitEditRow: View {
    let habit: Habit
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Delete button (left side)
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.dangerRed)
            }
            .buttonStyle(.plain)
            
            // Habit info (tappable to edit)
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Text(habit.emoji)
                        .font(.system(size: 26))
                    
                    Text(habit.name)
                        .font(.custom("PTSans-Regular", size: 17))
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Make Habit Identifiable for sheet(item:)
extension Habit: Identifiable {}

// MARK: - Preview

#Preview {
    ManageHabitsView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
