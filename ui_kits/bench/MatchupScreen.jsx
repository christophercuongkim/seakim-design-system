import React, { useState } from 'react';
import { Avatar } from '../../components/core/Avatar.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Button } from '../../components/core/Button.jsx';
import { Tabs } from '../../components/navigation/Tabs.jsx';
import { SegmentedControl } from '../../components/forms/SegmentedControl.jsx';
import { EmptyState } from '../../components/feedback/EmptyState.jsx';
import { pagePad } from './BenchShell.jsx';
import { H2H } from './roster.js';

const TABS = [
  { value: 'players', label: 'Players', icon: 'users-three' },
  { value: 'chart', label: 'Score chart', icon: 'chart-line' },
  { value: 'chat', label: 'Trash talk', icon: 'chat-circle', count: 3 },
];

/** sm stacks the two teams vertically-centred; md+ puts them side by side. */
function Side({ name, record, score, win, align, bp }) {
  const stacked = bp === 'sm';
  return (
    <div style={{
      flex: stacked ? 1 : 'none',
      display: 'flex', flexDirection: 'column', gap: 'var(--space-3)',
      alignItems: stacked ? 'center' : align === 'right' ? 'flex-end' : 'flex-start',
    }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
        flexDirection: stacked ? 'column' : align === 'right' ? 'row-reverse' : 'row',
      }}>
        <Avatar name={name} size="lg" />
        <div style={{ textAlign: stacked ? 'center' : align === 'right' ? 'right' : 'left' }}>
          <div style={{ font: stacked ? 'var(--type-label)' : 'var(--type-subheading)' }}>{name}</div>
          <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>{record}</div>
        </div>
      </div>
      <div style={{
        fontFamily: 'var(--font-mono)',
        fontSize: stacked ? 'var(--text-4xl)' : 'var(--text-5xl)',
        fontWeight: 'var(--weight-medium)', letterSpacing: 'var(--tracking-tighter)',
        lineHeight: 1, fontVariantNumeric: 'tabular-nums',
        color: win ? 'var(--text-accent)' : 'var(--text-primary)',
      }}>{score}</div>
    </div>
  );
}

export function MatchupScreen({ bp }) {
  const [tab, setTab] = useState('players');
  const isSm = bp === 'sm';
  const isLg = bp === 'lg';

  return (
    <div style={{ padding: pagePad(bp), display: 'flex', flexDirection: 'column', gap: isSm ? 0 : 'var(--space-7)' }}>
      <div style={{
        display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between',
        gap: isSm ? 'var(--space-4)' : 'var(--space-8)',
        padding: isSm ? 'var(--space-7) var(--space-5)' : 'var(--space-6)',
        border: isSm ? 'none' : '1px solid var(--border-subtle)',
        borderBottom: '1px solid var(--border-subtle)',
        background: isSm ? 'transparent' : 'var(--surface-card)',
      }}>
        <Side name="Bench Warmers" record={isSm ? '9–4' : '9–4 · 2nd in East'} score="79.1" win bp={bp} />
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--space-3)', paddingTop: 'var(--space-4)', flex: 'none' }}>
          <Badge tone="success" dot>Live</Badge>
          <span style={{ font: 'var(--type-eyebrow)', color: 'var(--text-tertiary)' }}>{isSm ? 'VS' : 'WEEK 14'}</span>
        </div>
        <Side name="Court Vision" record={isSm ? '8–5' : '8–5 · 5th in East'} score="78.1" align="right" bp={bp} />
      </div>

      <div style={{
        border: isSm ? 'none' : '1px solid var(--border-subtle)',
        background: 'var(--surface-card)',
      }}>
        {isSm
          ? <div style={{ padding: 'var(--space-5)' }}>
              <SegmentedControl size="sm" fullWidth value={tab} onChange={setTab}
                options={[{ value: 'players', label: 'Players' }, { value: 'chart', label: 'Chart' }, { value: 'chat', label: 'Chat' }]} />
            </div>
          : <Tabs value={tab} onChange={setTab} tabs={TABS} />}

        {tab === 'players' && (
          <div>
            {H2H.map(([slot, a, av, b, bv]) => {
              const lead = parseFloat(av) >= parseFloat(bv);
              return (
                <div key={slot} style={{
                  display: 'grid',
                  gridTemplateColumns: isLg ? '1fr 80px 60px 80px 1fr' : '1fr 52px 36px 52px 1fr',
                  alignItems: 'center', gap: isSm ? 'var(--space-3)' : 'var(--space-4)',
                  padding: isSm ? 'var(--space-4) var(--space-5)' : 'var(--space-4) var(--space-6)',
                  borderTop: '1px solid var(--border-subtle)',
                }}>
                  <span style={{ font: 'var(--type-body-sm)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{a}</span>
                  <span style={{
                    fontFamily: 'var(--font-mono)', fontSize: isSm ? 'var(--text-md)' : 'var(--text-lg)',
                    textAlign: 'right', fontVariantNumeric: 'tabular-nums',
                    color: lead ? 'var(--text-accent)' : 'var(--text-secondary)',
                  }}>{av}</span>
                  <span style={{ font: 'var(--type-eyebrow)', color: 'var(--text-tertiary)', textAlign: 'center' }}>{slot}</span>
                  <span style={{
                    fontFamily: 'var(--font-mono)', fontSize: isSm ? 'var(--text-md)' : 'var(--text-lg)',
                    fontVariantNumeric: 'tabular-nums',
                    color: !lead ? 'var(--text-accent)' : 'var(--text-secondary)',
                  }}>{bv}</span>
                  <span style={{ font: 'var(--type-body-sm)', textAlign: 'right', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{b}</span>
                </div>
              );
            })}
          </div>
        )}
        {tab === 'chart' && (
          <div style={{ padding: 'var(--space-6)', borderTop: isSm ? '1px solid var(--border-subtle)' : 'none' }}>
            <EmptyState compact icon="chart-line" title="Chart needs live game data" description="The scoring chart draws once the first quarter closes." />
          </div>
        )}
        {tab === 'chat' && (
          <div style={{ padding: 'var(--space-6)', borderTop: isSm ? '1px solid var(--border-subtle)' : 'none' }}>
            <EmptyState compact icon="chat-circle" title="3 unread messages" description="League chat is muted for this matchup." action={<Button size="sm" variant="secondary">Unmute</Button>} />
          </div>
        )}
      </div>

      <p style={{
        font: 'var(--type-caption)', color: 'var(--text-tertiary)', maxWidth: '70ch',
        padding: isSm ? 'var(--space-6) var(--space-5) 0' : 0,
      }}>
        Scores update every 30 seconds while games are live. Projections use the league's own
        scoring settings, not a third party.
      </p>
    </div>
  );
}
