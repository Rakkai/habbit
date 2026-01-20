"use client";

import { ReactNode, useEffect } from "react";
import { ensureSeedData } from "../lib/seed";
import { useSettings, useAppearanceTheme } from "../lib/hooks";

export function Providers({ children }: { children: ReactNode }) {
  const { settings } = useSettings();

  useAppearanceTheme(settings);

  useEffect(() => {
    ensureSeedData();
  }, []);

  return <>{children}</>;
}
