"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

import { Welcome } from "../components/Welcome";
import { useSettings } from "../lib/hooks";

export default function HomePage() {
  const router = useRouter();
  const { settings, isReady, updateSettings } = useSettings();

  useEffect(() => {
    if (settings?.hasCompletedWelcome) {
      router.replace("/habits");
    }
  }, [settings, router]);

  if (!isReady || settings?.hasCompletedWelcome) {
    return <div className="min-h-screen bg-background" />;
  }

  return (
    <Welcome
      onComplete={async (name) => {
        if (!name) {
          return;
        }
        await updateSettings({ userName: name, hasCompletedWelcome: true });
        router.replace("/habits");
      }}
    />
  );
}
