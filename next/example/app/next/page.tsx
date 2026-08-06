import {
  Avatar,
  Badge,
  Button,
  Card,
  DatePicker,
  EmptyState,
  Field,
  Icon,
  Input,
  Slider,
  Stat,
  Tag,
} from "@seakim/design-system";

import { RosterTable } from "./roster-table";

/**
 * Deliberately a Server Component.
 *
 * That is the whole point of the exercise: `next/lib/seakim.ts` carries the only
 * `"use client"` in the system, so a page like this one should be able to import
 * stateful components without becoming a Client Component itself. If that
 * boundary were wrong, this file would not build.
 *
 * Nothing here passes an event handler, for the same reason — a Server Component
 * cannot. Interactivity is the app's job; this proves the wiring.
 */

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section style={{ marginBottom: "var(--space-9)" }}>
      <p
        style={{
          font: "var(--text-eyebrow)",
          color: "var(--text-tertiary)",
          textTransform: "uppercase",
          marginBottom: "var(--space-4)",
        }}
      >
        {title}
      </p>
      <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-4)" }}>
        {children}
      </div>
    </section>
  );
}

export default function Page() {
  return (
    <main
      style={{
        maxWidth: 880,
        margin: "0 auto",
        padding: "var(--space-9) var(--space-6)",
      }}
    >
      <h1 style={{ font: "var(--text-title)", marginBottom: "var(--space-8)" }}>
        SeaKim in Next.js
      </h1>

      <Section title="Actions">
        <Button variant="primary">Book trip</Button>
        <Button variant="secondary">Hold</Button>
        <Button variant="ghost">Cancel</Button>
        <Button variant="danger">Delete trip</Button>
        <Button variant="primary" iconLeft="map-pin">
          Add leg
        </Button>
      </Section>

      <Section title="Status">
        <Badge tone="success">Confirmed</Badge>
        <Badge tone="warning" variant="solid">
          Hold expires
        </Badge>
        <Badge tone="danger">Cancelled</Badge>
        <Tag>Direct</Tag>
        <Avatar name="Okafor" />
        <Icon name="airplane-takeoff" />
      </Section>

      <Section title="Data">
        <Card style={{ padding: "var(--space-5)" }}>
          <Stat label="Fare" value="412" unit="USD" delta="-18" />
        </Card>
      </Section>

      <div style={{ marginBottom: "var(--space-9)" }}>
        <RosterTable />
      </div>

      <Section title="Forms">
        <div style={{ minWidth: 260 }}>
          <Field label="Destination" hint="City or airport">
            <Input placeholder="Where to?" />
          </Field>
        </div>
        <div style={{ minWidth: 260 }}>
          <Slider value={40} label="Budget" />
        </div>
        <div style={{ minWidth: 260 }}>
          <DatePicker label="Depart" />
        </div>
      </Section>

      <EmptyState
        title="No saved trips yet"
        description="Trips you save appear here, across every device."
      />
    </main>
  );
}
