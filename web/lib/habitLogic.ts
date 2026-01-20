import type { HabitCompletion, HabitWithCompletions } from "./types";

export type HabitState = "onTrack" | "gracePeriod" | "frozen" | "streakLost";

export function getLastCompletedAt(completions: HabitCompletion[]): number | null {
  if (!completions.length) {
    return null;
  }
  return completions.reduce((latest, completion) => {
    return completion.completedAt > latest ? completion.completedAt : latest;
  }, completions[0].completedAt);
}

export function cadenceSeconds(cadenceHours: number): number {
  if (cadenceHours < 0) {
    return Math.abs(cadenceHours);
  }
  return cadenceHours * 3600;
}

export function gracePeriodSeconds(cadenceHours: number): number {
  if (cadenceHours < 0) {
    return Math.abs(cadenceHours);
  }
  return 24 * 3600;
}

export function habitState(habit: HabitWithCompletions, now: number): HabitState {
  if (habit.isFrozen) {
    return "frozen";
  }
  const lastCompletedAt = getLastCompletedAt(habit.completions);
  if (!lastCompletedAt) {
    return "streakLost";
  }
  const elapsed = (now - lastCompletedAt) / 1000;
  const cadence = cadenceSeconds(habit.cadenceHours);
  const grace = gracePeriodSeconds(habit.cadenceHours);

  if (elapsed <= cadence) {
    return "onTrack";
  }
  if (elapsed <= cadence + grace) {
    return "gracePeriod";
  }
  return "streakLost";
}

export function progressRemaining(habit: HabitWithCompletions, now: number): number {
  if (habit.isFrozen) {
    return 1;
  }
  const lastCompletedAt = getLastCompletedAt(habit.completions);
  if (!lastCompletedAt) {
    return 0;
  }
  const elapsed = (now - lastCompletedAt) / 1000;
  const remaining = 1 - elapsed / cadenceSeconds(habit.cadenceHours);
  return Math.max(0, Math.min(1, remaining));
}

export function graceProgress(habit: HabitWithCompletions, now: number): number {
  const lastCompletedAt = getLastCompletedAt(habit.completions);
  if (!lastCompletedAt) {
    return 0;
  }
  const elapsed = (now - lastCompletedAt) / 1000;
  const cadence = cadenceSeconds(habit.cadenceHours);
  const grace = gracePeriodSeconds(habit.cadenceHours);
  const elapsedAfterCadence = elapsed - cadence;

  if (elapsedAfterCadence <= 0) {
    return 1;
  }
  const remaining = 1 - elapsedAfterCadence / grace;
  return Math.max(0, Math.min(1, remaining));
}

export function needsAutoFreeze(habit: HabitWithCompletions, now: number): boolean {
  if (habit.isFrozen || habit.completions.length === 0) {
    return false;
  }
  return habitState(habit, now) === "streakLost";
}

export function currentStreak(habit: HabitWithCompletions, now: number): number {
  if (habitState(habit, now) === "streakLost") {
    return 0;
  }
  return habit.completions.length;
}

export function timeRemainingLabel(habit: HabitWithCompletions, now: number): string {
  const state = habitState(habit, now);
  if (state === "frozen") {
    return "Frozen ❄️";
  }
  if (state === "streakLost") {
    return "Streak lost";
  }
  if (state === "gracePeriod") {
    const graceSecondsLeft = graceProgress(habit, now) * gracePeriodSeconds(habit.cadenceHours);
    const hoursLeft = graceSecondsLeft / 3600;
    if (hoursLeft >= 1) {
      return `${Math.floor(hoursLeft)}h left!`;
    }
    const minutesLeft = Math.max(0, Math.floor(graceSecondsLeft / 60));
    return `${minutesLeft}m left!`;
  }

  const lastCompletedAt = getLastCompletedAt(habit.completions);
  if (!lastCompletedAt) {
    return "";
  }
  const elapsed = (now - lastCompletedAt) / 1000;
  const remaining = Math.max(0, cadenceSeconds(habit.cadenceHours) - elapsed);
  const hours = remaining / 3600;

  if (hours >= 24) {
    const days = Math.floor(hours / 24);
    const remainingHours = Math.floor(hours % 24);
    return remainingHours > 0 ? `${days}d ${remainingHours}h` : `${days}d`;
  }
  if (hours >= 1) {
    return `${Math.floor(hours)}h`;
  }
  return `${Math.floor(hours * 60)}m`;
}

export function checkForNewStreakFreeze(habit: HabitWithCompletions): boolean {
  const streak = habit.completions.length;
  const currentMilestone = Math.floor(streak / 5) * 5;
  if (streak > 0 && streak % 5 === 0 && currentMilestone > habit.lastAwardedMilestone) {
    return true;
  }
  return false;
}
