import React, { useState } from 'react';
import { Button } from '../../components/core/Button.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { IconButton } from '../../components/core/IconButton.jsx';
import { Tag } from '../../components/core/Tag.jsx';
import { Field } from '../../components/forms/Field.jsx';
import { Input } from '../../components/forms/Input.jsx';
import { Select } from '../../components/forms/Select.jsx';
import { Checkbox } from '../../components/forms/Checkbox.jsx';
import { SegmentedControl } from '../../components/forms/SegmentedControl.jsx';
import { Tooltip } from '../../components/feedback/Tooltip.jsx';

const RESULTS = [
  { id: 1, airline: 'TAP Air Portugal', code: 'TP238', depart: '6:40am', arrive: '9:15am', dur: '13h 35m', stops: '1 stop · LIS', fare: '$412', best: true },
  { id: 2, airline: 'United', code: 'UA918', depart: '3:55pm', arrive: '2:20pm', dur: '15h 25m', stops: '1 stop · EWR', fare: '$438' },
  { id: 3, airline: 'Lufthansa', code: 'LH455', depart: '4:20pm', arrive: '4:05pm', dur: '17h 45m', stops: '2 stops · FRA', fare: '$451' },
  { id: 4, airline: 'Delta', code: 'DL8641', depart: '9:10pm', arrive: '8:40pm', dur: '15h 30m', stops: '1 stop · AMS', fare: '$479' },
  { id: 5, airline: 'Air France', code: 'AF83', depart: '1:15pm', arrive: '12:05pm', dur: '16h 50m', stops: '1 stop · CDG', fare: '$502' },
];

/** lg: one grid row. md/sm: two stacked lines, price trailing. */
function ResultRow({ r, selected, onSelect, bp }) {
  const [hover, setHover] = useState(false);
  const surface = {
    cursor: 'pointer', color: 'inherit', textAlign: 'left', width: '100%',
    border: 'none', borderTop: '1px solid var(--border-subtle)',
    borderLeft: selected ? '2px solid var(--fill-accent)' : '2px solid transparent',
    background: selected ? 'var(--surface-selected)' : hover ? 'var(--surface-hover)' : 'transparent',
    transition: 'var(--transition-surface)',
    padding: 'var(--space-5)',
  };

  if (bp === 'lg') {
    return (
      <button type="button" onClick={onSelect}
        onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
        style={{ ...surface, display: 'grid', gridTemplateColumns: '150px 1fr 150px 110px 120px', alignItems: 'center', gap: 'var(--space-5)' }}>
        <span>
          <span style={{ display: 'block', font: 'var(--type-body-sm)' }}>{r.airline}</span>
          <span style={{ display: 'block', font: 'var(--type-eyebrow)', color: 'var(--text-tertiary)', letterSpacing: 'var(--tracking-wide)', marginTop: 3 }}>{r.code}</span>
        </span>
        <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
          <span style={{ font: 'var(--type-data)', fontSize: 'var(--text-md)' }}>{r.depart}</span>
          <span style={{ flex: 1, height: 1, background: 'var(--border-default)', position: 'relative' }}>
            <Icon name="airplane-tilt" size={12} style={{ position: 'absolute', right: -2, top: -6, color: 'var(--text-tertiary)' }} />
          </span>
          <span style={{ font: 'var(--type-data)', fontSize: 'var(--text-md)' }}>{r.arrive}</span>
        </span>
        <span>
          <span style={{ display: 'block', font: 'var(--type-data)', color: 'var(--text-secondary)' }}>{r.dur}</span>
          <span style={{ display: 'block', font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>{r.stops}</span>
        </span>
        <span>{r.best && <Badge tone="accent">Best value</Badge>}</span>
        <span style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: 'var(--space-3)' }}>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: 'var(--text-xl)', fontWeight: 'var(--weight-medium)', letterSpacing: 'var(--tracking-tight)' }}>{r.fare}</span>
          <Tooltip label="Save fare" side="left"><IconButton icon="bookmark-simple" label="Save fare" size="sm" /></Tooltip>
        </span>
      </button>
    );
  }

  return (
    <button type="button" onClick={onSelect}
      onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
      style={{ ...surface, display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', flexWrap: 'wrap' }}>
          <span style={{ font: 'var(--type-label)', fontSize: 'var(--text-md)' }}>{r.depart}</span>
          <Icon name="arrow-right" size={12} style={{ color: 'var(--text-tertiary)' }} />
          <span style={{ font: 'var(--type-label)', fontSize: 'var(--text-md)' }}>{r.arrive}</span>
          {r.best && <Badge tone="accent">Best</Badge>}
        </span>
        <span style={{ display: 'block', font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 3 }}>
          {r.airline} · {r.dur} · {r.stops}
        </span>
      </span>
      <span style={{ fontFamily: 'var(--font-mono)', fontSize: 'var(--text-xl)', fontWeight: 'var(--weight-medium)', flex: 'none' }}>{r.fare}</span>
    </button>
  );
}

function Filters({ bp }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-7)' }}>
      <SegmentedControl fullWidth size="sm" options={['One way', 'Round trip']} defaultValue="Round trip" />
      <div style={{
        display: 'grid',
        gridTemplateColumns: bp === 'lg' ? '1fr' : 'repeat(auto-fit, minmax(140px, 1fr))',
        gap: 'var(--space-5)',
      }}>
        <Field label="From" htmlFor="from"><Input id="from" size="sm" mono defaultValue="SFO" /></Field>
        <Field label="To" htmlFor="to"><Input id="to" size="sm" mono defaultValue="LIS" /></Field>
        <Field label="Depart" htmlFor="dep"><Input id="dep" size="sm" mono defaultValue="2026-03-14" /></Field>
        <Field label="Return" htmlFor="ret"><Input id="ret" size="sm" mono defaultValue="2026-03-21" /></Field>
        <Field label="Cabin" htmlFor="cab"><Select id="cab" size="sm" options={['Economy', 'Premium economy', 'Business']} /></Field>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
        <div style={{ font: 'var(--type-eyebrow)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-caps)', color: 'var(--text-tertiary)' }}>Filters</div>
        <Checkbox label="Direct only" />
        <Checkbox label="Carry-on included" defaultChecked />
        <Checkbox label="Nearby airports" hint="Adds SJC and OAK" />
      </div>
      <Button fullWidth iconLeft="magnifying-glass">Update search</Button>
    </div>
  );
}

