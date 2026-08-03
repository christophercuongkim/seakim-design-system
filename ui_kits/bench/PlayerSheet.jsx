import React from 'react';
import { Avatar } from '../../components/core/Avatar.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Button } from '../../components/core/Button.jsx';
import { Stat } from '../../components/core/Stat.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';

const GAMES = [
  ['Fri · vs MIA', '24.6', '18.4'],
  ['Wed · @ ORL', '17.2', '19.0'],
  ['Mon · vs CHI', '21.9', '18.8'],
  ['Sat · @ BOS', '9.4', '17.5'],
];

/**
 * sm: bottom sheet that slides up. md+: centred panel that springs in.
 * Either way it floats, so it is one of the few shadowed surfaces.
 */
export function PlayerSheet({ player, onClose, bp = 'lg' }) {
  if (!player) return null;
  const isSm = bp === 'sm';
  return (
    <div
      onClick={onClose}
      style={{
        position: 'absolute', inset: 0, zIndex: 300, background: 'var(--surface-scrim)',
        display: 'flex',
        alignItems: isSm ? 'flex-end' : 'center',
        justifyContent: 'center',
        padding: isSm ? 0 : 'var(--space-7)',
      }}
    >
      <div
        onClick={e => e.stopPropagation()}
        style={{
          width: '100%', maxWidth: isSm ? 'none' : 460,
          maxHeight: isSm ? '82%' : '90%',
          background: 'var(--surface-overlay)',
          border: isSm ? 'none' : '1px solid var(--border-default)',
          borderTop: isSm ? '1px solid var(--border-default)' : undefined,
          boxShadow: isSm ? 'var(--shadow-sheet)' : 'var(--shadow-dialog)',
          animation: isSm
            ? 'sk-sheet-up var(--dur-slow) var(--ease-out) both'
            : 'sk-sheet-pop var(--dur-base) var(--ease-spring) both',
          display: 'flex', flexDirection: 'column',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 'var(--space-4)', padding: 'var(--space-5)' }}>
          <Avatar name={player.name} size="lg" status={player.status} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
              <span style={{ font: 'var(--type-subheading)' }}>{player.name}</span>
              {player.flag && <Badge tone={player.flag === 'OUT' ? 'danger' : 'warning'}>{player.flag}</Badge>}
            </div>
            <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 3 }}>
              {player.pos} · {player.team} · {player.matchup}
            </div>
          </div>
          <IconButton icon="x" label="Close" size="sm" onClick={onClose} />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', borderTop: '1px solid var(--border-subtle)', borderBottom: '1px solid var(--border-subtle)' }}>
          <div style={{ padding: 'var(--space-5)' }}><Stat label="Tonight" value={player.points} size="sm" /></div>
          <div style={{ padding: 'var(--space-5)', borderLeft: '1px solid var(--border-subtle)' }}><Stat label="Projected" value={player.proj} size="sm" /></div>
          <div style={{ padding: 'var(--space-5)', borderLeft: '1px solid var(--border-subtle)' }}><Stat label="Season avg" value="18.3" size="sm" delta="+1.4" /></div>
        </div>

        <div style={{ overflowY: 'auto' }}>
          <div style={{ padding: 'var(--space-5) var(--space-5) var(--space-3)', font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)', color: 'var(--text-tertiary)' }}>
            Last 4 games
          </div>
          {GAMES.map(([g, pts, proj]) => (
            <div key={g} style={{
              display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
              padding: 'var(--space-4) var(--space-5)', borderTop: '1px solid var(--border-subtle)',
            }}>
              <span style={{ font: 'var(--type-body-sm)', color: 'var(--text-secondary)', flex: 1 }}>{g}</span>
              <span style={{ font: 'var(--type-data)', fontSize: 'var(--text-md)' }}>{pts}</span>
              <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', width: 56, textAlign: 'right' }}>proj {proj}</span>
            </div>
          ))}
        </div>

        <div style={{ display: 'flex', gap: 'var(--space-4)', padding: 'var(--space-5)', borderTop: '1px solid var(--border-subtle)' }}>
          <Button variant="secondary" fullWidth>Compare</Button>
          <Button fullWidth iconLeft="arrows-left-right">Start</Button>
        </div>
        <style>{'@keyframes sk-sheet-up{from{transform:translateY(100%)}to{transform:none}}@keyframes sk-sheet-pop{from{opacity:0;transform:scale(.97)}to{opacity:1;transform:none}}'}</style>
      </div>
    </div>
  );
}
