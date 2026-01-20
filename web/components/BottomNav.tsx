"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { href: "/habits", label: "Habits", icon: "⭕" },
  { href: "/dashboard", label: "Dashboard", icon: "📊" },
  { href: "/profile", label: "Profile", icon: "👤" }
];

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="navbar">
      {navItems.map((item) => (
        <Link key={item.href} href={item.href} className={pathname === item.href ? "active" : ""}>
          <span>{item.icon}</span>
          <span>{item.label}</span>
        </Link>
      ))}
    </nav>
  );
}
