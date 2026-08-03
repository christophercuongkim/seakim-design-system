import React from 'react';
import { Card } from '../../components/core/Card.jsx';
import { Button } from '../../components/core/Button.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Stat } from '../../components/core/Stat.jsx';
import { Tag } from '../../components/core/Tag.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { EmptyState } from '../../components/feedback/EmptyState.jsx';
import { PageSection, Placeholder, pagePad } from './AppShell.jsx';

const TRIPS = [
  { id: 'lisbon', city: 'Lisbon', country: 'Portugal', dates: '14–21 Mar', nights: 7, fare: '$412', status: 'Confirmed', tone: 'success', legs: 'LIS · 2 travellers', tags: ['Flight', 'Hotel'] },
  { id: 'osaka', city: 'Osaka', country: 'Japan', dates: '2–12 May', nights: 10, fare: '$1,180', status: 'Holds 9m', tone: 'warning', legs: 'KIX · 1 traveller', tags: ['Flight'] },
  { id: 'quito', city: 'Quito', country: 'Ecuador', dates: '8–15 Aug', nights: 7, fare: '$640', status: 'Draft', tone: 'neutral', legs: 'UIO · 2 travellers', tags: ['Flight', 'Car'] },
];

const STATS = [
  { label: 'Trips this year', value: '6', hint: '3 upcoming' },
  { label: 'Spent', value: '$4,208', delta: '-12%', hint: 'vs 2024' },
  { label: 'Nights away', value: '41' },
  { label: 'Next departure', value: '18d', hint: 'Lisbon, 14 Mar' },
];

const WATCH = [
  { route: 'SFO → LIS', date: 'Mar 14', fare: '$412', delta: '-$48', dir: 'down', note: 'TAP Air Portugal · 1 stop' },
  { route: 'SFO → KIX', date: 'May 2', fare: '$1,180', delta: '+$92', dir: 'up', note: 'ANA · direct' },
];

function TripCard({ trip, onOpen, bp }) {
  return (
    <Card
      interactive
      onClick={onOpen}
      padding="var(--space-5)"
      media={<Placeholder label={trip.city + ' photography'} height={bp === 'sm' ? 132 : 104} />}
      style={bp === 'sm' ? { borderLeft: 'none', borderRight: 'none' } : undefined}
    >
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 'var(--space-4)' }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ font: 'var(--type-subheading)', letterSpacing: 'var(--tracking-tight)' }}>{trip.city}</div>
          <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>{trip.country}</div>
        </div>
        <Badge tone={trip.tone} dot={trip.tone === 'success'}>{trip.status}</Badge>
      </div>
      <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: 'var(--space-5)' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-2)' }}>
          <span style={{ font: 'var(--type-data)', color: 'var(--text-secondary)' }}>{trip.dates}</span>
          <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>{trip.nights} nights · {trip.legs}</span>
        </div>
        <Stat label="Total" value={trip.fare} align="right" size="sm" />
      </div>
      <div style={{ display: 'flex', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
        {trip.tags.map(t => <Tag key={t} icon={t === 'Flight' ? 'airplane-tilt' : t === 'Hotel' ? 'bed' : 'car'}>{t}</Tag>)}
      </div>
    </Card>
  );
}

export function TripsScreen({ bp, onOpenTrip, onSearch }) {
  const isSm = bp === 'sm';
  const statCols = bp === 'lg' ? 4 : bp === 'md' ? 2 : 3;
  const shownStats = isSm ? STATS.slice(0, 3) : STATS;
  const gutter = isSm ? { padding: '0 var(--space-5)' } : null;

  return (
    <div style={{ padding: pagePad(bp), display: 'flex', flexDirection: 'column', gap: isSm ? 'var(--space-7)' : 'var(--space-8)' }}>
      <div style={{
        display: 'grid', gridTemplateColumns: `repeat(${statCols}, 1fr)`,
        border: '1px solid var(--border-subtle)', background: 'var(--surface-card)',
        borderLeft: isSm ? 'none' : '1px solid var(--border-subtle)',
        borderRight: isSm ? 'none' : '1px solid var(--border-subtle)',
      }}>
        {shownStats.map((s, i) => (
          <div key={s.label} style={{
            padding: isSm ? 'var(--space-4) var(--space-5)' : 'var(--space-5)',
            borderLeft: i % statCols ? '1px solid var(--border-subtle)' : 'none',
            borderTop: i >= statCols ? '1px solid var(--border-subtle)' : 'none',
          }}>
            <Stat {...s} size={isSm ? 'sm' : 'md'} hint={isSm ? undefined : s.hint} />
          </div>
        ))}
      </div>

      <div style={gutter}>
        <PageSection
          title="Upcoming"
          meta="3 trips"
          action={<Button size="sm" iconLeft="plus" onClick={onSearch}>New trip</Button>}
        >
          <div style={{
            display: 'grid',
            gridTemplateColumns: isSm ? '1fr' : 'repeat(auto-fill, minmax(260px, 1fr))',
            gap: isSm ? 0 : 'var(--space-5)',
            margin: isSm ? '0 calc(-1 * var(--space-5))' : 0,
          }}>
            {TRIPS.map(t => <TripCard key={t.id} trip={t} bp={bp} onOpen={() => onOpenTrip(t)} />)}
          </div>
        </PageSection>
      </div>

      <div style={gutter}>
        <PageSection title="Watching" meta="2 fares">
          <div style={{
            border: '1px solid var(--border-subtle)', background: 'var(--surface-card)',
            margin: isSm ? '0 calc(-1 * var(--space-5))' : 0,
            borderLeft: isSm ? 'none' : undefined, borderRight: isSm ? 'none' : undefined,
          }}>
            {WATCH.map((r, i) => (
              <div key={r.route} style={{
                display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
                padding: 'var(--space-4) var(--space-5)',
                borderTop: i ? '1px solid var(--border-subtle)' : 'none',
              }}>
                <Icon name={r.dir === 'down' ? 'trend-down' : 'trend-up'} size={16} style={{ color: r.dir === 'down' ? 'var(--text-success)' : 'var(--text-danger)', flex: 'none' }} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ font: 'var(--type-data)', fontSize: 'var(--text-md)' }}>{r.route}</div>
                  <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                    {r.note}{bp !== 'lg' ? ' · ' + r.date : ''}
                  </div>
                </div>
                {bp === 'lg' && <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', width: 64 }}>{r.date}</span>}
                <div style={{ textAlign: 'right', flex: 'none' }}>
                  <div style={{ font: 'var(--type-data)', fontSize: 'var(--text-md)' }}>{r.fare}</div>
                  <div style={{ font: 'var(--type-caption)', color: r.dir === 'down' ? 'var(--text-success)' : 'var(--text-danger)', marginTop: 2 }}>{r.delta}</div>
                </div>
              </div>
            ))}
          </div>
        </PageSection>
      </div>

      <div style={gutter}>
        <PageSection title="Past trips">
          <EmptyState
            compact
            icon="clock-counter-clockwise"
            title="Nothing archived yet"
            description="Trips move here a week after you get home."
          />
        </PageSection>
      </div>
    </div>
  );
}
