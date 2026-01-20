import type { Metadata } from "next";
import { PT_Sans } from "next/font/google";

import "./globals.css";
import { Providers } from "./providers";

const ptSans = PT_Sans({
  subsets: ["latin"],
  weight: ["400", "700"],
  variable: "--font-pt-sans"
});

export const metadata: Metadata = {
  title: "Habbit",
  description: "A personal habit tracker for the web."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={ptSans.variable}>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
