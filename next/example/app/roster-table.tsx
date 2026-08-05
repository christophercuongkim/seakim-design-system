"use client";

import { Table } from "@/lib/seakim";

/**
 * Why this file exists — and it is not boilerplate.
 *
 * `Table` takes functions as props (`rowKey`, a column's `render`, `subLabel`),
 * and React Server Components cannot pass a function across the client boundary.
 * The barrel's `"use client"` makes the *component* a Client Component; it does
 * not make the *caller's props* serialisable.
 *
 * So any table that needs custom cell rendering has to be reached from a Client
 * Component. That is a one-line wrapper like this one, not a problem — but it is
 * the one place the RSC boundary is visible when using this system, so it is
 * worth stating rather than discovering.
 *
 * Decision 0003 requires the responsive metadata to be declared by hand per
 * column, which is why these objects are here and not derived.
 */

interface Player {
  name: string;
  team: string;
  pts: number;
  proj: number;
}

const roster: Player[] = [
  { name: "Okafor", team: "DEN", pts: 18.2, proj: 17.4 },
  { name: "Ruiz", team: "MIA", pts: 14.7, proj: 15.1 },
  { name: "Lindqvist", team: "POR", pts: 11.3, proj: 12.8 },
];

const columns = [
  { key: "name", label: "Player", identifying: true },
  { key: "team", label: "Team", secondary: true, priority: 2 as const },
  { key: "pts", label: "Pts", numeric: true, survives: true },
  {
    key: "proj",
    label: "Proj",
    numeric: true,
    priority: 3 as const,
    render: (r: Player) => r.proj.toFixed(1),
  },
];

export function RosterTable() {
  return (
    <Table<Player>
      columns={columns}
      rows={roster}
      rowKey={(r) => r.name}
      caption="Roster, points and projection"
    />
  );
}
