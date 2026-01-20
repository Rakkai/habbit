"use client";

import { CircularProgress } from "./CircularProgress";
import type { HabitWithCompletions } from "../lib/types";
import { currentStreak, graceProgress, habitState, progressRemaining } from "../lib/habitLogic";

const stateIconMap = {
  frozen: "❄️",
  streakLost: "",
  onTrack: "🔥",
  gracePeriod: "🔥"
} as const;

const stateColorMap = {
  frozen: "var(--color-icy-dark)",
  streakLost: "var(--color-neutral)",
  onTrack: "var(--color-text)",
  gracePeriod: "var(--color-text)"
} as const;

type HabitTileProps = {
  habit: HabitWithCompletions;
  now: number;
  onComplete: () => void;
  onEdit: () => void;
};

export function HabitTile({ habit, now, onComplete, onEdit }: HabitTileProps) {
  const state = habitState(habit, now);
  const progress = state === "gracePeriod" ? graceProgress(habit, now) : progressRemaining(habit, now);
  const streak = currentStreak(habit, now);
  const icon = state === "frozen" ? stateIconMap.frozen : streak > 0 ? "🔥" : "";

  return (
    <div className="flex flex-col items-center gap-2">
      <button
        onClick={onComplete}
        className="relative h-[100px] w-[100px] rounded-full border-none bg-transparent p-0"
        aria-label={`Complete ${habit.name}`}
      >
        <CircularProgress progress={progress} state={state} size={100} strokeWidth={6} />
        <div className="absolute inset-0 flex flex-col items-center justify-center gap-1">
          <span className="text-2xl">{habit.emoji}</span>
          <div className="flex items-center gap-1 text-xs">
            <span style={{ color: stateColorMap[state] }} className="font-medium">
              {streak}
            </span>
            {icon ? <span className="text-[10px]">{icon}</span> : null}
          </div>
        </div>
      </button>
      <button
        onClick={onEdit}
        className="text-xs text-text/70"
        aria-label={`Edit ${habit.name}`}
      >
        Edit
      </button>
    </div>
  );
}
