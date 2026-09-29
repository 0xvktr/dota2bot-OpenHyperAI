---
id: TASK-8
title: Give cores human-like jungle farming patterns
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-29 22:14'
labels:
  - farming
dependencies:
  - TASK-7
  - TASK-6
references:
  - bots/mode_farm_generic.lua
  - bots/FunLib/aba_site.lua
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
priority: high
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
A human pos 1 beats these bots 90%+ of games by farming the jungle in the mid game until key item timings. Bot cores join fights too early, route poorly between camps, rarely use the outer camps added in 7.33, and never farm stacks.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Cores route between safe camps and lane waves instead of walking to the single closest camp
- [ ] #2 Cores use the 7.33 outer camps and farm stacked camps
- [ ] #3 Carries prioritise farm until their key item timings unless a fight or objective clearly needs them
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five (doc-1, sections 2-3): the final agent concentrated farm on its strongest heroes, and grouping as five on one lane was a trap that gave up the map's other resources. Farm priority should go to the strongest cores, and grouping should not stop side lanes and jungle being farmed. Related: TASK-22.
<!-- SECTION:NOTES:END -->
