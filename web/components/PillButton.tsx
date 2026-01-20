"use client";

type PillButtonProps = {
  title: string;
  icon?: string;
  onClick: () => void;
};

export function PillButton({ title, icon, onClick }: PillButtonProps) {
  return (
    <button className="pill-button w-full justify-center text-base" onClick={onClick}>
      {icon ? <span className="text-lg">{icon}</span> : null}
      <span>{title}</span>
    </button>
  );
}
