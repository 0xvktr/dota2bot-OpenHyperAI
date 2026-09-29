---
id: TASK-21.3
title: 'Offlaner team items: Pipe of Insight, Crimson Guard and similar'
status: To Do
assignee: []
created_date: '2026-09-29 22:03'
labels:
  - teamfight
dependencies: []
parent_task_id: TASK-21
priority: medium
ordinal: 24000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pos 3 team items such as Pipe of Insight, Crimson Guard, Shiva's Guard and Blade Mail give most of their value when popped at the start of a fight, with allies inside the radius, against the right damage type: Pipe versus magic burst, Crimson versus physical. Current handlers mostly react to the carrier's own situation.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Pipe and Crimson are used when the fight starts with allies in range, matched to the enemies' damage type
- [ ] #2 Items are not wasted outside fights or with no allies nearby
- [ ] #3 Offline specs cover fight-start and damage-type cases
<!-- AC:END -->
