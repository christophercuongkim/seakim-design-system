import React, { useState } from 'react';
import { Tabs } from '../../components/navigation/Tabs.jsx';
import { Button } from '../../components/core/Button.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Stat } from '../../components/core/Stat.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';
import { Card } from '../../components/core/Card.jsx';
import { Avatar } from '../../components/core/Avatar.jsx';
import { Textarea } from '../../components/forms/Textarea.jsx';
import { Switch } from '../../components/forms/Switch.jsx';
import { SegmentedControl } from '../../components/forms/SegmentedControl.jsx';
import { EmptyState } from '../../components/feedback/EmptyState.jsx';
import { PageSection, Placeholder } from './AppShell.jsx';

const ITINERARY = [
  { day: 'Sat 14 Mar', items: [
    { icon: 'airplane-takeoff', time: '6:40am', title: 'SFO → LIS', meta: 'TAP TP238 · 13h 35m · 1 stop', code: 'XG4K2P', tone: 'success' },
  ] },
  { day: 'Sun 15 Mar', items: [
    { icon: 'bed', time: '3:00pm', title: 'Hotel Baixa', meta: '3 nights · Double, city view', code: 'HB-88121', tone: 'success' },
  ] },
  { day: 'Wed 18 Mar', items: [
    { icon: 'car', time: '9:30am', title: 'Compact car, Sixt', meta: '4 days · Lisbon airport pickup', code: 'SX-2019', tone: 'warning' },
    { icon: 'train', time: '6:15pm', title: 'Lisbon → Sintra', meta: 'CP regional · 42m', code: null, tone: 'neutral' },
  ] },
];

const TABS = [
  { value: 'itinerary', label: 'Itinerary', icon: 'list-checks', count: 4 },
  { value: 'stays', label: 'Stays', icon: 'bed', count: 1 },
  { value: 'documents', label: 'Documents', icon: 'file-text' },
  { value: 'notes', label: 'Notes', icon: 'note' },
];

function Leg({ item, last, bp }) {
  const stacked = bp === 'sm';
  return (
    <div style={{ display: 'flex', gap: 'var(--space-4)' }}>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', width: 34, flex: 'none' }}>
        <div style={{
          width: 34, height: 34, display: 'flex', alignItems: 'center', justifyContent: 'center',
          border: '1px solid var(--border-default)', background: 'var(--surface-raised)', color: 'var(--text-secondary)',
        }}>
          <Icon name={item.icon} size={16} />
        </div>
        {!last && <div style={{ flex: 1, width: 1, background: 'var(--border-subtle)', minHeight: 20 }} />}
      </div>
      <div style={{ flex: 1, minWidth: 0, paddingBottom: last ? 0 : 'var(--space-6)' }}>
        <div style={{
          display: 'flex', alignItems: stacked ? 'flex-start' : 'baseline',
          gap: 'var(--space-3)', flexDirection: stacked ? 'column' : 'row',
        }}>
          {!stacked && <span style={{ font: 'var(--type-data)', color: 'var(--text-secondary)', width: 62, flex: 'none' }}>{item.time}</span>}
          {stacked && <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>{item.time}</span>}
          <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
            <span style={{ font: 'var(--type-label)', fontSize: 'var(--text-md)', color: 'var(--text-primary)' }}>{item.title}</span>
            {item.code && <Badge mono tone={item.tone}>{item.code}</Badge>}
          </span>
        </div>
        <div style={{
          font: 'var(--type-body-sm)', color: 'var(--text-secondary)', marginTop: 3,
          paddingLeft: stacked ? 0 : 74,
        }}>{item.meta}</div>
      </div>
    </div>
  );
}

/**
 * lg: content plus a 300px rail. md/sm: rail moves below the content, tabs become
 * a SegmentedControl, and the pay action becomes a sticky footer bar.
 */
