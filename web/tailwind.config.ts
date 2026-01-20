import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./lib/**/*.{ts,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["var(--font-pt-sans)", "system-ui", "sans-serif"]
      },
      colors: {
        background: "var(--color-background)",
        card: "var(--color-card)",
        text: "var(--color-text)",
        success: "var(--color-success)",
        danger: "var(--color-danger)",
        neutral: "var(--color-neutral)",
        icy: "var(--color-icy)",
        icyDark: "var(--color-icy-dark)"
      },
      boxShadow: {
        soft: "0 4px 12px rgba(0, 0, 0, 0.05)",
        softSm: "0 2px 8px rgba(0, 0, 0, 0.05)"
      },
      borderRadius: {
        card: "24px",
        pill: "9999px",
        tile: "45px"
      }
    }
  },
  plugins: []
};

export default config;
