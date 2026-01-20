"use client";

import Link from "next/link";

import { BottomNav } from "../../../components/BottomNav";
import { manualSections } from "../../../lib/content";
import { useRequireWelcome, useSettings } from "../../../lib/hooks";

export default function AboutHabitsPage() {
  const { settings } = useSettings();

  useRequireWelcome(settings);

  return (
    <div className="min-h-screen bg-background">
      <main className="container flex flex-col gap-6">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-semibold">The Habbit Manual</h1>
          <Link href="/profile" className="text-sm text-success">
            Done
          </Link>
        </div>
        <p className="text-sm text-text/70">
          A friendly, practical guide to building habits that actually stick.
        </p>

        <div className="flex flex-col gap-6">
          {manualSections.map((section) => (
            <div key={section.title} className="card rounded-card p-5">
              <h2 className="text-lg font-semibold">{section.title}</h2>
              <p className="mt-3 whitespace-pre-line text-sm text-text/85">{section.body}</p>
            </div>
          ))}
        </div>
      </main>

      <BottomNav />
    </div>
  );
}
