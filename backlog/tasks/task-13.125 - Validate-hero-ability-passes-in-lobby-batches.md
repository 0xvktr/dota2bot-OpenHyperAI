---
id: TASK-13.125
title: Validate hero ability passes in lobby batches
status: Needs In-Game Test
assignee: []
created_date: '2026-10-02 16:48'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
documentation:
  - docs/HERO_PASS_TRACKER.md
  - docs/HERO_PASS_REPORT.md
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
type: task
ordinal: 166000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The 124 implemented hero passes have offline checks but no recorded lobby validation. One campaign owns their per-hero live checklists and results in docs/HERO_PASS_TRACKER.md; docs/HERO_PASS_REPORT.md preserves the source reviews, regressions and engine-only limits. Add the three deferred heroes to this campaign when their standard passes land. Exercise manageable batches, prioritizing channels, vector endpoints, copied spells, minions and weak heroes. TASK-1 remains the independent Ancient Apparition live release/weak-list task; TASK-16 retains weak-hero reasons and follow-up decisions. This campaign consolidates tracking, not evidence of a successful game.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every hero with an implemented standard pass has lobby results recorded against its checklist, including game patch, settings, observed native behavior and applicable copied-spell/minion/upgrade cases.
- [ ] #2 Each failure or engine-only limitation has a reproducible observation and a linked independent bug/deep-dive task or an explicit retained limitation; untested cases remain pending in the roster tracker.
- [ ] #3 All 18 currently flagged weak heroes retain their flags until a recorded deep-dive and lobby decision supports changing them; the report identifies the 16 reviewed and 2 deferred heroes, with TASK-1 and TASK-16 links.
- [ ] #4 The campaign finishes only when every implemented hero checklist has a recorded disposition and all blocking failures are resolved or explicitly deferred with linked work; deferred standard passes remain visible.
<!-- AC:END -->
