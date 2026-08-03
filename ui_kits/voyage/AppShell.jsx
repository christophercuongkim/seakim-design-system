import React from 'react';
import { SideNav } from '../../components/navigation/SideNav.jsx';
import { TabBar } from '../../components/navigation/TabBar.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Avatar } from '../../components/core/Avatar.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';
import { Input } from '../../components/forms/Input.jsx';
import { StatusBar } from '../shared/Frames.jsx';

export const VOYAGE_NAV = [
  { value: 'trips', label: 'Trips', icon: 'suitcase-rolling', count: 3 },
  { value: 'search', label: 'Search', icon: 'magnifying-glass' },
  { value: 'saved', label: 'Saved', icon: 'bookmark-simple' },
  { value: 'account', label: 'Account', icon: 'user' },
];

/**
 * One shell, three widths. Side nav from md up (icons-only at md), bottom tab bar
 * at sm. The search field leaves the top bar at sm — it lives in the screen there.
 */
export function AppShell({ bp, active, onNavigate, title, breadcrumb, actions, theme, onToggleTheme, children }) {
  const isSm = bp === 'sm';
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      {isSm && <StatusBar />}
      <div style={{ flex: 1, minHeight: 0, display: 'flex' }}>
        {!isSm && (
          <SideNav
            brand="Voyage"
            active={active}
            collapsed={bp === 'md'}
            groups={[
              { items: VOYAGE_NAV.slice(0, 3).map(n => ({
                ...n,
                onClick: e => { e.preventDefault(); onNavigate(n.value); },
                trailing: n.count ? <Badge tone="accent">{n.count}</Badge> : undefined,
              })) },
              { label: 'Account', items: [
                { value: 'billing', label: 'Billing', icon: 'credit-card', onClick: e => e.preventDefault() },
                { value: 'travellers', label: 'Travellers', icon: 'users', onClick: e => e.preventDefault() },
                { value: 'account', label: 'Settings', icon: 'sliders-horizontal', onClick: e => { e.preventDefault(); onNavigate('account'); } },
              ] },
            ]}
            footer={bp === 'md' ? <Avatar name="Priya Shah" size="sm" /> : (
              <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
                <Avatar name="Priya Shah" size="sm" />
                <div style={{ minWidth: 0 }}>
                  <div style={{ font: 'var(--type-body-sm)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>Priya Shah</div>
                  <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>Personal</div>
                </div>
              </div>
            )}
          />
        )}

        <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column' }}>
          <header style={{
            height: 'var(--topbar-h)', flex: 'none', display: 'flex', alignItems: 'center',
            gap: 'var(--space-4)', padding: isSm ? '0 var(--space-5)' : '0 var(--space-6)',
            borderBottom: '1px solid var(--border-subtle)', background: 'var(--surface-page)',
          }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 'var(--space-4)', minWidth: 0 }}>
              {breadcrumb && !isSm && (
                <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', whiteSpace: 'nowrap' }}>
                  {breadcrumb} <span style={{ padding: '0 4px' }}>/</span>
                </span>
              )}
              <h1 style={{
                font: 'var(--type-subheading)', letterSpacing: 'var(--tracking-tight)',
                whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
              }}>{isSm ? 'Voyage' : title}</h1>
            </div>

            {bp === 'lg' && (
              <div style={{ flex: 1, maxWidth: 320, marginLeft: 'auto' }}>
                <Input size="sm" iconLeft="magnifying-glass" placeholder="Search trips, cities, codes" />
              </div>
            )}

            <div style={{ marginLeft: bp === 'lg' ? 0 : 'auto', display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
              {!isSm && actions}
              <IconButton icon={theme === 'dark' ? 'sun' : 'moon'} label="Switch theme" size={isSm ? 'sm' : 'md'} onClick={onToggleTheme} />
              <IconButton icon="bell" label="Notifications" size={isSm ? 'sm' : 'md'} />
              {!isSm && <Avatar name="Priya Shah" size="sm" />}
            </div>
          </header>

          <main style={{ flex: 1, minHeight: 0, overflowY: 'auto' }}>{children}</main>
        </div>
      </div>

      {isSm && (
        <TabBar
          active={active}
          onChange={onNavigate}
          items={VOYAGE_NAV.map(n => ({ value: n.value, label: n.label, icon: n.icon }))}
        />
      )}
    </div>
  );
}

/** Section wrapper: eyebrow, optional meta and trailing action. */
export function PageSection({ title, meta, action, children, style }) {
  return (
    <section style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-5)', ...style }}>
      {(title || action) && (
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 'var(--space-4)', flexWrap: 'wrap' }}>
          <h2 style={{
            font: 'var(--type-eyebrow)', textTransform: 'uppercase',
            letterSpacing: 'var(--tracking-caps)', color: 'var(--text-tertiary)',
          }}>{title}</h2>
          {meta && <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>{meta}</span>}
          <div style={{ marginLeft: 'auto' }}>{action}</div>
        </div>
      )}
      {children}
    </section>
  );
}

/** Neutral stand-in for real destination photography. No invented imagery. */
export function Placeholder({ label, height = 120, style }) {
  return (
    <div style={{
      height, display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'var(--surface-inset)', borderBottom: '1px solid var(--border-subtle)',
      font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)',
      color: 'var(--text-tertiary)', textAlign: 'center', padding: '0 var(--space-4)', ...style,
    }}>{label}</div>
  );
}

/** Page padding that tightens at sm. Every Voyage screen uses it. */
export function pagePad(bp) {
  return bp === 'sm'
    ? 'var(--space-5) 0 var(--space-9)'
    : 'var(--space-7) var(--space-6) var(--space-11)';
}
