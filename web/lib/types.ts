export type Habit = {
  id: string;
  name: string;
  emoji: string;
  createdAt: number;
  isArchived: boolean;
  sortOrder: number;
  cadenceHours: number;
  isFrozen: boolean;
  frozenAt?: number | null;
  lastAwardedMilestone: number;
};

export type HabitCompletion = {
  id: string;
  habitId: string;
  completedAt: number;
  notes?: string | null;
};

export type AppSettings = {
  id: string;
  userName: string;
  hasCompletedWelcome: boolean;
  appearanceMode: "system" | "light" | "dark";
  streakFreezeCount: number;
};

export type HabitWithCompletions = Habit & {
  completions: HabitCompletion[];
};
