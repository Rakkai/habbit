"use client";

import Link from "next/link";

import { BottomNav } from "../../../components/BottomNav";
import { db } from "../../../lib/db";
import { useHabitsWithCompletions, useRequireWelcome, useSettings } from "../../../lib/hooks";

export default function ManageHabitsPage() {
  const habits = useHabitsWithCompletions();
  const { settings } = useSettings();

  useRequireWelcome(settings);

  async function moveHabit(index: number, direction: "up" | "down") {
    const targetIndex = direction === "up" ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= habits.length) {
      return;
    }

    const current = habits[index];
    const target = habits[targetIndex];

    await db.habits.update(current.id, { sortOrder: target.sortOrder });
    await db.habits.update(target.id, { sortOrder: current.sortOrder });
  }

  async function deleteHabit(id: string) {
    await db.completions.where("habitId").equals(id).delete();
    await db.habits.delete(id);
  }

  if (habits.length === 0) {
    return (
      <div className="min-h-screen bg-background">
        <main className="container">
          <div className="card rounded-[29px] p-10 text-center">
            <div className="text-[64px]" aria-hidden="true">
              📝
            </div>
            <h2 className="mt-4 text-[20px] font-medium">No habits to edit</h2>
            <p className="text-[16px] text-text/60">Add some habits first from the home screen</p>
          </div>
          <Link href="/habits" className="mt-6 inline-flex text-sm text-success">
            ← Back to habits
          </Link>
        </main>
        <BottomNav />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <main className="container">
        <div className="mb-4 flex items-center justify-between">
          <h1 className="text-[20px] font-medium">Edit Habits</h1>
          <Link href="/habits" className="text-[14px] text-success">
            Done
          </Link>
        </div>

        <div className="card overflow-hidden">
          {habits.map((habit, index) => (
            <div key={habit.id} className="flex items-center gap-3 border-b border-neutral/30 px-4 py-3">
              <button
                onClick={() => deleteHabit(habit.id)}
                className="text-[22px] text-danger"
                aria-label="Delete habit"
                type="button"
              >
                ⊖
              </button>
              <div className="flex flex-1 items-center gap-3">
                <span className="text-[26px]" aria-hidden="true">
                  {habit.emoji}
                </span>
                <span className="text-[17px]">{habit.name}</span>
              </div>
              <div className="flex flex-col gap-1">
                <button
                  onClick={() => moveHabit(index, "up")}
                  className="text-[12px] text-text/60"
                  aria-label="Move habit up"
                  type="button"
                >
                  ↑
                </button>
                <button
                  onClick={() => moveHabit(index, "down")}
                  className="text-[12px] text-text/60"
                  aria-label="Move habit down"
                  type="button"
                >
                  ↓
                </button>
              </div>
            </div>
          ))}
        </div>
      </main>
      <BottomNav />
    </div>
  );
}
