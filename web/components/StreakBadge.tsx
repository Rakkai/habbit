"use client";

type StreakBadgeProps = {
  count: number;
  emoji: string;
};

export function StreakBadge({ count, emoji }: StreakBadgeProps) {
  return (
    <div className="badge text-base">
      <span className="font-medium">{count}</span>
      <span className="text-xl">{emoji}</span>
    </div>
  );
}
