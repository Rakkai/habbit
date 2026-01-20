"use client";

type SettingsRowProps = {
  icon: string;
  title: string;
  onClick: () => void;
  showChevron?: boolean;
};

export function SettingsRow({ icon, title, onClick, showChevron = true }: SettingsRowProps) {
  return (
    <button
      onClick={onClick}
      className="flex w-full items-center gap-4 px-4 py-3 text-left text-base text-text"
    >
      <span className="text-success">{icon}</span>
      <span className="flex-1">{title}</span>
      {showChevron ? <span className="text-text/40">›</span> : null}
    </button>
  );
}
