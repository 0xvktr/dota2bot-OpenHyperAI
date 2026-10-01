---
id: TASK-7
title: Fix the farm camp filter that lets every bot take every camp
status: Done
assignee:
  - '@codex'
created_date: '2026-09-29 21:29'
updated_date: '2026-10-01 20:25'
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
- [x] #1 Low-level bots no longer pick camps their filters exclude
- [x] #2 The fix is made in the TypeScript source and the generated Lua matches
- [x] #3 Offline spec covers each level bracket
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Keep the camp availability registry complete and move the existing level/damage eligibility rules to per-bot camp selection, using cattr for camp type/team. 2. Regenerate aba_site.lua from TypeScript with a focused compiler run. 3. Test every level/damage bracket, shared-list callers, and raw camp attribute selection.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Moved eligibility into CanFarmCamp and GetClosestNeutralSpwan instead of pruning RefreshCamp: the availability registry must retain camps other farmers can use. Original tier thresholds are now effective: level <=7 or attack damage <=80 uses allied non-large/non-ancient camps; levels 8-11 with damage >80 allow allied regular camps; levels 12-14 allow allied ancients; level 15+ with damage >80 allows all camps. Fixed camp attribute reads to use cattr for type/team and the enemy distance penalty. A focused TSTL compile regenerates only aba_site.lua and the test compares the full generated file against TypeScript. Validation: 15 actual-selector scenarios, full run-objectives.cjs and run-builds.cjs passed; build suite parsed 381 Lua files. No live farming observation claimed.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Camp selection now enforces the existing level/damage brackets per bot without removing entries from the availability registry. TypeScript and generated Lua match. Verified with 15 camp scenarios and both full offline suites.
<!-- SECTION:FINAL_SUMMARY:END -->
