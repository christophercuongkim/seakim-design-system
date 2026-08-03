"use client";

import { Button, Field, Input, Stat, Card, Badge, useSkTheme } from "@/lib/seakim";

/**
 * Smallest possible proof that the wiring works: tokens resolving, fonts loaded,
 * icons rendering, theme toggling, and no hydration warning in the console.
 *
 * Note the styling approach — inline styles reading CSS custom properties, exactly
 * as the rest of the system does. There is no Tailwind and no CSS module here on
 * purpose: semantic tokens already carry the theme and app switching.
 */
export default function Page() {
  const { theme, toggleTheme } = useSkTheme();

  return (
    <main
      style={{
        minHeight: "100vh",
        padding: "var(--space-11) var(--space-6)",
        display: "flex",
        flexDirection: "column",
        gap: "var(--space-8)",
        maxWidth: 720,
        margin: "0 auto",
      }}
    >
      <header style={{ display: "flex", alignItems: "flex-end", gap: "var(--space-5)" }}>
        <div style={{ flex: 1 }}>
          <div
            style={{
              font: "var(--type-eyebrow)",
              textTransform: "uppercase",
              letterSpacing: "var(--tracking-caps)",
              color: "var(--text-tertiary)",
            }}
          >
            SeaKim · Next.js
          </div>
          <h1
            style={{
              font: "var(--type-title)",
              letterSpacing: "var(--tracking-tighter)",
              marginTop: "var(--space-3)",
            }}
          >
            Wiring check
          </h1>
        </div>
        <Button variant="secondary" size="sm" iconLeft={theme === "dark" ? "sun" : "moon"} onClick={toggleTheme}>
          {theme === "dark" ? "Light" : "Dark"}
        </Button>
      </header>

      <div style={{ display: "flex", gap: "var(--space-9)" }}>
        <Stat label="Total fare" value="$412" hint="2 travellers, taxes in" />
        <Stat label="Projected" value="18.4" unit="pts" delta="+2.1" />
      </div>

      <Card title="Hotel Baixa" eyebrow="15–18 Mar · 3 nights" meta="Rua dos Fanqueiros 12, Lisbon">
        <p style={{ font: "var(--type-body-sm)", color: "var(--text-secondary)" }}>
          Double room, city view. Free cancellation until 12 Mar.
        </p>
      </Card>

      <Field label="Where to" hint="City or airport code" htmlFor="dest">
        <Input id="dest" iconLeft="magnifying-glass" placeholder="Lisbon, LIS" />
      </Field>

      <div style={{ display: "flex", alignItems: "center", gap: "var(--space-4)" }}>
        <Badge tone="success" dot>
          Confirmed
        </Badge>
        <Button iconRight="arrow-right">Continue</Button>
      </div>
    </main>
  );
}
