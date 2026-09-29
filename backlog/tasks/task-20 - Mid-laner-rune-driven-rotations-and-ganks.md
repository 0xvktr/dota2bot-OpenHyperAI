---
id: TASK-20
title: Mid laner rune-driven rotations and ganks
status: To Do
assignee: []
created_date: '2026-09-29 21:44'
updated_date: '2026-09-29 22:14'
labels:
  - laning
  - macro
dependencies:
  - TASK-19
references:
  - bots/mode_rune_generic.lua
  - bots/mode_roam_generic.lua
  - bots/FunLib/lane_rotation.lua
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
priority: medium
ordinal: 20000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Human mids rotate after taking a power rune: a rune at 6/8/10 minutes gives a window to gank the top or bottom lane and come back. Bot mids never do this; ganking from mid is absent and rune control is not tied to rotations. Lane equilibrium decides whether a gank is possible: if the target lane is pushed up to the enemy tower, the gank would run into tower range and should be skipped. Pairs with the rune logic in mode_rune_generic.lua and the support equilibrium work in TASK-5.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Pos 2 contests power runes at their spawn times when its lane allows
- [ ] #2 With a power rune, pos 2 rotates to gank a side lane where the wave sits away from the enemy tower and an enemy is vulnerable
- [ ] #3 No rotation when the side lane is pushed to the enemy tower or the mid wave would be lost to a tower hit
- [ ] #4 Pos 2 returns to mid or farm after the gank window
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five (doc-1, section 4) rotated heroes across the map far more often than humans do, and it was a strength. Supports frequent, cheap mid rotations when the lane state allows.
<!-- SECTION:NOTES:END -->
