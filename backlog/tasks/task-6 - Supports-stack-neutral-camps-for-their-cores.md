---
id: TASK-6
title: Supports stack neutral camps for their cores
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-30 15:22'
labels:
  - farming
dependencies: []
references:
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/46'
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
priority: high
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Supports never stack camps, so carries never reach the farm a human carry gets from stacks and cannot hit critical mass. aba_site.lua has unused stack helpers (CStackLoc with 47 hard-coded positions, GetCampStackTime) that likely predate the 7.33 map expansion. Live camp boxes are available from GetNeutralSpawners().
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Free supports stack a camp near their core's farming area at the right second and leave the spawn box before the minute mark
- [ ] #2 Stack positions come from current map data, not stale hard-coded tables
- [ ] #3 Stacking yields to lane duties, danger and team fights
- [ ] #4 Offline spec covers timing and position choice
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five (doc-1, section 7): stack timing must tolerate the ~0.12-0.2 s think step: aggro inside a window and leave the spawn box by a deadline, rather than acting at an exact second.

Upstream issue 46 (original author): stack by timing the aggro and walking away, but do not send weak or non-AoE heroes to farm big stacks too early, because bots die there.
<!-- SECTION:NOTES:END -->
