One file, dropped or picked, with where it stands shown beneath.

```jsx
<Field label="Résumé">
  <FileDrop
    accept=".pdf"
    hint="PDF up to 5 MB"
    file={resume}
    onFile={setResume}
    onRemove={() => setResume(null)}
    uploading={saving}
    error={tooBig ? 'That file is over 5 MB.' : undefined}
  />
</Field>
```

Put it in a `Field` for the label. Keep the hint to the types and the limit; the zone's
own line already says how. Pass `file` back once you have it (a `File` or just
`{ name, size }` from the server) so the row shows, and `uploading` while it saves: the
row takes a labelled wait, not a spinner and not a bar. Put the failure in `error`; the
references toast it, and a toast is gone before the user looks down. Multiple files are
several `FileDrop`s or a different control.
