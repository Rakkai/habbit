import Dexie, { type Table } from "dexie";

import type { AppSettings, Habit, HabitCompletion } from "./types";

export class HabbitDB extends Dexie {
  habits!: Table<Habit, string>;
  completions!: Table<HabitCompletion, string>;
  settings!: Table<AppSettings, string>;

  constructor() {
    super("habbit-db");
    this.version(1).stores({
      habits: "id, sortOrder, isArchived",
      completions: "id, habitId, completedAt",
      settings: "id"
    });
  }
}

export const db = new HabbitDB();

export const DEFAULT_SETTINGS: AppSettings = {
  id: "settings",
  userName: "Luis",
  hasCompletedWelcome: false,
  appearanceMode: "system",
  streakFreezeCount: 0
};

export async function getSettings(): Promise<AppSettings> {
  const stored = await db.settings.get("settings");
  if (stored) {
    return stored;
  }
  await db.settings.put(DEFAULT_SETTINGS);
  return DEFAULT_SETTINGS;
}

export async function updateSettings(update: Partial<AppSettings>) {
  const current = await getSettings();
  const next = { ...current, ...update };
  await db.settings.put(next);
  return next;
}
