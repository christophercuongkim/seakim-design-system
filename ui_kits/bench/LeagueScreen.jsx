import React from 'react';
import { Avatar } from '../../components/core/Avatar.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Table } from '../../components/data/Table.jsx';
import { SegmentedControl } from '../../components/forms/SegmentedControl.jsx';
import { SectionLabel, pagePad } from './BenchShell.jsx';
import { STANDINGS } from './roster.js';

/* Standings, expressed as a column definition over the shared Table.

   This was the last hand-rolled table in the kits — the pattern decision 0003 was
   written to replace. What stays here is the part that is genuinely Bench's: which
   columns drop first, and that the user's own row is the one accent in the table. */

const MY_TEAM = 'Bench Warmers';

function TeamCell(row) {
  const mine = row.team === MY_TEAM;
  return (
    <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)', minWidth: 0 }}>
      <Avatar name={row.team} size="sm" />
      <span style={{
        font: 'var(--type-label)', fontSize: 'var(--text-sm)',
        color: mine ? 'var(--text-accent)' : 'var(--text-primary)',
        whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
      }}>{row.team}</span>
      {mine && <Badge tone="accent">You</Badge>}
    </span>
  );
}

export function LeagueScreen({ bp }) {
  const isSm = bp === 'sm';

  const rows = STANDINGS.map(([rank, team, record, pointsFor, differential]) => ({
    rank, team, record, pointsFor, differential,
  }));

  const columns = [
    {
      key: 'rank', label: '#', width: 40, sortable: false,
      render: r => <span style={{ font: 'var(--type-data)', color: 'var(--text-tertiary)' }}>{r.rank}</span>,
    },
    { key: 'team', label: 'Team', identifying: true, render: TeamCell },
    { key: 'record', label: 'Record', numeric: true, survives: true, secondary: r => r.record },
    // Points for and differential are the two widest columns and the least urgent:
    // they drop at md rather than the type shrinking.
    { key: 'pointsFor', label: 'Points for', numeric: true, priority: 3 },
    {
      key: 'differential', label: 'Differential', numeric: true, priority: 3,
      render: r => (
        <span style={{ color: r.differential.startsWith('-') ? 'var(--text-danger)' : 'var(--text-success)' }}>
          {r.differential}
        </span>
      ),
    },
  ];

  return (
    <div style={{ padding: pagePad(bp), display: 'flex', flexDirection: 'column', gap: isSm ? 0 : 'var(--space-6)' }}>
      <div style={{
        display: 'flex', alignItems: isSm ? 'stretch' : 'center', gap: 'var(--space-4)',
        flexDirection: isSm ? 'column' : 'row', flexWrap: 'wrap',
        padding: isSm ? 'var(--space-5)' : 0,
        borderBottom: isSm ? '1px solid var(--border-subtle)' : 'none',
      }}>
        <SectionLabel meta={isSm ? undefined : 'East · 6 teams · week 14'}>Standings</SectionLabel>
        <div style={{ marginLeft: isSm ? 0 : 'auto' }}>
          <SegmentedControl
            size="sm"
            fullWidth={isSm}
            options={isSm ? ['Standings', 'Trades'] : ['Standings', 'Transactions', 'Draft board']}
          />
        </div>
      </div>

      <Table
        columns={columns}
        rows={rows}
        bp={bp}
        rowKey={r => r.team}
        selectedKey={MY_TEAM}
        caption="League standings, East division, week 14"
      />
    </div>
  );
}
