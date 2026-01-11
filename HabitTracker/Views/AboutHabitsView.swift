//
//  AboutHabitsView.swift
//  HabitTracker
//
//  Created by Luis Amrein
//

import SwiftUI

struct AboutHabitsView: View {
    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The Habbit Manual")
                            .font(.custom("PTSans-Bold", size: 28))
                            .foregroundColor(.primaryText)
                        
                        Text("A friendly, practical guide to building habits that actually stick.")
                            .font(.custom("PTSans-Regular", size: 16))
                            .foregroundColor(.primaryText.opacity(0.7))
                    }
                    
                    // Sections
                    ForEach(sections) { section in
                        ArticleSection(section: section)
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("About habits")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Article Content
    
    private var sections: [ManualSection] {
        [
            ManualSection(
                title: "1) What a habit is",
                body: """
In behavioral psychology, a habit is a behavior your brain learns to run with less conscious effort because it's been repeated in a similar context and consistently followed by some kind of payoff.

A useful model is the habit loop:

• Cue: the trigger (time, place, emotion, people, or a preceding action)
• Routine: the behavior (what you do)
• Reward: the payoff (what your brain gets—relief, satisfaction, progress, pleasure)

Your brain doesn't become consistent because you "want it" more. It becomes consistent because the cue becomes reliable, the routine becomes easy, and the reward becomes expected.
"""
            ),
            ManualSection(
                title: "2) Why motivation fails",
                body: """
Motivation is a mood state. Habits are a learning process.

When you're tired, stressed, or busy, your brain defaults to:
• whatever is easiest,
• whatever is most familiar,
• whatever pays off fastest.

So the goal is to design a system where the habit is:
• easy to start (low friction),
• triggered reliably (strong cue),
• reinforced quickly (reward you feel now, not in 6 months).

This is behavioral design: change the environment + timing + payoff, not your personality.
"""
            ),
            ManualSection(
                title: "3) Start tiny",
                body: """
A common failure mode is picking a habit that only works on a "good day." Behavioral psychology solves this with shaping: you reinforce small, doable steps that gradually build toward the full behavior.

Your "minimum rep" should be so small that you can do it even when you're not feeling it:
• Reading: 1 page
• Workout: put on shoes + 10 bodyweight reps
• Meditation: sit and take 5 breaths
• Journal: one sentence

This works because the biggest barrier is usually initiation. Once you start, continuing is easier. Shaping gets you consistent starts.
"""
            ),
            ManualSection(
                title: "4) Make the cue explicit",
                body: """
One of the most evidence-backed tools in behavior change is the implementation intention:

"If [cue], then I will [behavior]."

This reduces decision-making in the moment. You're not asking "should I do it?"—you're executing a plan you already chose.

Examples:
• If I finish brushing my teeth, then I floss one tooth.
• If I pour my morning coffee, then I read one page.
• If I close my laptop at night, then I stretch for 60 seconds.

Good cues are specific, stable, and close to the behavior.
"""
            ),
            ManualSection(
                title: "5) Use habit stacking",
                body: """
Habit stacking is cue design using behaviors you already do automatically.

Instead of relying on a brand-new cue ("I'll remember at 7pm"), you attach your new habit to a reliable routine:
• After I lock the door, I take 3 deep breaths.
• After lunch, I walk for 5 minutes.
• After I get into bed, I write one line of gratitude.

Psychologically, this works because your existing routine already has strong cue strength and low variability.
"""
            ),
            ManualSection(
                title: "6) Engineer your environment",
                body: """
A core concept in behavioral psychology is stimulus control: behavior is strongly shaped by the cues around you.

If you want a habit to happen, you make its cues obvious and its first step easy. If you want a bad habit to fade, you remove cues and increase friction.

Practical examples:
• Put the book on your pillow (cue + low friction).
• Keep the guitar on a stand, not in a case.
• Put workout clothes where you will trip over them.
• Charge your phone outside the bedroom.

This isn't "discipline." It's changing the stimulus field so the habit becomes the default option.
"""
            ),
            ManualSection(
                title: "7) Reward matters",
                body: """
In psychology, behaviors repeat when they are reinforced.

The problem: many good habits have delayed rewards (health, skill, confidence). Your brain learns fastest from rewards that are immediate.

So you add immediate reinforcement on purpose:
• A satisfying "done" moment (check-in, progress ring completion)
• A small pleasure paired with the habit (music during cleaning, tea during reading)
• A short self-signal: "I keep promises to myself."

The brain doesn't need a huge reward. It needs a reliable reward.
"""
            ),
            ManualSection(
                title: "8) Lower the friction",
                body: """
When a behavior is hard to start, you get avoidance—even if you "care."

Two rules:
• Lower the friction for the habit you want.
• Raise the friction for the habit you don't want.

Examples:
• Want to drink water? Put a bottle at your desk and pre-fill it.
• Want to run? Put shoes by the door.
• Want less doomscrolling? Remove the app from home screen.

Small friction changes compound because you face them every day.
"""
            ),
            ManualSection(
                title: "9) Choose a realistic cadence",
                body: """
Habits form through repeated cue→routine→reward cycles. If you set a cadence that you keep failing, your brain learns a different pattern: "this is optional."

A realistic rule:
• Choose a cadence you can hit most of the time.
• If you miss repeatedly, reduce either the difficulty (smaller habit) or the frequency (longer cadence).

Consistency is not a moral achievement; it's a learning condition.
"""
            ),
            ManualSection(
                title: "10) Plan for misses",
                body: """
From a behavioral standpoint, missing once is normal. What matters is whether the miss becomes a new habit.

Use a recovery rule:
• If I miss, the next time I do the minimum rep, no matter what.
• I don't "punish" myself with an extreme makeup session.

This avoids the shame spiral: shame increases avoidance; avoidance increases inconsistency.

Your goal isn't perfection. It's rapid recovery.
"""
            ),
            ManualSection(
                title: "11) Identity-based habits",
                body: """
There's a powerful psychological effect: when you repeatedly do a behavior, you start to see yourself as the kind of person who does it.

Instead of "I'm trying to meditate," you become "I'm someone who meditates."

A simple trick: After you do the minimum rep, mentally label it:
• "I'm the kind of person who shows up."
• "I keep small promises."

This reinforces identity, which increases future consistency.
"""
            ),
            ManualSection(
                title: "12) How to use Habbit",
                body: """
Use the app to support the psychology:
• Make the habit tiny so initiation wins.
• Set a cadence you can actually meet.
• Complete immediately after the behavior so the reward is linked to the action.
• Review your month to learn what conditions helped you succeed.

If a habit keeps failing, don't blame yourself—adjust the system:
• weaker cue → attach to a better anchor
• too big → reduce minimum rep
• too frequent → increase cadence
• no reward → add immediate reinforcement
"""
            ),
            ManualSection(
                title: "Troubleshooting",
                body: """
• You forget: your cue is weak. Tie it to a stable routine (after coffee / after brushing teeth).

• You avoid: the habit is too big or too unpleasant. Shrink it and improve the immediate reward.

• You're inconsistent: cadence is too ambitious or your environment supports competing behaviors.

• You do it but hate it: keep the cue, change the routine (same "slot," different activity).
"""
            )
        ]
    }
}

// MARK: - Supporting Types

struct ManualSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct ArticleSection: View {
    let section: ManualSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.custom("PTSans-Bold", size: 20))
                .foregroundColor(.primaryText)
            
            Text(section.body)
                .font(.custom("PTSans-Regular", size: 16))
                .foregroundColor(.primaryText.opacity(0.85))
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardWhite)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AboutHabitsView()
    }
}
