import React from 'react';
import { Avatar } from '../../components/core/Avatar.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { Switch } from '../../components/forms/Switch.jsx';
import { PageSection, pagePad } from './AppShell.jsx';

const ROWS = [
  ['users', 'Travellers', '2 saved'],
  ['credit-card', 'Payment methods', 'Visa · 4242'],
  ['identification-card', 'Passports and visas', '1 expiring'],
  ['receipt', 'Booking history', '14 trips'],
];

export function AccountScreen({ bp }) {
  const isSm = bp === 'sm';
  const isLg = bp === 'lg';
  return (
    <div style={{
      padding: pagePad(bp),
      display: isLg ? 'grid' : 'flex',
      flexDirection: isLg ? undefined : 'column',
      gridTemplateColumns: isLg ? 'minmax(0,1fr) 320px' : undefined,
      gap: 'var(--space-8)',
    }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-7)', padding: isSm ? '0 var(--space-5)' : 0 }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 'var(--space-5)',
          padding: 'var(--space-5)', border: '1px solid var(--border-subtle)', background: 'var(--surface-card)',
        }}>
          <Avatar name="Priya Shah" size="xl" />
          <div style={{ minWidth: 0 }}>
            <div style={{ font: 'var(--type-subheading)' }}>Priya Shah</div>
            <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 3 }}>priya@example.com</div>
          </div>
        </div>

        <PageSection title="Your details">
          <div style={{ border: '1px solid var(--border-subtle)', background: 'var(--surface-card)' }}>
            {ROWS.map(([icon, label, meta], i) => (
              <button
                key={label}
                type="button"
                style={{
                  width: '100%', display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
                  minHeight: 'var(--control-h-touch)', padding: 'var(--space-4) var(--space-5)',
                  background: 'transparent', border: 'none',
                  borderTop: i ? '1px solid var(--border-subtle)' : 'none',
                  cursor: 'pointer', color: 'inherit', textAlign: 'left',
                }}
              >
                <Icon name={icon} size={18} style={{ color: 'var(--text-secondary)' }} />
                <span style={{ flex: 1, font: 'var(--type-body-sm)' }}>{label}</span>
                {meta && <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>{meta}</span>}
                <Icon name="caret-right" size={14} style={{ color: 'var(--text-tertiary)' }} />
              </button>
            ))}
          </div>
        </PageSection>
      </div>

      <div style={{ padding: isSm ? '0 var(--space-5)' : 0 }}>
        <PageSection title="Notifications">
          <div style={{
            border: '1px solid var(--border-subtle)', background: 'var(--surface-card)',
            padding: 'var(--space-5)', display: 'flex', flexDirection: 'column', gap: 'var(--space-5)',
          }}>
            <Switch label="Fare drops" hint="Routes you are watching" defaultChecked />
            <Switch label="Gate and delay changes" defaultChecked />
            <Switch label="Trip reminders" hint="24 hours before departure" defaultChecked />
            <Switch label="Product news" />
          </div>
        </PageSection>
      </div>
    </div>
  );
}
