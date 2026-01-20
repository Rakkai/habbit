"use client";

import Link from "next/link";

import { BottomNav } from "../../../components/BottomNav";
import { useRequireWelcome, useSettings } from "../../../lib/hooks";

const modes = [
  { id: "system", label: "System", icon: "📱" },
  { id: "light", label: "Light", icon: "☀️" },
  { id: "dark", label: "Dark", icon: "🌙" }
] as const;

export default function AppearancePage() {
  const { settings, updateSettings } = useSettings();

  useRequireWelcome(settings);

  return (
    <div className="min-h-screen bg-background">
      <div className="container flex flex-col gap-6">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-semibold">Appearance</h1>
          <Link href="/profile" className="text-sm text-success">
            Done
          </Link>
        </div>

        <div className="card overflow-hidden">
          {modes.map((mode, index) => (
            <div key={mode.id}>
              <button
                className="flex w-full items-center gap-4 px-4 py-3 text-left"
                onClick={() => updateSettings({ appearanceMode: mode.id })}
              >
                <span className="text-success">{mode.icon}</span>
                <span className="flex-1">{mode.label}</span>
                {settings?.appearanceMode === mode.id ? (
                  <span className="text-success">✔</span>
                ) : null}
              </button>
              {index < modes.length - 1 ? <div className="h-px bg-neutral/30" /> : null}
            </div>
          ))}
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
