"use client";

import Link from "next/link";

type SettingsLinkProps = {
  href: string;
  icon: string;
  title: string;
};

export function SettingsLink({ href, icon, title }: SettingsLinkProps) {
  return (
    <Link
      href={href}
      className="flex w-full items-center gap-4 px-4 py-4 text-left text-[16px] text-text"
    >
      <span className="text-[18px] text-success">{icon}</span>
      <span className="flex-1">{title}</span>
      <span className="text-[14px] text-text/30">›</span>
    </Link>
  );
}
