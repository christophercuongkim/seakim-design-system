import React from 'react';
import { Card } from '../core/Card.jsx';
import { useMeasuredBreakpoint } from '../core/useMeasuredBreakpoint.js';

/**
 * The page outside the shell: sign-in, a gate ("you are not on the list"),
 * a paywall, a wizard. The brand centred above, one column of content
 * (36rem), the content top-aligned under a fixed margin, an optional footer
 * for the legal line, full-bleed on a phone.
 *
 * Sixteen references (logins, denied pages, paywalls): the brand sits
 * centred above the content in most; only three of eight logins and no
 * denied page put the content in a bordered card, so `card` is off by
 * default; the column is 34 to 40rem wide; five top-align against three that
 * centre; the legal line is inline under the button more often than in a
 * footer, so `footer` is optional. Measured on the container.
 */
export function GateLayout({ brand, children, footer, card = false, width = '36rem', style, ...rest }) {
  const { ref, bp } = useMeasuredBreakpoint();
  const narrow = bp === 'sm';
  const body = card ? <Card padding="var(--space-7)">{children}</Card> : children;
  return (
    <div
      ref={ref}
      style={{
        minHeight: '100dvh',
        display: 'flex', flexDirection: 'column', alignItems: 'center',
        padding: narrow ? 'var(--space-7) var(--space-5) var(--space-5)' : 'var(--space-11) var(--space-7) var(--space-7)',
        boxSizing: 'border-box',
        background: 'var(--surface-page)',
        color: 'var(--text-primary)',
        ...style,
      }}
      {...rest}
    >
      {brand && (
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 'var(--space-8)', font: 'var(--type-heading)', letterSpacing: 'var(--tracking-tight)' }}>
          {brand}
        </div>
      )}
      <main style={{ width: '100%', maxWidth: width, display: 'flex', flexDirection: 'column', gap: 'var(--space-6)', minWidth: 0 }}>
        {body}
      </main>
      {footer && (
        <footer style={{ marginTop: 'auto', width: '100%', maxWidth: width, paddingTop: 'var(--space-8)', font: 'var(--type-caption)', color: 'var(--text-tertiary)', textAlign: 'center' }}>
          {footer}
        </footer>
      )}
    </div>
  );
}
