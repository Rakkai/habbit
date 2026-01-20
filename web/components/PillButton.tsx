"use client";

type PillButtonProps = {
  title: string;
  icon?: string;
  onClick: () => void;
};

export function PillButton({ title, icon, onClick }: PillButtonProps) {
  return (
    <button className="pill-button w-full justify-center" onClick={onClick} type="button">
      {icon ? (
        <span className="text-[20px] leading-none" aria-hidden="true">
          {icon}
        </span>
      ) : null}
      <span>{title}</span>
    </button>
  );
}
