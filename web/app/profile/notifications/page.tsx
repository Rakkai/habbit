"use client";

import Link from "next/link";

import { BottomNav } from "../../../components/BottomNav";
import { useRequireWelcome, useSettings } from "../../../lib/hooks";

export default function NotificationsPage() {
  const { settings } = useSettings();

  useRequireWelcome(settings);

  return (
    <div className="min-h-screen bg-background">
      <main className="container flex flex-col items-center gap-4 text-center">
        <div className="flex w-full items-center justify-between">
          <h1 className="text-xl font-semibold">Notifications</h1>
          <Link href="/profile" className="text-sm text-success">
            Done
          </Link>
        </div>
        <div className="card rounded-card p-10">
          <div className="text-6xl" aria-hidden="true">
            🔔
          </div>
          <h2 className="mt-4 text-xl font-semibold">Coming soon...</h2>
          <p className="mt-2 text-sm text-text/60">
            Push notifications will be available in a future update.
          </p>
        </div>
      </main>
      <BottomNav />
    </div>
  );
}
