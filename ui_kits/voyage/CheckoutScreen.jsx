import React, { useState } from 'react';
import { Button } from '../../components/core/Button.jsx';
import { Badge } from '../../components/core/Badge.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { Field } from '../../components/forms/Field.jsx';
import { Input } from '../../components/forms/Input.jsx';
import { Select } from '../../components/forms/Select.jsx';
import { Checkbox } from '../../components/forms/Checkbox.jsx';
import { Radio } from '../../components/forms/Radio.jsx';
import { Dialog } from '../../components/feedback/Dialog.jsx';
import { Toast } from '../../components/feedback/Toast.jsx';
import { PageSection } from './AppShell.jsx';

const LINES = [
  ['Base fare · 2 adults', '$318.00'],
  ['Taxes and carrier charges', '$74.00'],
  ['Seat selection · 2 × aisle', '$20.00'],
];

/**
 * lg: form plus a 320px summary rail with the pay button in it.
 * md/sm: summary moves above the form, and paying becomes a sticky footer bar.
 */
export function CheckoutScreen({ bp, onDone }) {
  const [confirming, setConfirming] = useState(false);
  const [paid, setPaid] = useState(false);
  const isSm = bp === 'sm';
  const isLg = bp === 'lg';
  const pad = isSm ? 'var(--space-5)' : 'var(--space-6)';

  const summary = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-5)' }}>
      <div style={{ border: '1px solid var(--border-subtle)', background: 'var(--surface-card)' }}>
        <div style={{ padding: 'var(--space-5)', borderBottom: '1px solid var(--border-subtle)', display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
          <Icon name="airplane-tilt" size={16} style={{ color: 'var(--text-secondary)' }} />
          <div style={{ flex: 1 }}>
            <div style={{ font: 'var(--type-label)' }}>SFO → LIS</div>
            <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', marginTop: 2 }}>TAP TP238 · 14 Mar, 6:40am</div>
          </div>
        </div>
        <div style={{ padding: 'var(--space-5)', display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
          {LINES.map(([l, v]) => (
            <div key={l} style={{ display: 'flex', gap: 'var(--space-4)' }}>
              <span style={{ font: 'var(--type-body-sm)', color: 'var(--text-secondary)', flex: 1 }}>{l}</span>
              <span style={{ font: 'var(--type-data)' }}>{v}</span>
            </div>
          ))}
        </div>
        <div style={{ padding: 'var(--space-5)', borderTop: '1px solid var(--border-subtle)', display: 'flex', alignItems: 'baseline', gap: 'var(--space-4)' }}>
          <span style={{ font: 'var(--type-label)', flex: 1 }}>Total</span>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: 'var(--text-2xl)', fontWeight: 'var(--weight-medium)', letterSpacing: 'var(--tracking-tight)' }}>$412.00</span>
        </div>
      </div>
      <Badge tone="warning" icon="clock">Seats held for 9 more minutes</Badge>
      {isLg && <Button size="lg" fullWidth onClick={() => setConfirming(true)}>Pay $412.00</Button>}
      <p style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>
        Your card is charged by TAP Air Portugal, not by Voyage. Fare rules apply from the
        moment the booking is issued.
      </p>
    </div>
  );

  const form = (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-8)', maxWidth: isLg ? 620 : undefined }}>
      <PageSection title="Traveller 1 · adult">
        <div style={{
          display: 'grid',
          gridTemplateColumns: isSm ? '1fr' : 'repeat(auto-fit, minmax(200px, 1fr))',
          gap: 'var(--space-5)',
        }}>
          <Field label="Given name" htmlFor="gn"><Input id="gn" defaultValue="Priya" /></Field>
          <Field label="Family name" htmlFor="fn"><Input id="fn" defaultValue="Shah" /></Field>
          <Field label="Date of birth" hint="As printed on the passport" htmlFor="dob"><Input id="dob" mono defaultValue="1991-04-22" /></Field>
          <Field label="Passport number" htmlFor="pp"><Input id="pp" mono defaultValue="X4128866" /></Field>
          <Field label="Nationality" htmlFor="nat"><Select id="nat" options={['India', 'Portugal', 'United States']} defaultValue="India" /></Field>
          <Field label="Frequent flyer" hint="Optional" htmlFor="ff"><Input id="ff" mono placeholder="TP1234567" /></Field>
        </div>
      </PageSection>

      <PageSection title="Cancellation cover">
        <Radio name="cover" defaultValue="flex" options={[
          { value: 'basic', label: 'Non-refundable', hint: 'Cheapest. No changes or refunds after booking.' },
          { value: 'flex', label: 'Flexible', hint: '+$48. Change dates once, free, up to 24h before departure.' },
          { value: 'full', label: 'Full cover', hint: '+$96. Cancel for any reason up to departure.' },
        ]} />
      </PageSection>

      <PageSection title="Payment">
        <div style={{
          display: 'grid',
          gridTemplateColumns: isSm ? '1fr' : '2fr 1fr 1fr',
          gap: 'var(--space-5)',
        }}>
          <Field label="Card number" htmlFor="cn"><Input id="cn" mono iconLeft="credit-card" defaultValue="4242 4242 4242 4242" /></Field>
          <Field label="Expiry" htmlFor="ex"><Input id="ex" mono defaultValue="04/29" /></Field>
          <Field label="CVC" htmlFor="cvc"><Input id="cvc" mono defaultValue="123" /></Field>
        </div>
        <Checkbox label="Save this card for future bookings" defaultChecked />
      </PageSection>
    </div>
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100%' }}>
      <div style={{
        flex: 1,
        padding: `var(--space-7) ${pad} var(--space-11)`,
        display: isLg ? 'grid' : 'flex',
        flexDirection: isLg ? undefined : 'column',
        gridTemplateColumns: isLg ? 'minmax(0,1fr) 320px' : undefined,
        gap: 'var(--space-8)',
      }}>
        {isLg ? form : summary}
        {isLg ? summary : form}
      </div>

      {!isLg && (
        <div style={{
          position: 'sticky', bottom: 0, flex: 'none', display: 'flex', alignItems: 'center',
          gap: 'var(--space-4)', padding: 'var(--space-5)',
          borderTop: '1px solid var(--border-subtle)', background: 'var(--surface-card)',
          boxShadow: 'var(--shadow-raised-footer)',
        }}>
          <div>
            <div style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)' }}>Total</div>
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 'var(--text-xl)', fontWeight: 'var(--weight-medium)' }}>$412.00</div>
          </div>
          <Button style={{ marginLeft: 'auto' }} size="lg" onClick={() => setConfirming(true)}>Pay now</Button>
        </div>
      )}

      <Dialog
        open={confirming}
        width={bp === 'sm' ? 340 : 440}
        title="Pay $412.00 now"
        description="This issues the ticket immediately. Under Flexible cover you can change dates once, free, up to 24 hours before departure."
        onClose={() => setConfirming(false)}
        footer={<>
          <Button variant="ghost" onClick={() => setConfirming(false)}>Keep editing</Button>
          <Button onClick={() => { setConfirming(false); setPaid(true); }}>Pay and issue ticket</Button>
        </>}
      />

      {paid && (
        <div style={{
          position: 'fixed', zIndex: 400,
          right: isSm ? 'var(--space-4)' : 'var(--space-6)',
          left: isSm ? 'var(--space-4)' : 'auto',
          bottom: isSm ? 100 : 'var(--space-6)',
        }}>
          <Toast tone="success" message="Ticket issued · XG4K2P" actionLabel="View trip" action={onDone} onDismiss={() => setPaid(false)} />
        </div>
      )}
    </div>
  );
}
