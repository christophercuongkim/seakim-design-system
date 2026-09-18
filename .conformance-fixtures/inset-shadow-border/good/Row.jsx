export function Row({ selected }) {
  return <tr style={{ borderLeft: `var(--border-emphasis) solid ${selected ? 'var(--border-accent)' : 'transparent'}`, boxShadow: 'var(--focus-ring)' }} />;
}
