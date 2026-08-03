import React from 'react';
import { SideNav } from '../../components/navigation/SideNav.jsx';
import { TabBar } from '../../components/navigation/TabBar.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Avatar } from '../../components/core/Avatar.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';
import { StatusBar } from '../shared/Frames.jsx';

export const BENCH_NAV = [
  { value: 'lineup', label: 'Lineup', icon: 'users-three' },
  { value: 'matchup', label: 'Matchup', icon: 'chart-bar' },
  { value: 'players', label: 'Players', icon: 'magnifying-glass' },
  { value: 'league', label: 'League', icon: 'trophy' },
];

/** Same chassis as Voyage: side nav from md up, bottom tab bar at sm. */
export function BenchShell({ bp, active, onNavigate, title, eyebrow, actions, theme, onToggleTheme, children }) {
  const isSm = bp === 'sm';
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      {isSm && <StatusBar />}
      <div style={{ flex: 1, minHeight: 0, display: 'flex' }}>
        {!isSm && (
          <SideNav
            brand="Bench"
            active={active}
            collapsed={bp === 'md'}
            groups={[
              { items: BENCH_NAV.map(n => ({
                ...n,
                onClick: e => { e.preventDefault(); onNavigate(n.value); },
                trailing: n.value === 'matchup' ? <Badge tone="success">Live</Badge> : undefined,
              })) },
              { label: 'Team', items: [
                { value: 'trades', label: 'Trades', icon: 'arrows-left-right', onClick: e => e.preventDefault(), trailing: <Badge tone="accent">2</Badge> },
                { value: 'settings', label: 'Settings', icon: 'sliders-horizontal', onClick: e => e.preventDefault() },
              ] },
            ]}
            footer={bp === 'md' ? <Avatar name="Bench Warmers" size="sm" /> : (
              <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
                <Avatar name="Bench Warmers" size="sm" />
                <div style={{ minWidth: 0 }}>
                  <div style={{ font: 'var(--type-body-sm)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>Bench Warmers</div>
                  <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>9–4 · 2nd</div>
                </div>
              </div>
            )}
          />
        )}

        <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column' }}>
          <header style={{
            minHeight: 'var(--topbar-h)', flex: 'none', display: 'flex', alignItems: 'center',
            gap: 'var(--space-4)', padding: isSm ? 'var(--space-3) var(--space-5)' : '0 var(--space-6)',
            borderBottom: '1px solid var(--border-subtle)',
          }}>
            <div style={{ minWidth: 0 }}>
              {eyebrow && (
                <div style={{ font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)', color: 'var(--text-tertiary)' }}>
                  {eyebrow}
                </div>
              )}
              <h1 style={{
                font: isSm ? 'var(--type-heading)' : 'var(--type-subheading)',
                letterSpacing: 'var(--tracking-tight)', whiteSpace: 'nowrap',
                overflow: 'hidden', textOverflow: 'ellipsis',
              }}>{title}</h1>
            </div>
            <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
              {!isSm && actions}
              <IconButton icon={theme === 'dark' ? 'sun' : 'moon'} label="Switch theme" size={isSm ? 'sm' : 'md'} onClick={onToggleTheme} />
              <IconButton icon="bell" label="Notifications" size={isSm ? 'sm' : 'md'} />
              {!isSm && <Avatar name="Priya Shah" size="sm" />}
            </div>
          </header>

          <main style={{ flex: 1, minHeight: 0, overflowY: 'auto' }}>{children}</main>
        </div>
      </div>

      {isSm && <TabBar active={active} onChange={onNavigate} items={BENCH_NAV} />}
    </div>
  );
}

export function pagePad(bp) {
  return bp === 'sm' ? '0 0 var(--space-9)' : 'var(--space-7) var(--space-6) var(--space-11)';
}

export function SectionLabel({ children, meta, action, bp }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'baseline', gap: 'var(--space-4)', flexWrap: 'wrap',
      padding: bp === 'sm' ? 'var(--space-6) var(--space-5) var(--space-3)' : 0,
    }}>
      <h2 style={{
        font: 'var(--type-eyebrow)', textTransform: 'uppercase',
        letterSpacing: 'var(--tracking-caps)', color: 'var(--text-tertiary)',
      }}>{children}</h2>
      {meta && <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>{meta}</span>}
      {action && <div style={{ marginLeft: 'auto' }}>{action}</div>}
    </div>
  );
}
