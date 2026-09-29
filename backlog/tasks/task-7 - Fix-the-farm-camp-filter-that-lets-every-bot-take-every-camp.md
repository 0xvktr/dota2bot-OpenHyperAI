---
id: TASK-7
title: Fix the farm camp filter that lets every bot take every camp
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
labels:
  - farming
dependencies: []
references:
  - bots/FunLib/aba_site.lua
  - typescript/bots/FunLib/aba_site.ts
  - bots/mode_farm_generic.lua
priority: high
type: bug
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
RefreshCamp in aba_site.lua has level-based filters (no large or enemy camps early, no ancients before level 10), but every branch including the final else adds the camp, so the filters do nothing. Only closest-camp choice (enemy camps x1.5 distance) and the ancient level check in GetClosestNeutralSpwan remain. aba_site.lua is generated from typescript/bots/FunLib/aba_site.ts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Low-level bots no longer pick camps their filters exclude
- [ ] #2 The fix is made in the TypeScript source and the generated Lua matches
- [ ] #3 Offline spec covers each level bracket
<!-- AC:END -->