/**
 * lg: persistent 248px filter rail.
 * md/sm: rail collapses into a chip row plus a Filters button that expands it inline.
 */
export function SearchScreen({ bp, onContinue }) {
  const [selected, setSelected] = useState(1);
  const [sort, setSort] = useState('price');
  const [showFilters, setShowFilters] = useState(false);
  const picked = RESULTS.find(r => r.id === selected);
  const isLg = bp === 'lg';

  return (
    <div style={{ display: 'flex', minHeight: '100%' }}>
      {isLg && (
        <aside style={{
          width: 248, flex: 'none', borderRight: '1px solid var(--border-subtle)',
          padding: 'var(--space-6) var(--space-5)',
        }}>
          <Filters bp={bp} />
        </aside>
      )}

      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 'var(--space-4)', flexWrap: 'wrap',
          minHeight: 'var(--subbar-h)', padding: 'var(--space-3) var(--space-5)',
          borderBottom: '1px solid var(--border-subtle)',
        }}>
          <span style={{ font: 'var(--type-body-sm)', color: 'var(--text-secondary)' }}>
            <span className="tnum" style={{ color: 'var(--text-primary)' }}>142</span> fares{bp === 'sm' ? '' : ' · SFO → LIS · 14–21 Mar'}
          </span>
          <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
            <SegmentedControl size="sm" value={sort} onChange={setSort} options={
              bp === 'sm'
                ? [{ value: 'price', label: 'Cheap' }, { value: 'time', label: 'Fast' }, { value: 'best', label: 'Best' }]
                : [{ value: 'price', label: 'Cheapest' }, { value: 'time', label: 'Fastest' }, { value: 'best', label: 'Best' }]
            } />
            {!isLg && (
              <IconButton
                icon="sliders-horizontal"
                label="Filters"
                variant={showFilters ? 'secondary' : 'ghost'}
                active={showFilters}
                onClick={() => setShowFilters(v => !v)}
              />
            )}
          </div>
        </div>

        {!isLg && showFilters && (
          <div style={{ padding: 'var(--space-5)', borderBottom: '1px solid var(--border-subtle)', background: 'var(--surface-card)' }}>
            <Filters bp={bp} />
          </div>
        )}

        {!isLg && !showFilters && (
          <div style={{ display: 'flex', gap: 'var(--space-3)', padding: 'var(--space-4) var(--space-5)', borderBottom: '1px solid var(--border-subtle)', flexWrap: 'wrap' }}>
            <Tag selected onClick={() => {}}>SFO → LIS</Tag>
            <Tag onClick={() => {}}>14–21 Mar</Tag>
            <Tag icon="airplane-tilt" onClick={() => {}}>Direct</Tag>
          </div>
        )}

        <div>
          {RESULTS.map(r => (
            <ResultRow key={r.id} r={r} bp={bp} selected={selected === r.id} onSelect={() => setSelected(r.id)} />
          ))}
        </div>

        <div style={{
          marginTop: 'auto', display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
          padding: 'var(--space-5)', borderTop: '1px solid var(--border-subtle)',
          background: 'var(--surface-card)', boxShadow: 'var(--shadow-raised-footer)',
          position: 'sticky', bottom: 0, flexWrap: 'wrap',
        }}>
          <div style={{ minWidth: 0 }}>
            <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>
              {bp === 'sm' ? picked.code : 'Selected · ' + picked.airline + ' ' + picked.code}
            </div>
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 'var(--text-xl)', fontWeight: 'var(--weight-medium)' }}>{picked.fare}</div>
          </div>
          {bp === 'lg' && (
            <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', maxWidth: '36ch' }}>
              3 seats left at this fare, per TAP's inventory feed.
            </span>
          )}
          <Button style={{ marginLeft: 'auto' }} iconRight="arrow-right" onClick={onContinue}>Continue</Button>
        </div>
      </div>
    </div>
  );
}
