---
id: TASK-21
title: 'Improve support and team item usage: targets and timing'
status: To Do
assignee: []
created_date: '2026-09-29 22:03'
labels:
  - teamfight
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
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
