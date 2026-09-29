---
id: TASK-3
title: Confirm wards no longer block our own neutral camps
status: Needs In-Game Test
assignee: []
created_date: '2026-09-29 21:29'
labels:
  - wards
dependencies: []
references:
  - bots/FunLib/aba_ward_utility.lua
  - tests/ward_spawn_box_spec.lua
  - tests/neutral_spawners_741f.lua
priority: high
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bots were seen blocking their own jungle camps with observer wards. Two hard-coded Radiant spots were inside Radiant spawn boxes (ancient camp, bottom medium camp). Ward spots are now moved out of our own boxes using GetNeutralSpawners() min/max at runtime; this needs a game on each side to confirm.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Over a full game on each side, no allied observer or sentry sits inside an allied camp's spawn box
- [ ] #2 Moved spots still give vision of the intended area
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Camp boxes dumped from a 7.41f lobby are in tests/neutral_spawners_741f.lua; re-dump with FunLib/debug_dumps.lua after map patches.
<!-- SECTION:NOTES:END -->
