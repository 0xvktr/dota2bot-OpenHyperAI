---
id: TASK-21
title: 'Improve support and team item usage: targets and timing'
status: To Do
assignee: []
created_date: '2026-09-29 22:03'
updated_date: '2026-10-01 12:49'
labels:
  - teamfight
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - tools/tdl/fetch.cjs
priority: medium
ordinal: 21000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Every common support and team item already has a handler in ability_item_usage_generic.lua (X.ConsiderItemDesire[item]), but they are simple threshold rules: fixed HP cut-offs, the first ally found in range, self before allies, little sense of fight timing. Humans get most of these items' value from choosing the right target and moment, such as a save at the moment the burst lands, or a heal at the end of a fight. Complements TASK-11, which covers the same questions for spells.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each item group's subtask is done
- [ ] #2 Handlers are audited against how the items are used in human play; the reasoning is written into the subtasks
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-10-01: Torte de Lini guides carry per-item usage tips for many heroes (when and on whom to use the item). `node tools/tdl/fetch.cjs <hero>` prints them under "Item tips"; `node tools/tdl/fetch.cjs --all` caches every guide for searching across heroes. Reference only: turn the advice into logic, never paste the text. See the playbook (doc-2).
<!-- SECTION:NOTES:END -->
