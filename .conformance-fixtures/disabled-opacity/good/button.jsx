export const Button = ({ disabled }) => (
  <button style={{ color: disabled ? 'var(--text-disabled)' : 'var(--text-primary)' }} />
);
