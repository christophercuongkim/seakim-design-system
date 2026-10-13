import {
  Avatar,
  Badge,
  Button,
  Card,
  DatePicker,
  Disclosure,
  EmptyState,
  Field,
  Icon,
  Input,
  ListGroup,
  ListRow,
  PageHeader,
  Progress,
  Slider,
  SplitPane,
  SplitPaneHeader,
  Stat,
  Stepper,
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

      <Section title="PageHeader">
        <div style={{ width: "100%" }}>
          <PageHeader
            title="Roster"
            badge={<Badge mono>12</Badge>}
            description="Everyone on the bench this week."
          />
        </div>
      </Section>
      <Section title="ListRow">
        <div style={{ width: 360 }}>
          <ListGroup heading="Roster">
            <ListRow
              leading={<Avatar name="Dana Okafor" size="sm" />}
              eyebrow="PG · ATL"
              title="Dana Okafor"
              meta="vs MIA tonight"
              trailing="24.6"
              selected
              href="#okafor"
            />
            <ListRow
              leading={<Avatar name="Theo Lindqvist" size="sm" />}
              eyebrow="SG · BOS"
              title="Theo Lindqvist"
              meta="@ NYK tonight"
              trailing="11.2"
              href="#lindqvist"
            />
          </ListGroup>
        </div>
      </Section>
      <Section title="SplitPane">
        <div style={{ width: "100%", height: 240 }}>
          <SplitPane
            listWidth="14rem"
            list={
              <ListGroup heading="Roster">
                <ListRow title="Dana Okafor" meta="PG · ATL" trailing="24.6" selected href="#okafor" />
                <ListRow title="Theo Lindqvist" meta="SG · BOS" trailing="11.2" href="#lindqvist" />
              </ListGroup>
            }
            detail={
              <>
                <SplitPaneHeader title="Dana Okafor" counter="1 of 2" />
                <p style={{ padding: "var(--space-6)", font: "var(--type-body-sm)", color: "var(--text-secondary)" }}>
                  vs MIA tonight. Projected 18.4, live 24.6.
                </p>
              </>
            }
          />
        </div>
      </Section>
      <Section title="Stepper">
        <div style={{ width: "100%" }}>
          <Stepper
            current="recruiter"
            orientation="horizontal"
            steps={[
              { key: "applied", label: "Applied" },
              { key: "recruiter", label: "Recruiter screen" },
              { key: "onsite", label: "Onsite" },
              { key: "offer", label: "Offer" },
            ]}
          />
        </div>
      </Section>
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

      <Section title="Progress">
        <div style={{ width: 320 }}>
          <Progress value={4} max={13} label="4 of 13" />
        </div>
      </Section>
      <Section title="Disclosure">
        <div style={{ width: 320 }}>
          <Disclosure summary="Fare breakdown" meta="4 items">
            <p style={{ font: "var(--type-body-sm)", color: "var(--text-secondary)" }}>
              Base fare $312 · Taxes $86 · Seat $14 · Bag $0
            </p>
          </Disclosure>
        </div>
      </Section>
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
