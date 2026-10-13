import React from 'react';
import { PageHeader } from './PageHeader.jsx';
import { Badge } from '../core/Badge.jsx';
import { Button } from '../core/Button.jsx';
import { IconButton } from '../core/IconButton.jsx';
import { SegmentedControl } from '../forms/SegmentedControl.jsx';
import { Select } from '../forms/Select.jsx';

export function Demo() {
  return (
    <div className="col" style={{ gap: 'var(--space-7)' }}>
      <div>
        <div className="lbl">PageHeader</div>
        <PageHeader
          title="Trips"
          badge={<Badge mono>12</Badge>}
          actions={<>
            <IconButton icon="share-network" label="Share" variant="secondary" />
            <Button iconLeft="plus">New trip</Button>
          </>}
          toolbar={<>
            <SegmentedControl options={['List', 'Board']} defaultValue="List" size="sm" />
            <Select size="sm" options={['All trips', 'Upcoming', 'Past']} defaultValue="All trips" />
          </>}
        />
      </div>
      <div>
        <div className="lbl">PageHeader · description, no toolbar</div>
        <PageHeader
          title="Settings"
          description="Account, notifications and the people who can see your trips."
          actions={<Button variant="secondary" size="sm">Sign out</Button>}
        />
      </div>
    </div>
  );
}
