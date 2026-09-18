export function Button({ active }) {
  return <button style={{ background: active ? 'var(--fill-accent-active)' : 'var(--fill-accent)', transition: 'var(--transition-control)' }} />;
}
