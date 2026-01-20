import { db, getSettings, updateSettings } from "./db";
import type { Habit, HabitCompletion } from "./types";

const sampleHabit: Habit = {
  id: crypto.randomUUID(),
  name: "Think about Luis",
  emoji: "🥰",
  createdAt: Date.now(),
  isArchived: false,
  sortOrder: 0,
  cadenceHours: 24,
  isFrozen: false,
  frozenAt: null,
  lastAwardedMilestone: 0
};

export async function ensureSeedData() {
  const habitsCount = await db.habits.count();
  if (habitsCount > 0) {
    return;
  }

  await db.habits.add(sampleHabit);

  const now = Date.now();
  const completions: HabitCompletion[] = [
    {
      id: crypto.randomUUID(),
      habitId: sampleHabit.id,
      completedAt: now - 2 * 60 * 60 * 1000,
      notes: null
    },
    {
      id: crypto.randomUUID(),
      habitId: sampleHabit.id,
      completedAt: now - 24 * 60 * 60 * 1000,
      notes: null
    },
    {
      id: crypto.randomUUID(),
      habitId: sampleHabit.id,
      completedAt: now - 48 * 60 * 60 * 1000,
      notes: null
    }
  ];

  await db.completions.bulkAdd(completions);

  const settings = await getSettings();
  if (settings.streakFreezeCount === 0) {
    await updateSettings({ streakFreezeCount: 5 });
  }
}
