import React from 'react';

/**
 * A placeholder shaped like the content that is arriving (decision 0021).
 *
 * Use it whenever you know *what* is coming — a list row, a stat, a table cell —
 * so it mirrors that geometry and real content drops in without a layout shift.
 * It pulses between `--surface-sunken` and `--surface-shimmer`; it never spins.
 * Reduced motion collapses it to a static block (handled in `tokens/motion.css`).
 * It is decorative, so it is `aria-hidden` — the surrounding region owns the
 * busy announcement (see `LoadingState`).
 */
export function Skeleton({
  width = '100%',
  height = 'var(--space-6)',
  radius = 'var(--radius-none)',
  style,
  ...rest
}) {
  return (
    <span
      aria-hidden="true"
      className="sk-shimmer"
      style={{
        display: 'block',
        width,
        height,
        borderRadius: radius,
        background: 'var(--surface-sunken)',
        ...style,
      }}
      {...rest}
    />
  );
}
