"use client";

import { useState } from "react";

import { BottomNav } from "../../components/BottomNav";
import { SettingsLink } from "../../components/SettingsLink";
import { useRequireWelcome, useSettings } from "../../lib/hooks";

export default function ProfilePage() {
  const { settings, updateSettings } = useSettings();
  const [isEditing, setIsEditing] = useState(false);
  const [tempName, setTempName] = useState("");

  useRequireWelcome(settings);

  return (
    <div className="min-h-screen bg-background">
      <main className="container flex flex-col gap-6">
        <div className="card flex flex-col items-center gap-4 p-6 text-center">
          <div className="flex h-20 w-20 items-center justify-center rounded-full bg-card text-[44px] shadow-softSm" aria-hidden="true">
            🐰
          </div>
          {isEditing ? (
            <div className="flex items-center gap-3">
              <label htmlFor="profile-name" className="sr-only">
                Update name
              </label>
              <input
                id="profile-name"
                type="text"
                value={tempName}
                onChange={(event) => setTempName(event.target.value)}
                className="max-w-[200px] text-center text-[24px] font-medium"
              />
              <button
                onClick={async () => {
                  if (!tempName.trim()) {
                    return;
                  }
                  await updateSettings({ userName: tempName.trim() });
                  setIsEditing(false);
                }}
                className="text-success text-[24px]"
                type="button"
                aria-label="Save name"
              >
                ✔
              </button>
            </div>
          ) : (
            <button
              onClick={() => {
                setTempName(settings?.userName ?? "");
                setIsEditing(true);
              }}
              className="secondary-button flex items-center gap-2 text-[24px] font-medium"
              type="button"
            >
              {settings?.userName ?? ""}
              <span className="text-[14px]" aria-hidden="true">
                ✏️
              </span>
            </button>
          )}
        </div>

        <section className="flex flex-col gap-3">
          <h2 className="text-[18px] font-medium">General</h2>
          <div className="card overflow-hidden">
            <SettingsLink href="/profile/about" icon="📘" title="About habits" />
            <div className="h-px bg-neutral/30" />
            <SettingsLink href="/profile/feedback" icon="💬" title="Help & Feedback" />
          </div>
        </section>

        <section className="flex flex-col gap-3">
          <h2 className="text-[18px] font-medium">Settings</h2>
          <div className="card overflow-hidden">
            <SettingsLink href="/profile/notifications" icon="🔔" title="Notifications" />
            <div className="h-px bg-neutral/30" />
            <SettingsLink href="/profile/appearance" icon="🎨" title="Appearance" />
          </div>
        </section>
      </main>
      <BottomNav />
    </div>
  );
}
