import React, { useState } from 'react';
import { PageHeader } from './PageHeader.jsx';
import { SplitPane } from './SplitPane.jsx';
import { ListRow } from '../data/ListRow.jsx';
import { ListGroup } from '../data/ListGroup.jsx';
import { Stat } from '../core/Stat.jsx';
import { Avatar } from '../core/Avatar.jsx';
import { Badge } from '../core/Badge.jsx';
import { Button } from '../core/Button.jsx';
import { IconButton } from '../core/IconButton.jsx';
import { SegmentedControl } from '../forms/SegmentedControl.jsx';
import { Select } from '../forms/Select.jsx';

const TRIPS = [
  { id: 1, city: 'Lisbon', dates: '14–21 Mar', who: 'Ada, Ravi', fare: '$412' },
  { id: 2, city: 'Kyoto', dates: '2–12 Apr', who: 'Mei', fare: '$1,180' },
  { id: 3, city: 'Oaxaca', dates: '19–26 May', who: 'Jonas, Lena, Sam', fare: '$640' },
];

export function Demo() {
  const [open, setOpen] = useState(2);
  const trip = TRIPS.find(t => t.id === open) || TRIPS[0];
  const index = TRIPS.indexOf(trip);
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
        <div className="lbl">SplitPane · list, detail with header, aside from lg</div>
        <div style={{ height: 320, background: 'var(--surface-page)' }}>
          <SplitPane
            detailOpen={open != null}
            onBack={() => setOpen(null)}
            listWidth="16rem"
            list={
              <ListGroup heading="Trips">
                {TRIPS.map(t => (
                  <ListRow key={t.id} leading={<Avatar name={t.city} size="sm" />} title={t.city} meta={t.dates} trailing={t.fare} selected={t.id === open} onClick={() => setOpen(t.id)} />
                ))}
              </ListGroup>
            }
            detail={<>
              <SplitPane.Header
                title={trip.city}
                counter={`${index + 1} of ${TRIPS.length}`}
                onClose={() => setOpen(null)}
                onPrev={index > 0 ? () => setOpen(TRIPS[index - 1].id) : undefined}
                onNext={index < TRIPS.length - 1 ? () => setOpen(TRIPS[index + 1].id) : undefined}
              />
              <div style={{ padding: 'var(--space-6)', font: 'var(--type-body-sm)', color: 'var(--text-secondary)' }}>
                {trip.dates} with {trip.who}. Flights held; the hotel is still a plan.
              </div>
            </>}
            aside={<div className="col" style={{ padding: 'var(--space-6)', gap: 'var(--space-5)' }}><Stat label="Fare" value={trip.fare} size="sm" /><Stat label="Travellers" value={String(trip.who.split(',').length)} size="sm" /></div>}
          />
        </div>
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
