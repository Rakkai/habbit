"use client";

import { useEffect, useMemo, useState } from "react";

import { Modal } from "./Modal";
import { db } from "../lib/db";
import type { HabitWithCompletions } from "../lib/types";

const suggestedEmojis = [
  "🧘",
  "💪",
  "🏃",
  "🚴",
  "📚",
  "💧",
  "🥗",
  "😴",
  "✍️",
  "🎨",
  "🎹",
  "🧠",
  "🌱",
  "❄️",
  "🎯",
  "⭐"
];

const cadencePresets = [
  { label: "Daily", hours: 24 },
  { label: "Every 2 days", hours: 48 },
  { label: "Twice a week", hours: 84 },
  { label: "Weekly", hours: 168 }
];

type AddEditHabitModalProps = {
  habit: HabitWithCompletions | null;
  isOpen: boolean;
  onClose: () => void;
};

export function AddEditHabitModal({ habit, isOpen, onClose }: AddEditHabitModalProps) {
  const isEditing = Boolean(habit);
  const [name, setName] = useState("");
  const [selectedEmoji, setSelectedEmoji] = useState("🎯");
  const [selectedCadence, setSelectedCadence] = useState(cadencePresets[0]);
  const [customCadence, setCustomCadence] = useState(24);
  const [useCustomCadence, setUseCustomCadence] = useState(false);
  const [testMode, setTestMode] = useState(false);

  useEffect(() => {
    if (!isOpen) {
      return;
    }
    setName(habit?.name ?? "");
    setSelectedEmoji(habit?.emoji ?? "🎯");
    setSelectedCadence(
      cadencePresets.find((preset) => preset.hours === habit?.cadenceHours) ?? cadencePresets[0]
    );
    setCustomCadence(habit?.cadenceHours && habit.cadenceHours > 0 ? habit.cadenceHours : 24);
    setUseCustomCadence(
      habit ? !cadencePresets.some((preset) => preset.hours === habit.cadenceHours) : false
    );
    setTestMode(habit?.cadenceHours ? habit.cadenceHours < 0 : false);
  }, [habit, isOpen]);

  const cadenceHours = useMemo(() => {
    if (testMode) {
      return -30;
    }
    return useCustomCadence ? customCadence : selectedCadence.hours;
  }, [testMode, useCustomCadence, customCadence, selectedCadence]);

  const canSave = name.trim().length > 0;

  async function handleSave() {
    if (!canSave) {
      return;
    }

    if (habit) {
      await db.habits.update(habit.id, {
        name: name.trim(),
        emoji: selectedEmoji,
        cadenceHours
      });
    } else {
      const allHabits = await db.habits.toArray();
      const maxSortOrder = allHabits.reduce((max, item) => Math.max(max, item.sortOrder), -1);
      await db.habits.add({
        id: crypto.randomUUID(),
        name: name.trim(),
        emoji: selectedEmoji,
        createdAt: Date.now(),
        isArchived: false,
        sortOrder: maxSortOrder + 1,
        cadenceHours,
        isFrozen: false,
        frozenAt: null,
        lastAwardedMilestone: 0
      });
    }
    onClose();
  }

  async function handleDelete() {
    if (!habit) {
      return;
    }
    await db.completions.where("habitId").equals(habit.id).delete();
    await db.habits.delete(habit.id);
    onClose();
  }

  function formatCadence(hours: number) {
    if (hours < 0) {
      return `${Math.abs(hours)} seconds`;
    }
    if (hours < 24) {
      return `${hours} hours`;
    }
    if (hours === 24) {
      return "24 hours";
    }
    if (hours % 24 === 0) {
      const days = hours / 24;
      return `${days} day${days > 1 ? "s" : ""}`;
    }
    const days = Math.floor(hours / 24);
    const remainingHours = hours % 24;
    return `${days}d ${remainingHours}h`;
  }

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={isEditing ? "Edit Habit" : "New Habit"}>
      <div className="flex flex-col gap-6">
        <div className="flex flex-col items-center gap-4">
          <div className="flex h-[90px] w-[90px] items-center justify-center rounded-full bg-card text-[56px] shadow-soft">
            {selectedEmoji}
          </div>
          <fieldset className="grid grid-cols-8 gap-2.5" aria-label="Pick an emoji">
            {suggestedEmojis.map((emoji) => (
              <button
                key={emoji}
                type="button"
                className={`flex h-9 w-9 items-center justify-center rounded-full text-[24px] ${
                  selectedEmoji === emoji ? "bg-success/20" : "bg-transparent"
                }`}
                onClick={() => setSelectedEmoji(emoji)}
                aria-pressed={selectedEmoji === emoji}
              >
                <span aria-hidden="true">{emoji}</span>
                <span className="sr-only">Select {emoji}</span>
              </button>
            ))}
          </fieldset>
        </div>

        <div>
          <label htmlFor="habit-name" className="text-[14px] text-text/60">
            Habit Name
          </label>
          <input
            id="habit-name"
            type="text"
            value={name}
            onChange={(event) => setName(event.target.value)}
            placeholder="e.g., Meditation"
          />
        </div>

        <div className="flex flex-col gap-3">
          <label className="text-[14px] text-text/60" id="cadence-label">
            How often?
          </label>
          <div className="flex flex-col gap-2" role="radiogroup" aria-labelledby="cadence-label">
            {cadencePresets.map((preset) => (
              <button
                key={preset.label}
                type="button"
                onClick={() => {
                  setSelectedCadence(preset);
                  setUseCustomCadence(false);
                }}
                className="flex items-center justify-between rounded-xl bg-card px-4 py-3.5 text-left"
                role="radio"
                aria-checked={!useCustomCadence && selectedCadence.label === preset.label}
              >
                <div>
                  <div className="text-[16px] font-medium text-text">{preset.label}</div>
                  <div className="text-[13px] text-text/50">{formatCadence(preset.hours)}</div>
                </div>
                <div
                  className={`flex h-[22px] w-[22px] items-center justify-center rounded-full border-2 ${
                    !useCustomCadence && selectedCadence.label === preset.label
                      ? "border-success"
                      : "border-neutral"
                  }`}
                >
                  {!useCustomCadence && selectedCadence.label === preset.label ? (
                    <div className="h-[12px] w-[12px] rounded-full bg-success" />
                  ) : null}
                </div>
              </button>
            ))}

            <button
              type="button"
              onClick={() => setUseCustomCadence(true)}
              className="flex items-center justify-between rounded-xl bg-card px-4 py-3.5 text-left"
              role="radio"
              aria-checked={useCustomCadence}
            >
              <div>
                <div className="text-[16px] font-medium text-text">Custom</div>
                <div className="text-[13px] text-text/50">
                  {useCustomCadence ? formatCadence(customCadence) : "Set your own"}
                </div>
              </div>
              <div
                className={`flex h-[22px] w-[22px] items-center justify-center rounded-full border-2 ${
                  useCustomCadence ? "border-success" : "border-neutral"
                }`}
              >
                {useCustomCadence ? <div className="h-[12px] w-[12px] rounded-full bg-success" /> : null}
              </div>
            </button>
          </div>

          {useCustomCadence ? (
            <div className="flex items-center gap-3 rounded-xl bg-card px-4 py-3.5">
              <label htmlFor="custom-cadence" className="text-[16px]">
                Every
              </label>
              <input
                id="custom-cadence"
                type="number"
                min={1}
                max={336}
                value={customCadence}
                onChange={(event) => setCustomCadence(Number(event.target.value))}
                className="max-w-[120px]"
                inputMode="numeric"
              />
              <span className="text-[16px]">hours</span>
            </div>
          ) : null}

          <label htmlFor="test-mode" className="flex items-center gap-3 text-[14px] text-text/60">
            <input
              id="test-mode"
              type="checkbox"
              checked={testMode}
              onChange={() => setTestMode((prev) => !prev)}
            />
            <span>Test Mode (30 sec)</span>
          </label>
        </div>

        <div className="flex flex-col gap-3">
          <button className="primary-button" onClick={handleSave} disabled={!canSave} type="button">
            {isEditing ? "Save Changes" : "Create Habit"}
          </button>
          {isEditing ? (
            <button className="secondary-button text-danger" onClick={handleDelete} type="button">
              Delete Habit
            </button>
          ) : null}
        </div>
      </div>
    </Modal>
  );
}
