"use client";

import type { HabitState } from "../lib/habitLogic";

const COLORS: Record<HabitState, { stroke: string; track: string; fill: string }> = {
  frozen: {
    stroke: "var(--color-icy)",
    track: "rgba(125, 211, 252, 0.3)",
    fill: "rgba(125, 211, 252, 0.2)"
  },
  gracePeriod: {
    stroke: "var(--color-danger)",
    track: "rgba(217, 217, 217, 0.3)",
    fill: "rgba(212, 66, 77, 0.15)"
  },
  onTrack: {
    stroke: "var(--color-success)",
    track: "rgba(217, 217, 217, 0.3)",
    fill: "rgba(57, 212, 92, 0.15)"
  },
  streakLost: {
    stroke: "var(--color-neutral)",
    track: "rgba(217, 217, 217, 0.3)",
    fill: "transparent"
  }
};

type CircularProgressProps = {
  progress: number;
  state: HabitState;
  size?: number;
  strokeWidth?: number;
};

export function CircularProgress({ progress, state, size = 100, strokeWidth = 6 }: CircularProgressProps) {
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference * (1 - Math.max(0, Math.min(1, progress)));
  const colors = COLORS[state];
  const fillColor =
    state === "frozen"
      ? colors.fill
      : state === "streakLost"
        ? "transparent"
        : progress > 0
          ? colors.fill
          : "transparent";

  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <circle
        cx={size / 2}
        cy={size / 2}
        r={radius}
        stroke={colors.track}
        strokeWidth={strokeWidth}
        fill="none"
      />
      <circle
        cx={size / 2}
        cy={size / 2}
        r={radius}
        stroke={colors.stroke}
        strokeWidth={strokeWidth}
        strokeLinecap="round"
        fill="none"
        strokeDasharray={circumference}
        strokeDashoffset={offset}
        transform={`rotate(-90 ${size / 2} ${size / 2}) scale(-1 1) translate(-${size} 0)`}
        style={{ transition: "stroke-dashoffset 0.3s ease" }}
      />
      <circle
        cx={size / 2}
        cy={size / 2}
        r={radius - strokeWidth / 2}
        fill={fillColor}
      />
    </svg>
  );
}
