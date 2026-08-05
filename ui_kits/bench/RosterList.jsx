import React from 'react';
import { Avatar } from '../../components/core/Avatar.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';
import { Tooltip } from '../../components/feedback/Tooltip.jsx';
import { Table } from '../../components/data/Table.jsx';

/* Bench's roster, expressed as a column definition over the shared Table.
   This used to be a hand-rolled table plus a hand-rolled list row — the pattern
   that decision 0003 was written to replace. The species swap at sm now comes
   from Table itself, so there is one implementation instead of two.

   What stays here is the part that is genuinely Bench's: which columns matter,
   which figure survives to sm, and how a player is drawn. */

function PlayerCell(p) {
  return (
    <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
      <Avatar name={p.name} size="sm" status={p.status} />
      <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.name}</span>
      {p.flag && (
        <Badge tone={p.flag === 'OUT' ? 'danger' : p.flag === 'Q' ? 'warning' : 'neutral'}>{p.flag}</Badge>
      )}
    </span>
  );
}

/**
 * @param bp        measured breakpoint — Table decides list vs table from it
 * @param liveLabel header for the points column
 */
export function RosterList({ bp, rows, onOpen, actions, liveLabel = 'Live', showOwned = true, dense = false }) {
  const columns = [
    { key: 'slot', label: 'Slot', width: 48, sortable: false, cell: p => p.slot },
    { key: 'name', label: 'Player', identifying: true, render: PlayerCell },
    {
      key: 'matchup', label: 'Matchup', priority: 3, secondary: true,
      render: p => `${p.pos} · ${p.team} · ${p.matchup}`,
    },
    {
      key: 'points', label: liveLabel, numeric: true, survives: true,
      subLabel: p => `proj ${p.proj}`,
    },
    { key: 'proj', label: 'Proj', numeric: true, priority: 3 },
    ...(showOwned ? [{ key: 'own', label: 'Owned', numeric: true, priority: 3 }] : []),
  ];

  return (
    <Table
      columns={columns}
      rows={rows}
      bp={bp}
      density={dense ? 'compact' : 'comfortable'}
      rowKey={p => p.name + p.slot}
      onSelectRow={onOpen}
      caption="Roster"
      actions={actions ? (p => actions(p)) : (p => (
        <>
          <Tooltip label="Swap player" side="left">
            <IconButton icon="arrows-left-right" label={`Swap ${p.name}`} size="sm" />
          </Tooltip>
          <Tooltip label="Drop" side="left">
            <IconButton icon="trash" label={`Drop ${p.name}`} size="sm" />
          </Tooltip>
        </>
      ))}
    />
  );
}

/**
 * A single tappable player row, for lists that are not tables — the free-agent
 * search results and anywhere a roster row appears outside a column layout.
 */
export function PlayerRow({ p, onPress, trailing, dense = false }) {
  return (
    <button
      type="button"
      onClick={onPress}
      style={{
        width: '100%', display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
        minHeight: 'var(--control-h-touch)',
        padding: dense ? 'var(--space-3) var(--space-5)' : 'var(--space-4) var(--space-5)',
        background: 'transparent', border: 'none', borderTop: '1px solid var(--border-subtle)',
        textAlign: 'left', cursor: 'pointer', color: 'inherit',
      }}
    >
      <span style={{ width: 30, flex: 'none', font: 'var(--type-eyebrow)', color: 'var(--text-tertiary)', letterSpacing: 'var(--tracking-wide)' }}>{p.slot}</span>
      <Avatar name={p.name} size="md" status={p.status} />
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
          <span style={{ font: 'var(--type-label)', fontSize: 'var(--text-md)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.name}</span>
          {p.flag && <Badge tone={p.flag === 'OUT' ? 'danger' : p.flag === 'Q' ? 'warning' : 'neutral'}>{p.flag}</Badge>}
        </span>
        <span style={{ display: 'block', font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>
          {p.pos} · {p.team} · {p.matchup}
        </span>
      </span>
      {trailing || (
        <span style={{ textAlign: 'right', flex: 'none' }}>
          <span style={{
            display: 'block', fontFamily: 'var(--font-mono)', fontSize: 'var(--text-lg)',
            fontWeight: 'var(--weight-medium)', fontVariantNumeric: 'tabular-nums', lineHeight: 1.1,
          }}>{p.points}</span>
          <span style={{ display: 'block', font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>proj {p.proj}</span>
        </span>
      )}
      <Icon name="caret-right" size={14} style={{ color: 'var(--text-tertiary)', flex: 'none' }} />
    </button>
  );
}
