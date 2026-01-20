"use client";

import type { HabitWithCompletions } from "../lib/types";
import { HabitTile } from "./HabitTile";

type HabitGridProps = {
  habits: HabitWithCompletions[];
  now: number;
  onComplete: (habit: HabitWithCompletions) => void;
  onEdit: (habit: HabitWithCompletions) => void;
};

export function HabitGrid({ habits, now, onComplete, onEdit }: HabitGridProps) {
  return (
    <div className="card rounded-tile p-6">
      <div className="grid grid-cols-2 gap-6">
        {habits.map((habit) => (
          <HabitTile
            key={habit.id}
            habit={habit}
            now={now}
            onComplete={() => onComplete(habit)}
            onEdit={() => onEdit(habit)}
          />
        ))}
      </div>
    </div>
  );
}
