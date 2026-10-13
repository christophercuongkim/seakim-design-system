import React, { useRef, useState, useId } from 'react';
import { Icon } from '../core/Icon.jsx';
import { IconButton } from '../core/IconButton.jsx';
import { useCoarsePointer } from '../core/useCoarsePointer.js';

const HIDDEN_INPUT = { position: 'absolute', width: 1, height: 1, opacity: 0, overflow: 'hidden', clip: 'rect(0 0 0 0)', whiteSpace: 'nowrap' };

/** "80.3 KB", "1.2 MB". */
export function formatFileSize(bytes) {
  if (bytes == null || Number.isNaN(bytes)) return '';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

/**
 * A drop zone around a native file input: dashed hairline, an icon, "Click to
 * upload or drag and drop" with the verb link-coloured, a hint line for the
 * types and size. The references (Remote, Mercor, Lindy, Employment Hero)
 * agree on all of that; two of four are compact, so this is.
 *
 * The chosen file is a row under the zone with its name, size and a remove
 * control. Uploading is a labelled fallback on that row (0021), never a bar:
 * no reference shows one. The error renders under the zone as a Field-style
 * line and is announced; the references toast it, and a toast can be missed.
 * One file. The input is the focus target, so Enter and Space open the picker
 * and the ring is the system's.
 */
export function FileDrop({
  accept, onFile, file, onRemove, uploading = false, error, hint,
  icon = 'upload-simple', action = 'Click to upload', label = 'or drag and drop',
  disabled = false, style, ...rest
}) {
  const id = useId();
  const [over, setOver] = useState(false);
  const [focus, setFocus] = useState(false);
  const depth = useRef(0);
  const coarse = useCoarsePointer();

  const pick = (list) => {
    const f = list && list[0];
    if (f && onFile && !disabled) onFile(f);
  };
  const border = error ? 'var(--text-danger)' : over ? 'var(--border-accent)' : focus ? 'var(--border-focus)' : 'var(--border-default)';

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)', ...style }} {...rest}>
      <label
        onDragEnter={(e) => { e.preventDefault(); depth.current += 1; if (!disabled) setOver(true); }}
        onDragLeave={() => { depth.current -= 1; if (depth.current <= 0) { depth.current = 0; setOver(false); } }}
        onDragOver={(e) => e.preventDefault()}
        onDrop={(e) => { e.preventDefault(); depth.current = 0; setOver(false); pick(e.dataTransfer && e.dataTransfer.files); }}
        style={{
          position: 'relative',
          display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
          minHeight: coarse ? 'var(--control-h-touch)' : undefined,
          padding: 'var(--space-6) var(--space-5)',
          borderRadius: 'var(--radius-lg)',
          border: `1px dashed ${disabled ? 'var(--border-disabled)' : border}`,
          background: disabled ? 'var(--fill-disabled)' : over ? 'var(--surface-hover)' : 'var(--surface-raised)',
          boxShadow: focus ? 'var(--focus-ring)' : 'none',
          cursor: disabled ? 'not-allowed' : 'pointer',
          transition: 'var(--transition-control), box-shadow var(--dur-instant) var(--ease-out)',
        }}
      >
        <input
          type="file"
          accept={accept}
          disabled={disabled}
          aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
          aria-invalid={error ? true : undefined}
          onChange={(e) => { pick(e.target.files); e.target.value = ''; }}
          onFocus={() => setFocus(true)}
          onBlur={() => setFocus(false)}
          style={HIDDEN_INPUT}
        />
        {icon && <Icon name={icon} size={20} style={{ color: disabled ? 'var(--text-disabled)' : 'var(--text-tertiary)' }} />}
        <span style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-1)', minWidth: 0 }}>
          <span style={{ font: 'var(--type-body)', color: disabled ? 'var(--text-disabled)' : 'var(--text-primary)' }}>
            <span style={{ color: disabled ? 'var(--text-disabled)' : 'var(--text-link)' }}>{action}</span> {label}
          </span>
          {hint && <span id={`${id}-hint`} style={{ font: 'var(--type-caption)', color: disabled ? 'var(--text-disabled)' : 'var(--text-tertiary)' }}>{hint}</span>}
        </span>
      </label>
      {file && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', padding: '0 var(--space-2) 0 var(--space-3)', minHeight: 'var(--control-h-md)' }}>
          <Icon name="paperclip" size={16} style={{ color: 'var(--text-tertiary)' }} />
          <span style={{ font: 'var(--type-body-sm)', color: 'var(--text-primary)', minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{file.name}</span>
          {file.size != null && <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', whiteSpace: 'nowrap' }}>{formatFileSize(file.size)}</span>}
          <span style={{ flex: 1 }} />
          {uploading ? (
            <span role="status" aria-busy="true" aria-live="polite" style={{ display: 'inline-flex', alignItems: 'center', gap: 'var(--space-3)', font: 'var(--type-caption)', color: 'var(--text-secondary)' }}>
              <span aria-hidden="true" style={{ width: 'var(--space-9)', height: 'var(--space-1)', background: 'var(--surface-shimmer)' }} />
              Uploading…
            </span>
          ) : onRemove && (
            <IconButton icon="x" label={`Remove ${file.name}`} variant="ghost" size="sm" onClick={onRemove} disabled={disabled} />
          )}
        </div>
      )}
      {error && <div id={`${id}-error`} role="alert" style={{ font: 'var(--type-caption)', color: 'var(--text-danger)' }}>{error}</div>}
    </div>
  );
}
