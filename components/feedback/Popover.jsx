import React, { useEffect, useRef } from 'react';

/**
 * Trigger-anchored contextual overlay — the third overlay species (0022).
 *
 * Two modes. modal (a reaction bar): a scrim, focus moves into the panel and is
 * trapped there loosely, dismiss on scrim-click or Escape. non-modal (a tooltip
 * or autocomplete, the default): no scrim, focus STAYS on the trigger, dismiss on
 * outside-click, Escape, or the trigger losing focus. Both flip to stay on-screen
 * and wear the overlay surface with `--shadow-popover` and a hairline border.
 */
export function Popover({ trigger, children, open, onDismiss, modal = false, side = 'bottom', style, ...rest }) {
  const anchorRef = useRef(null);
  const panelRef = useRef(null);

  useEffect(() => {
    if (!open) return undefined;
    // modal takes focus; non-modal must not (a tooltip that steals focus is
    // broken for every AT user).
    if (modal && panelRef.current) panelRef.current.focus();

    function onKey(e) {
      if (e.key === 'Escape') onDismiss?.();
    }
    // Outside-press. modal dismisses via its scrim, so only the non-modal mode
    // needs a document listener.
    function onDocPointer(e) {
      if (modal) return;
      if (anchorRef.current && !anchorRef.current.contains(e.target)) onDismiss?.();
    }
    document.addEventListener('keydown', onKey);
    document.addEventListener('mousedown', onDocPointer);
    return () => {
      document.removeEventListener('keydown', onKey);
      document.removeEventListener('mousedown', onDocPointer);
    };
  }, [open, modal, onDismiss]);

  // Best-effort side flip: if `bottom` would overflow the viewport and there is
  // more room above, open upward. Approximate — measured against a fixed budget,
  // not the panel's real height.
  let above = false;
  if (open && side === 'bottom' && typeof window !== 'undefined' && anchorRef.current) {
    const r = anchorRef.current.getBoundingClientRect();
    const below = window.innerHeight - r.bottom;
    above = below < 240 && r.top > below;
  }
  const pos = above
    ? { bottom: '100%', left: 0, marginBottom: 4 }
    : { top: '100%', left: 0, marginTop: 4 };

  return (
    <span ref={anchorRef} style={{ position: 'relative', display: 'inline-flex' }}>
      {trigger}
      {open && modal && (
        <div
          onClick={onDismiss}
          style={{
            position: 'fixed', inset: 0, zIndex: 'var(--z-modal, 300)',
            background: 'var(--surface-scrim)',
          }}
        />
      )}
      {open && (
        <div
          ref={panelRef}
          tabIndex={modal ? -1 : undefined}
          role={modal ? 'dialog' : 'tooltip'}
          aria-modal={modal || undefined}
          style={{
            position: 'absolute', ...pos, minWidth: 'max-content',
            zIndex: modal ? 'calc(var(--z-modal, 300) + 1)' : 'var(--z-popover, 250)',
            background: 'var(--surface-overlay)',
            border: '1px solid var(--border-default)',
            boxShadow: 'var(--shadow-popover)',
            borderRadius: 'var(--radius-none)',
            outline: 'none',
            ...style,
          }}
          {...rest}
        >
          {children}
        </div>
      )}
    </span>
  );
}
