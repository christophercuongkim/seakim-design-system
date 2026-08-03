import React from 'react';
import { Button } from '../../components/core/Button.jsx';
import { Stat } from '../../components/core/Stat.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { SegmentedControl } from '../../components/forms/SegmentedControl.jsx';
import { RosterList } from './RosterList.jsx';
import { SectionLabel, pagePad } from './BenchShell.jsx';
import { STARTERS, RESERVES } from './roster.js';

const STATS = [
  { label: 'Live score', value: '79.1', delta: '+6.2' },
  { label: 'Projected', value: '94.7', hint: 'league scoring' },
  { label: 'Win probability', value: '61', unit: '%', delta: '+4' },
  { label: 'Opponent', value: '78.1', hint: 'Court Vision · 8–5' },
];

export function LineupScreen({ bp, onOpenPlayer }) {
  const isSm = bp === 'sm';
  const statCols = bp === 'lg' ? 4 : bp === 'md' ? 2 : 3;
  const shown = isSm ? STATS.slice(0, 3) : STATS;

  return (
    <div style={{ padding: pagePad(bp), display: 'flex', flexDirection: 'column', gap: isSm ? 0 : 'var(--space-7)' }}>
      <div style={{
        display: 'grid', gridTemplateColumns: `repeat(${statCols}, 1fr)`,
        background: 'var(--surface-card)',
        border: isSm ? 'none' : '1px solid var(--border-subtle)',
        borderBottom: '1px solid var(--border-subtle)',
      }}>
        {shown.map((s, i) => (
          <div key={s.label} style={{
            padding: isSm ? 'var(--space-4) var(--space-5)' : 'var(--space-5)',
            borderLeft: i % statCols ? '1px solid var(--border-subtle)' : 'none',
            borderTop: i >= statCols ? '1px solid var(--border-subtle)' : 'none',
          }}>
            <Stat {...s} size={isSm ? 'sm' : 'md'} hint={isSm ? undefined : s.hint} label={isSm && s.label === 'Win probability' ? 'Win prob' : s.label} />
          </div>
        ))}
      </div>

      {isSm && (
        <div style={{ padding: 'var(--space-5)' }}>
          <SegmentedControl size="sm" fullWidth options={['Starters', 'Full roster']} />
        </div>
      )}

      <div style={{
        display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
        padding: 'var(--space-4) var(--space-5)', background: 'var(--fill-warning-subtle)',
        border: isSm ? 'none' : '1px solid var(--border-subtle)',
        borderTop: isSm ? '1px solid var(--border-subtle)' : undefined,
        borderBottom: isSm ? '1px solid var(--border-subtle)' : undefined,
      }}>
        <Icon name="warning" size={16} weight="fill" style={{ color: 'var(--text-warning)', flex: 'none' }} />
        <span style={{ font: 'var(--type-body-sm)', flex: 1 }}>
          Vrba is out. Colton projects 12.0 in that slot.
        </span>
        <Button size="sm" variant="secondary">{isSm ? 'Swap' : 'Swap Vrba for Colton'}</Button>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: isSm ? 0 : 'var(--space-5)' }}>
        <SectionLabel
          bp={bp}
          meta="5 of 5 filled"
          action={!isSm && (
            <div style={{ display: 'flex', gap: 'var(--space-4)' }}>
              <Button size="sm" variant="secondary" iconLeft="arrows-clockwise">Optimise</Button>
              <Button size="sm" iconLeft="lock-simple">Lock lineup</Button>
            </div>
          )}
        >Starters</SectionLabel>
        <RosterList bp={bp} rows={STARTERS} onOpen={onOpenPlayer} />
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: isSm ? 0 : 'var(--space-5)' }}>
        <SectionLabel bp={bp}>Bench and IR</SectionLabel>
        <RosterList bp={bp} rows={RESERVES} onOpen={onOpenPlayer} dense />
      </div>

      {isSm && (
        <div style={{ padding: 'var(--space-6) var(--space-5) 0', display: 'flex', gap: 'var(--space-4)' }}>
          <Button fullWidth iconLeft="lock-simple">Lock lineup</Button>
        </div>
      )}
    </div>
  );
}
