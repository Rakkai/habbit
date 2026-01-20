"use client";

type StreakBadgeProps = {
  count: number;
  emoji: string;
};

export function StreakBadge({ count, emoji }: StreakBadgeProps) {
  return (
    <div className="badge text-[18px]">
      <span className="font-medium">{count}</span>
      <span className="text-[24px] leading-none">{emoji}</span>
    </div>
  );
}
