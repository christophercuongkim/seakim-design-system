Every page starts with one of these, and nothing else renders an `h1`.

```jsx
<PageHeader
  title="Trips"
  badge={<Badge mono>12</Badge>}
  actions={<Button iconLeft="plus">New trip</Button>}
  toolbar={<>
    <SegmentedControl options={['List', 'Board']} defaultValue="List" size="sm" />
    <Select size="sm" options={['All', 'Upcoming', 'Past']} />
  </>}
/>
```

The count goes in `badge`, never in the title string. The view toggle, filters, tabs and
sort go in `toolbar`, never beside the title; the references keep the title row for the
name and the primary action. Three actions at most; the fourth is an overflow `IconButton`
with a `Popover`. Search is a toolbar child, not a slot. It is not sticky: a page that
needs its header pinned is scrolling the wrong element.
