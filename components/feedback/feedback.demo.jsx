import React, { useState } from 'react';
import { Toast } from './Toast.jsx';
import { Tooltip } from './Tooltip.jsx';
import { Popover } from './Popover.jsx';
import { Combobox } from './Combobox.jsx';
import { EmptyState } from './EmptyState.jsx';
import { Skeleton } from './Skeleton.jsx';
import { LoadingState } from './LoadingState.jsx';
import { Dialog } from './Dialog.jsx';
import { Button } from '../core/Button.jsx';
import { IconButton } from '../core/IconButton.jsx';

export function Demo() {
  const [open, setOpen] = useState(false);
  const [currency, setCurrency] = useState('EUR');
  return (
    <div className="grid" style={{ gridTemplateColumns: '1fr 1fr', alignItems: 'start' }}>
      <div className="col">
        <div className="lbl">Toast</div>
        <Toast message="Trip saved" tone="success" onDismiss={() => {}} />
        <Toast message="Okafor moved to bench" actionLabel="Undo" action={() => {}} onDismiss={() => {}} />
        <Toast message="Fare changed to $438 while you were deciding" tone="warning" onDismiss={() => {}} />
        <div className="lbl" style={{ marginTop: 'var(--space-4)' }}>Tooltip · Dialog</div>
        <div className="row">
          <Tooltip label="Add leg"><IconButton icon="plus" label="Add leg" variant="secondary" /></Tooltip>
          <Tooltip label="Saved trips" side="right"><IconButton icon="bookmark-simple" label="Saved trips" variant="secondary" /></Tooltip>
          <Button variant="secondary" size="sm" onClick={() => setOpen(true)}>Open dialog</Button>
        </div>
        <div className="lbl" style={{ marginTop: 'var(--space-4)' }}>Popover</div>
        <Popover
          open
          onDismiss={() => {}}
          trigger={<Button variant="secondary" size="sm">Actions</Button>}
        >
          <div style={{ padding: 'var(--space-4)', font: 'var(--type-body-sm)', color: 'var(--text-primary)' }}>
            Rename · Duplicate · Delete
          </div>
        </Popover>
        <div className="lbl" style={{ marginTop: 'var(--space-4)' }}>Combobox</div>
        <Combobox
          value={currency}
          onChanged={setCurrency}
          placeholder="Select currency"
          options={[
            { value: 'USD', label: 'US Dollar' },
            { value: 'EUR', label: 'Euro' },
            { value: 'GBP', label: 'British Pound' },
            { value: 'JPY', label: 'Japanese Yen' },
            { value: 'AUD', label: 'Australian Dollar' },
          ]}
        />
      </div>
      <div className="col">
        <div className="lbl">EmptyState</div>
        <EmptyState
          icon="airplane-tilt"
          title="No trips yet"
          description="Start with a destination and dates. Hotels and cars can come later."
          action={<Button iconLeft="plus">New trip</Button>}
        />
        <div className="lbl" style={{ marginTop: 'var(--space-4)' }}>Skeleton · LoadingState</div>
        <div className="col" style={{ gap: 'var(--space-2)' }}>
          <Skeleton width="60%" height="var(--space-5)" />
          <Skeleton />
          <Skeleton width="80%" />
        </div>
        <LoadingState
          title="Checking 40 airlines…"
          description="Holding your dates while we compare fares."
          compact
        />
      </div>
      <Dialog
        open={open}
        title="Delete this trip"
        description="Lisbon, 14–21 Mar. Bookings you have already paid for are not cancelled by this."
        onClose={() => setOpen(false)}
        footer={<>
          <Button variant="ghost" onClick={() => setOpen(false)}>Keep trip</Button>
          <Button variant="danger" onClick={() => setOpen(false)}>Delete trip</Button>
        </>}
      />
    </div>
  );
}
