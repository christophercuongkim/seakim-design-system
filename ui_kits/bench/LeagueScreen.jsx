import React from 'react';
import { Avatar } from '../../components/core/Avatar.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { SegmentedControl } from '../../components/forms/SegmentedControl.jsx';
import { SectionLabel, pagePad } from './BenchShell.jsx';
import { STANDINGS } from './roster.js';

const TH = {
  font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)',
  color: 'var(--text-tertiary)', padding: 'var(--space-4) var(--space-5)', textAlign: 'left',
  borderBottom: '1px solid var(--border-subtle)', whiteSpace: 'nowrap',
};
const TD = { padding: 'var(--space-4) var(--space-5)', borderBottom: '1px solid var(--border-subtle)', font: 'var(--type-body-sm)' };
const NUM = { ...TD, fontFamily: 'var(--font-mono)', fontVariantNumeric: 'tabular-nums', textAlign: 'right' };

/** sm drops the two widest columns rather than shrinking the type. */
export function LeagueScreen({ bp }) {
  const isSm = bp === 'sm';
  const isLg = bp === 'lg';
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
          <SegmentedControl size="sm" fullWidth={isSm} options={isSm ? ['Standings', 'Trades'] : ['Standings', 'Transactions', 'Draft board']} />
        </div>
      </div>

      <div style={{ border: isSm ? 'none' : '1px solid var(--border-subtle)', overflowX: 'auto' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', background: 'var(--surface-card)' }}>
          <thead>
            <tr>
              <th style={{ ...TH, width: 40 }}>#</th>
              <th style={TH}>Team</th>
              <th style={{ ...TH, textAlign: 'right' }}>Record</th>
              {!isSm && <th style={{ ...TH, textAlign: 'right' }}>Points for</th>}
              {isLg && <th style={{ ...TH, textAlign: 'right' }}>Differential</th>}
            </tr>
          </thead>
          <tbody>
            {STANDINGS.map(([rank, team, rec, pf, diff]) => {
              const mine = team === 'Bench Warmers';
              return (
                <tr key={team} style={{ background: mine ? 'var(--surface-selected)' : 'transparent' }}>
                  <td style={{ ...TD, fontFamily: 'var(--font-mono)', color: 'var(--text-tertiary)' }}>{rank}</td>
                  <td style={TD}>
                    <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
                      <Avatar name={team} size="sm" />
                      <span style={{
                        font: 'var(--type-label)', fontSize: 'var(--text-sm)',
                        color: mine ? 'var(--text-accent)' : 'var(--text-primary)',
                        whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
                      }}>{team}</span>
                      {mine && <Badge tone="accent">You</Badge>}
                    </span>
                  </td>
                  <td style={NUM}>{rec}</td>
                  {!isSm && <td style={NUM}>{pf}</td>}
                  {isLg && <td style={{ ...NUM, color: diff.startsWith('-') ? 'var(--text-danger)' : 'var(--text-success)' }}>{diff}</td>}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
