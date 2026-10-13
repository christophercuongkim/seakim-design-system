The one page shape that has no sidebar: brand on top, one column, nothing else.

```jsx
<GateLayout brand="Voyage" footer={<>By continuing you agree to the <a href="/terms">terms</a>.</>}>
  <h1 style={{ font: 'var(--type-title)' }}>Sign in</h1>
  <Button fullWidth>Continue with Google</Button>
  <Button variant="secondary" fullWidth>Continue with email</Button>
</GateLayout>
```

Use it for sign-in, the not-invited page, a paywall, and a wizard's screens; leave the
app shell for everything after. The page's `h1` goes in the column, not in `brand`. Leave
`card` off unless the content is a form that needs an edge against a busy page; the
references mostly put the controls straight on the page. The column is top-aligned on
purpose: a form that jumps as its error line appears is a centred one.
