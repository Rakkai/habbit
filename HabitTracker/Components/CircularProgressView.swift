//
//  CircularProgressView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct CircularProgressView: View {
    /// Progress from 0.0 to 1.0
    let progress: Double
    
    /// The habit state for coloring
    let habitState: Habit.HabitState
    
    /// Line width of the progress ring
    var lineWidth: CGFloat = 8
    
    /// Size of the circle
    var size: CGFloat = 100
    
    private var progressColor: Color {
        switch habitState {
        case .frozen:
            return .icyBlue
        case .gracePeriod:
            return .dangerRed
        case .onTrack:
            return .successGreen
        case .streakLost:
            return .neutralGray
        }
    }
    
    private var trackColor: Color {
        switch habitState {
        case .frozen:
            return .icyBlue.opacity(0.3)
        case .streakLost:
            return .neutralGray.opacity(0.3)
        default:
            return .neutralGray.opacity(0.3)
        }
    }
    
    private var fillColor: Color {
        switch habitState {
        case .frozen:
            return .icyBlue.opacity(0.2)
        case .streakLost:
            return .clear
        default:
            return progress > 0 ? progressColor.opacity(0.15) : .clear
        }
    }
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            // Progress arc - counter-clockwise from top
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90)) // Start from top
                .scaleEffect(x: -1, y: 1) // Counter-clockwise
            
            // Inner fill
            Circle()
                .fill(fillColor)
                .padding(lineWidth / 2)
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.3), value: progress)
        .animation(.easeInOut(duration: 0.3), value: habitState)
    }
}

// MARK: - Make HabitState Equatable for animation
extension Habit.HabitState: Equatable {}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            // On Track (green)
            CircularProgressView(progress: 1.0, habitState: .onTrack)
            CircularProgressView(progress: 0.5, habitState: .onTrack)
            CircularProgressView(progress: 0.1, habitState: .onTrack)
        }
        
        HStack(spacing: 20) {
            // Grace Period (red)
            CircularProgressView(progress: 0.8, habitState: .gracePeriod)
            CircularProgressView(progress: 0.3, habitState: .gracePeriod)
            CircularProgressView(progress: 0.0, habitState: .gracePeriod)
        }
        
        HStack(spacing: 20) {
            // Frozen (icy blue)
            CircularProgressView(progress: 1.0, habitState: .frozen)
            
            // Streak Lost (grey)
            CircularProgressView(progress: 0.0, habitState: .streakLost)
        }
    }
    .padding()
    .background(Color.backgroundCream)
}