export function TripDetailScreen({ bp, trip, onCheckout, onBack }) {
  const [tab, setTab] = useState('itinerary');
  const isSm = bp === 'sm';
  const isLg = bp === 'lg';
  const pad = isSm ? 'var(--space-5)' : 'var(--space-6)';

  const rail = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-6)' }}>
      <div style={{ border: '1px solid var(--border-subtle)', background: 'var(--surface-card)', padding: 'var(--space-5)', display: 'flex', flexDirection: 'column', gap: 'var(--space-5)' }}>
        <div style={{ font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)', color: 'var(--text-tertiary)' }}>Travellers</div>
        {[['Priya Shah', 'Organiser'], ['Marcus Reid', 'Guest']].map(([n, role]) => (
          <div key={n} style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
            <Avatar name={n} size="sm" />
            <span style={{ font: 'var(--type-body-sm)', flex: 1 }}>{n}</span>
            <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>{role}</span>
          </div>
        ))}
        <Button variant="secondary" size="sm" iconLeft="user-plus" fullWidth>Add traveller</Button>
      </div>
      <div style={{ border: '1px solid var(--border-subtle)', background: 'var(--surface-card)', padding: 'var(--space-5)', display: 'flex', flexDirection: 'column', gap: 'var(--space-5)' }}>
        <div style={{ font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)', color: 'var(--text-tertiary)' }}>Alerts</div>
        <Switch label="Fare drops" hint="Email me if this route gets cheaper" defaultChecked />
        <Switch label="Gate changes" defaultChecked />
        <Switch label="Weather warnings" />
      </div>
    </div>
  );

  const body = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-8)' }}>
      {tab === 'itinerary' && ITINERARY.map(day => (
        <PageSection key={day.day} title={day.day}>
          <div style={{ border: '1px solid var(--border-subtle)', background: 'var(--surface-card)', padding: 'var(--space-5)' }}>
            {day.items.map((item, i) => (
              <Leg key={item.title} item={item} bp={bp} last={i === day.items.length - 1} />
            ))}
          </div>
        </PageSection>
      ))}
      {tab === 'stays' && (
        <Card
          title="Hotel Baixa"
          eyebrow="15–18 Mar · 3 nights"
          meta="Rua dos Fanqueiros 12, Lisbon"
          media={<Placeholder label="Hotel photography" height={140} />}
          footer={<>
            <Badge tone="success" dot>Confirmed</Badge>
            <span style={{ font: 'var(--type-data)', marginLeft: 'auto' }}>$228</span>
          </>}
        >
          <p style={{ font: 'var(--type-body-sm)', color: 'var(--text-secondary)' }}>
            Double room, city view. Free cancellation until 12 Mar.
          </p>
        </Card>
      )}
      {tab === 'documents' && (
        <EmptyState
          icon="file-text"
          title="No documents yet"
          description="Boarding passes appear here 24 hours before departure. You can also upload a visa or insurance PDF."
          action={<Button variant="secondary" iconLeft="upload-simple">Upload document</Button>}
        />
      )}
      {tab === 'notes' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
          <Textarea rows={5} defaultValue={'Tram 28 gets crowded after 10am.\nBook Belém pastries the night before.'} />
          <div><Button size="sm">Save notes</Button></div>
        </div>
      )}
    </div>
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100%' }}>
      <div style={{ position: 'relative', flex: 'none' }}>
        <Placeholder label={(trip ? trip.city : 'Lisbon') + ' — destination photography'} height={isSm ? 168 : 180} />
        {isSm && onBack && (
          <div style={{ position: 'absolute', top: 'var(--space-4)', left: 'var(--space-4)' }}>
            <IconButton icon="arrow-left" label="Back to trips" variant="secondary" onClick={onBack} />
          </div>
        )}
      </div>

      <div style={{ padding: `var(--space-6) ${pad} 0` }}>
        <div style={{
          display: 'flex', alignItems: isLg ? 'flex-end' : 'flex-start',
          flexDirection: isLg ? 'row' : 'column',
          gap: isLg ? 'var(--space-7)' : 'var(--space-5)',
          paddingBottom: 'var(--space-6)',
        }}>
          <div style={{ minWidth: 0 }}>
            <div style={{ font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)', color: 'var(--text-tertiary)' }}>
              Portugal · 7 nights
            </div>
            <h2 style={{
              font: 'var(--type-title)',
              fontSize: isSm ? 'var(--text-3xl)' : undefined,
              letterSpacing: 'var(--tracking-tighter)', marginTop: 'var(--space-3)',
            }}>{trip ? trip.city : 'Lisbon'}</h2>
          </div>
          <div style={{ display: 'flex', gap: isSm ? 'var(--space-7)' : 'var(--space-9)', marginLeft: isLg ? 'auto' : 0, flexWrap: 'wrap' }}>
            <Stat label="Dates" value="14–21 Mar" size="sm" />
            <Stat label="Travellers" value="2" size="sm" />
            <Stat label="Total" value="$412" delta="-$48" size="sm" />
          </div>
          {!isSm && (
            <div style={{ display: 'flex', gap: 'var(--space-4)' }}>
              <Button variant="secondary" iconLeft="share-network">Share</Button>
              <Button iconLeft="credit-card" onClick={onCheckout}>Pay balance</Button>
            </div>
          )}
        </div>

        {isSm
          ? <div style={{ paddingBottom: 'var(--space-5)' }}>
              <SegmentedControl size="sm" fullWidth value={tab} onChange={setTab}
                options={TABS.slice(0, 3).map(t => ({ value: t.value, label: t.label }))} />
            </div>
          : <Tabs value={tab} onChange={setTab} tabs={TABS} />}
      </div>

      <div style={{
        flex: 1,
        padding: `var(--space-7) ${pad} var(--space-11)`,
        display: isLg ? 'grid' : 'flex',
        flexDirection: isLg ? undefined : 'column',
        gridTemplateColumns: isLg ? 'minmax(0,1fr) 300px' : undefined,
        gap: 'var(--space-8)',
      }}>
        {body}
        {rail}
      </div>

      {isSm && (
        <div style={{
          position: 'sticky', bottom: 0, flex: 'none', display: 'flex', gap: 'var(--space-4)',
          padding: 'var(--space-5)', borderTop: '1px solid var(--border-subtle)',
          background: 'var(--surface-card)', boxShadow: 'var(--shadow-raised)',
        }}>
          <IconButton icon="share-network" label="Share trip" variant="secondary" />
          <Button fullWidth iconLeft="credit-card" onClick={onCheckout}>Pay balance · $412</Button>
        </div>
      )}
    </div>
  );
}
