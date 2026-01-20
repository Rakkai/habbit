"use client";

import { useMemo, useState } from "react";

import { BottomNav } from "../../components/BottomNav";
import { StatCard } from "../../components/StatCard";
import { currentStreak } from "../../lib/habitLogic";
import { useHabitsWithCompletions, useRequireWelcome, useSettings } from "../../lib/hooks";
import type { HabitWithCompletions } from "../../lib/types";

function startOfMonth(date: Date) {
  return new Date(date.getFullYear(), date.getMonth(), 1);
}

function getCalendarDays(month: Date) {
  const firstOfMonth = startOfMonth(month);
  const firstWeekday = firstOfMonth.getDay();
  const adjustedFirstWeekday = (firstWeekday + 5) % 7 + 1;
  const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
  const days: Array<Date | null> = Array(adjustedFirstWeekday - 1).fill(null);

  for (let day = 1; day <= daysInMonth; day += 1) {
    days.push(new Date(month.getFullYear(), month.getMonth(), day));
  }

  return days;
}

function isSameDay(a: Date, b: Date) {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

function isSameMonth(a: Date, b: Date) {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth();
}

export default function DashboardPage() {
  const habits = useHabitsWithCompletions();
  const { settings } = useSettings();
  const [selectedMonth, setSelectedMonth] = useState(new Date());
  const [selectedHabitId, setSelectedHabitId] = useState<string | "all">("all");
  const now = Date.now();

  useRequireWelcome(settings);

  const filteredHabits = useMemo(() => {
    if (selectedHabitId === "all") {
      return habits;
    }
    return habits.filter((habit) => habit.id === selectedHabitId);
  }, [habits, selectedHabitId]);

  const totalCompletions = filteredHabits.reduce((sum, habit) => sum + habit.completions.length, 0);
  const bestStreak = filteredHabits.reduce(
    (max, habit) => Math.max(max, currentStreak(habit, now)),
    0
  );

  const calendarDays = useMemo(() => getCalendarDays(selectedMonth), [selectedMonth]);
  const selectedHabit = useMemo(
    () => (selectedHabitId === "all" ? null : habits.find((habit) => habit.id === selectedHabitId) ?? null),
    [habits, selectedHabitId]
  );

  function isDateCompleted(date: Date) {
    return filteredHabits.some((habit) =>
      habit.completions.some((completion) => isSameDay(new Date(completion.completedAt), date))
    );
  }

  function changeMonth(offset: number) {
    const newDate = new Date(selectedMonth);
    newDate.setMonth(newDate.getMonth() + offset);
    setSelectedMonth(newDate);
  }

  return (
    <div className="min-h-screen bg-background">
      <main className="container flex flex-col gap-6">
        <h1 className="text-[28px] font-semibold">Analysis</h1>

        <div className="flex flex-col gap-4 sm:flex-row">
          <StatCard title="Total Completions" value={`${totalCompletions}`} icon="✅" />
          <StatCard title="Best Streak" value={`${bestStreak}`} icon="🔥" />
        </div>

        <div className="relative flex items-center gap-3 rounded-full bg-card px-5 py-3 shadow-softSm">
          <span className="text-[24px] leading-none" aria-hidden="true">
            {selectedHabit ? selectedHabit.emoji : "📊"}
          </span>
          <label htmlFor="habit-filter" className="sr-only">
            Filter habits
          </label>
          <select
            id="habit-filter"
            value={selectedHabitId}
            onChange={(event) => setSelectedHabitId(event.target.value)}
            className="w-full appearance-none bg-transparent text-[16px] text-text"
          >
            <option value="all">All Habits</option>
            {habits.map((habit) => (
              <option key={habit.id} value={habit.id}>
                {habit.emoji} {habit.name}
              </option>
            ))}
          </select>
          <span className="pointer-events-none text-[14px] text-text/50">⌄</span>
        </div>

        <div className="card rounded-tile p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <button onClick={() => changeMonth(-12)} className="text-text/40" type="button" aria-label="Previous year">
                «
              </button>
              <button onClick={() => changeMonth(-1)} className="text-text" type="button" aria-label="Previous month">
                ‹
              </button>
            </div>
            <div className="text-[16px] font-medium">
              {selectedMonth.toLocaleDateString(undefined, { month: "long", year: "numeric" })}
            </div>
            <div className="flex items-center gap-2">
              <button onClick={() => changeMonth(1)} className="text-text" type="button" aria-label="Next month">
                ›
              </button>
              <button onClick={() => changeMonth(12)} className="text-text/40" type="button" aria-label="Next year">
                »
              </button>
            </div>
          </div>

          <div className="mt-4 grid grid-cols-7 text-center text-[12px] text-text/50">
            {["M", "T", "W", "T", "F", "S", "S"].map((day) => (
              <div key={day}>{day}</div>
            ))}
          </div>

          <div className="mt-2 grid grid-cols-7 gap-2">
            {calendarDays.map((date, index) => {
              if (!date) {
                return <div key={`empty-${index}`} className="h-9" />;
              }
              const completed = isDateCompleted(date);
              const today = isSameDay(date, new Date());
              const isCurrent = isSameMonth(date, selectedMonth);

              return (
                <div
                  key={date.toISOString()}
                  className={`flex h-9 w-9 items-center justify-center rounded-full text-[14px] ${
                    completed
                      ? "bg-success text-white"
                      : today
                        ? "bg-neutral/30"
                        : "bg-neutral/15"
                  } ${isCurrent ? "text-text" : "text-text/30"}`}
                >
                  {date.getDate()}
                </div>
              );
            })}
          </div>
        </div>

        <div className="card rounded-card p-6">
          <h2 className="text-[20px] font-medium">Habit Breakdown</h2>
          <div className="mt-4 flex flex-col gap-2">
            {habits.map((habit) => (
              <HabitRow key={habit.id} habit={habit} now={now} />
            ))}
          </div>
        </div>
      </main>

      <BottomNav />
    </div>
  );
}

function HabitRow({ habit, now }: { habit: HabitWithCompletions; now: number }) {
  const streak = currentStreak(habit, now);

  return (
    <div className="flex items-center gap-4">
      <span className="text-[28px]" aria-hidden="true">
        {habit.emoji}
      </span>
      <div className="flex-1">
        <div className="text-[16px] font-medium">{habit.name}</div>
        <div className="text-[12px] text-text/60">
          {habit.completions.length} completions • {streak} day streak
        </div>
      </div>
      {streak > 0 ? (
        <span className="text-[24px] text-success" aria-hidden="true">
          ✔
        </span>
      ) : null}
    </div>
  );
}
