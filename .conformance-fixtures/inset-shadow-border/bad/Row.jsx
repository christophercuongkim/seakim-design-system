export function Row({ selected }) {
  return <tr style={{ boxShadow: selected ? 'inset 2px 0 0 var(--border-accent)' : 'none' }} />;
}
