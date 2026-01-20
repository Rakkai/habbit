"use client";

type StatCardProps = {
  title: string;
  value: string;
  icon: string;
};

export function StatCard({ title, value, icon }: StatCardProps) {
  return (
    <div className="card flex flex-1 flex-col items-center gap-2 p-5 text-center">
      <div className="text-[32px] leading-none">{icon}</div>
      <div className="text-[28px] font-bold text-text">{value}</div>
      <div className="text-[14px] text-text/60">{title}</div>
    </div>
  );
}
