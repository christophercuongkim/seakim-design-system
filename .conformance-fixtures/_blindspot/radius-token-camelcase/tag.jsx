// The one call-site form the current check cannot see: camelCase borderRadius
// holding a var() that is NOT one of none/full/circle. Branch one matches
// kebab-case `border-radius:` only; branch three matches a literal px only.
// Expected violations today: ZERO. ADR 0030 turns this into a catch.
export const Tag = () => <span style={{ borderRadius: 'var(--radius-xs)' }} />;
