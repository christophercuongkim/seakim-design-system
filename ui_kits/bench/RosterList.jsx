import React, { useState } from 'react';
import { Avatar } from '../../components/core/Avatar.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';
import { Tooltip } from '../../components/feedback/Tooltip.jsx';

/* The same roster data renders two ways. This is the core responsive move in
   Bench: at sm a player is a tappable row with a chevron; from md up it is a
   table row with hover-revealed actions and extra columns. */

const TH = {
  font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)',
  color: 'var(--text-tertiary)', padding: 'var(--space-4) var(--space-5)', textAlign: 'left',
  borderBottom: '1px solid var(--border-subtle)', whiteSpace: 'nowrap',
};
const TD = {
  padding: 'var(--space-4) var(--space-5)', borderBottom: '1px solid var(--border-subtle)',
  font: 'var(--type-body-sm)', verticalAlign: 'middle',
};
const NUM = { ...TD, fontFamily: 'var(--font-mono)', fontVariantNumeric: 'tabular-nums', textAlign: 'right' };

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

function TableRow({ p, onOpen, actions, showOwned }) {
  const [hover, setHover] = useState(false);
  return (
    <tr
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{ background: hover ? 'var(--surface-hover)' : 'transparent', transition: 'var(--transition-surface)' }}
    >
      <td style={{ ...TD, font: 'var(--type-eyebrow)', color: 'var(--text-tertiary)', letterSpacing: 'var(--tracking-wide)' }}>{p.slot}</td>
      <td style={TD}>
        <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
          <Avatar name={p.name} size="sm" status={p.status} />
          <button
            type="button"
            onClick={() => onOpen(p)}
            style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer', font: 'var(--type-label)', fontSize: 'var(--text-sm)', color: 'var(--text-primary)' }}
          >{p.name}</button>
          {p.flag && <Badge tone={p.flag === 'OUT' ? 'danger' : 'warning'}>{p.flag}</Badge>}
        </span>
      </td>
      <td style={{ ...TD, color: 'var(--text-secondary)', whiteSpace: 'nowrap' }}>{p.pos} · {p.team} · {p.matchup}</td>
      <td style={{ ...NUM, fontSize: 'var(--text-md)' }}>{p.points}</td>
      <td style={{ ...NUM, color: 'var(--text-secondary)' }}>{p.proj}</td>
      {showOwned && <td style={{ ...NUM, color: 'var(--text-tertiary)' }}>{p.own}</td>}
      <td style={{ ...TD, textAlign: 'right', width: 96 }}>
        {actions ? actions(p) : (
          <span style={{ display: 'inline-flex', gap: 'var(--space-3)', opacity: hover ? 1 : 0, transition: 'opacity var(--dur-fast) var(--ease-out)' }}>
            <Tooltip label="Swap player" side="left"><IconButton icon="arrows-left-right" label="Swap player" size="sm" /></Tooltip>
            <Tooltip label="Drop" side="left"><IconButton icon="trash" label="Drop player" size="sm" /></Tooltip>
          </span>
        )}
      </td>
    </tr>
  );
}

/**
 * @param bp        measured breakpoint — decides list vs table
 * @param rows      roster rows
 * @param liveLabel header for the points column
 */
export function RosterList({ bp, rows, onOpen, actions, liveLabel = 'Live', showOwned = true, dense = false }) {
  if (bp === 'sm') {
    return (
      <div>
        {rows.map(p => (
          <PlayerRow
            key={p.name + p.slot}
            p={p}
            dense={dense}
            onPress={() => onOpen(p)}
            trailing={actions ? actions(p) : undefined}
          />
        ))}
      </div>
    );
  }
  const owned = showOwned && bp === 'lg';
  return (
    <div style={{ border: '1px solid var(--border-subtle)', overflowX: 'auto' }}>
      <table style={{ width: '100%', borderCollapse: 'collapse', background: 'var(--surface-card)' }}>
        <thead>
          <tr>
            <th style={{ ...TH, width: 48 }}>Slot</th>
            <th style={TH}>Player</th>
            <th style={TH}>Matchup</th>
            <th style={{ ...TH, textAlign: 'right' }}>{liveLabel}</th>
            <th style={{ ...TH, textAlign: 'right' }}>Proj</th>
            {owned && <th style={{ ...TH, textAlign: 'right' }}>Owned</th>}
            <th style={{ ...TH, width: 96 }}></th>
          </tr>
        </thead>
        <tbody>
          {rows.map(p => (
            <TableRow key={p.name + p.slot} p={p} onOpen={onOpen} actions={actions} showOwned={owned} />
          ))}
        </tbody>
      </table>
    </div>
  );
}
