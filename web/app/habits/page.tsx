"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";

import { AddEditHabitModal } from "../../components/AddEditHabitModal";
import { BottomNav } from "../../components/BottomNav";
import { HabitGrid } from "../../components/HabitGrid";
import { PillButton } from "../../components/PillButton";
import { StreakBadge } from "../../components/StreakBadge";
import { db, updateSettings } from "../../lib/db";
import {
  checkForNewStreakFreeze,
  habitState,
  needsAutoFreeze
} from "../../lib/habitLogic";
import { useHabitsWithCompletions, useRequireWelcome, useSettings } from "../../lib/hooks";
import { wisdoms } from "../../lib/content";
import type { HabitWithCompletions } from "../../lib/types";

export default function HabitsPage() {
  const habits = useHabitsWithCompletions();
  const { settings } = useSettings();
  const [selectedHabit, setSelectedHabit] = useState<HabitWithCompletions | null>(null);
  const [showModal, setShowModal] = useState(false);
  const [now, setNow] = useState(Date.now());
  const [wisdomIndex, setWisdomIndex] = useState(() => Math.floor(Math.random() * wisdoms.length));

  useRequireWelcome(settings);

  useEffect(() => {
    const interval = window.setInterval(() => setNow(Date.now()), 5000);
    return () => window.clearInterval(interval);
  }, []);

  useEffect(() => {
    if (!settings) {
      return;
    }
    const runAutoFreeze = async () => {
      let didFreeze = false;
      let availableFreezes = settings.streakFreezeCount;

      for (const habit of habits) {
        if (availableFreezes <= 0) {
          break;
        }
        if (needsAutoFreeze(habit, now)) {
          await db.habits.update(habit.id, { isFrozen: true, frozenAt: Date.now() });
          availableFreezes -= 1;
          didFreeze = true;
        }
      }

      if (didFreeze) {
        await updateSettings({ streakFreezeCount: availableFreezes });
      }
    };

    runAutoFreeze();
  }, [habits, now, settings]);

  const headerWisdom = useMemo(() => wisdoms[wisdomIndex % wisdoms.length], [wisdomIndex]);

  async function handleCompleteHabit(habit: HabitWithCompletions) {
    const nowTime = Date.now();
    const state = habitState(habit, nowTime);
    const shouldReset = state === "streakLost";

    if (shouldReset) {
      await db.completions.where("habitId").equals(habit.id).delete();
      await db.habits.update(habit.id, { lastAwardedMilestone: 0 });
    }

    if (habit.isFrozen) {
      await db.habits.update(habit.id, { isFrozen: false, frozenAt: null });
    }

    const completion = {
      id: crypto.randomUUID(),
      habitId: habit.id,
      completedAt: nowTime,
      notes: null
    };

    await db.completions.add(completion);

    const updatedHabit = {
      ...habit,
      completions: [...(shouldReset ? [] : habit.completions), completion]
    };

    if (checkForNewStreakFreeze(updatedHabit)) {
      const milestone = Math.floor(updatedHabit.completions.length / 5) * 5;
      await db.habits.update(habit.id, { lastAwardedMilestone: milestone });
      if (settings) {
        await updateSettings({ streakFreezeCount: settings.streakFreezeCount + 1 });
      }
    }

    setWisdomIndex((prev) => {
      let next = Math.floor(Math.random() * wisdoms.length);
      while (next === prev && wisdoms.length > 1) {
        next = Math.floor(Math.random() * wisdoms.length);
      }
      return next;
    });
  }

  const sortedHabits = habits.filter((habit) => !habit.isArchived);

  return (
    <div className="min-h-screen bg-background">
      <div className="container flex flex-col gap-6">
        <div className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-[22px] font-medium">Hey {settings?.userName ?? ""} 👋</h1>
            <p className="text-[22px] leading-snug text-text">{headerWisdom}</p>
          </div>
          <StreakBadge count={settings?.streakFreezeCount ?? 0} emoji="❄️" />
        </div>

        {sortedHabits.length > 0 ? (
          <>
            <HabitGrid
              habits={sortedHabits}
              now={now}
              onComplete={handleCompleteHabit}
              onEdit={(habit) => {
                setSelectedHabit(habit);
                setShowModal(true);
              }}
            />

            <PillButton
              title="Add new habit"
              icon="➕"
              onClick={() => {
                setSelectedHabit(null);
                setShowModal(true);
              }}
            />

            <Link href="/habits/manage" className="pill-button w-full justify-center">
              ✏️ Edit habits
            </Link>
          </>
        ) : (
          <div className="card rounded-tile p-10 text-center">
            <div className="text-[64px]">🎯</div>
            <h2 className="mt-4 text-[20px] font-medium">No habits yet</h2>
            <p className="text-[16px] text-text/60">Create your first habit to get started</p>
            <div className="mt-6">
              <PillButton
                title="Add new habit"
                icon="➕"
                onClick={() => {
                  setSelectedHabit(null);
                  setShowModal(true);
                }}
              />
            </div>
          </div>
        )}
      </div>

      <BottomNav />

      <AddEditHabitModal habit={selectedHabit} isOpen={showModal} onClose={() => setShowModal(false)} />
    </div>
  );
}
