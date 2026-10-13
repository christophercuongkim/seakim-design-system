The pipeline as columns; a card opens the record.

```jsx
<Board>
  <BoardColumn label="Pursuing" count={3} footer={<Button variant="ghost" size="sm" iconLeft="plus">Add</Button>}>
    {postings.map(p => (
      <Card key={p.id} interactive onClick={() => open(p)} eyebrow={p.company} title={p.title} padding="var(--space-5)">
        <Tag>{p.verdict}</Tag>
      </Card>
    ))}
  </BoardColumn>
  <BoardColumn label="Applied" count={0} />
</Board>
```

Give the board a height if the page should scroll columns rather than the page. Keep a
card to a title, one chip and one date; the record is a click away. Leave `collapseEmpty`
off unless the pipeline has more columns than a screen fits; the references show empty
columns at full width. Moving a card is the card's own menu (a `Popover` on a desktop, a
`Sheet` on a phone), not a drag. Under `md` the board swipes one column at a time; do not
add a tab picker, no reference has one.
