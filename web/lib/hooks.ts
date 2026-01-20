"use client";

import { useEffect, useMemo, useState } from "react";
import { useLiveQuery } from "dexie-react-hooks";
import { useRouter } from "next/navigation";

import { db, getSettings, updateSettings } from "./db";
import type { AppSettings, HabitCompletion, HabitWithCompletions } from "./types";

export function useSettings() {
  const settings = useLiveQuery(() => db.settings.get("settings"));
  const [ready, setReady] = useState(false);

  useEffect(() => {
    getSettings().then(() => setReady(true));
  }, []);

  return {
    settings: settings ?? null,
    isReady: ready,
    updateSettings
  };
}

export function useHabitsWithCompletions() {
  const habits = useLiveQuery(() => db.habits.orderBy("sortOrder").toArray(), []);
  const completions = useLiveQuery(() => db.completions.toArray(), []);

  return useMemo(() => {
    if (!habits || !completions) {
      return [] as HabitWithCompletions[];
    }

    const byHabit: Record<string, HabitCompletion[]> = {};
    for (const completion of completions) {
      if (!byHabit[completion.habitId]) {
        byHabit[completion.habitId] = [];
      }
      byHabit[completion.habitId].push(completion);
    }

    return habits.map((habit) => ({
      ...habit,
      completions: byHabit[habit.id] ?? []
    }));
  }, [habits, completions]);
}

export function useAppearanceTheme(settings: AppSettings | null) {
  useEffect(() => {
    const root = document.documentElement;
    if (!settings) {
      return;
    }

    if (settings.appearanceMode === "system") {
      const media = window.matchMedia("(prefers-color-scheme: dark)");
      const applyTheme = () => {
        root.dataset.theme = media.matches ? "dark" : "light";
      };
      applyTheme();
      media.addEventListener("change", applyTheme);
      return () => media.removeEventListener("change", applyTheme);
    }

    root.dataset.theme = settings.appearanceMode;
  }, [settings]);
}

export function useRequireWelcome(settings: AppSettings | null) {
  const router = useRouter();

  useEffect(() => {
    if (settings && !settings.hasCompletedWelcome) {
      router.replace("/");
    }
  }, [settings, router]);
}
