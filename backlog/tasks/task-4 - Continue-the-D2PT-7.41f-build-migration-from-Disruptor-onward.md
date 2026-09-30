---
id: TASK-4
title: Continue the D2PT 7.41f build migration from Disruptor onward
status: In Progress
assignee:
  - '@codex'
created_date: '2026-09-29 21:29'
updated_date: '2026-09-30 09:31'
labels:
  - builds
dependencies: []
documentation:
  - docs/D2PT_BUILD_UPDATES.md
priority: medium
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
BotLib builds, talents and skill orders were outdated. Heroes are being rebuilt alphabetically from dota2protracker 7.41f data, only for roles with enough matches, with matching position weights, neutral preferences and D2PT matchup lists. Abaddon through Death Prophet are done.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each migrated hero has a BotLib/Builds file, 7.41f annotations and weights in both TS and Lua
- [ ] #2 Roles without enough D2PT evidence have weight 0
- [ ] #3 node tests/run-builds.cjs passes after each hero
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
2026-09-30: Research Kez carry, Marci mid/offlane and optional supports, Mars offlane, Medusa carry, Mirana supports. Update BotLib, build metadata, neutral preferences and paired weight/matchup tables. Validate the five-hero batch and preserve unrelated edits.

2026-09-30 next batch: Review Meepo mid and optional carry, Monkey King carry/mid, Morphling carry, Muerta carry and Naga Siren carry. Collect coherent builds and normalized All-role matchups, verify ability/talent maps and recipes, update metadata and paired weights, and validate each hero while preserving prior changes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-09-30: Completed Kez pos1, Marci pos2/3, Mars pos3, Medusa pos1 and Mirana pos4/5. Recorded observed D2PT build and role samples, reviewed neutral/enchantment preferences, guarded level-10 skill swaps and practical item continuations. Updated paired weight and normalized All-role matchup tables; moved Kez into alphabetic position. Reviewed and deferred Marci supports. node tests/run-builds.cjs, node tests/matchups_spec.cjs and git diff --check passed. Lobby purchase/active/talent validation remains outstanding. Preserved unrelated working-tree edits; broader migration remains In Progress.

2026-09-30: Completed Meepo pos1/2, Monkey King pos1/2, Morphling pos1, Muerta pos1 and Naga Siren pos1. Added D2PT role/build samples, source windows, neutral/enchantment observations and paired weights/matchups. Weights: Meepo 45/67; Monkey King 53/49; Morphling 61; Muerta 55; Naga Siren 57. Corrected Meepo skill queue to spend four ultimate points at 3/10/17/24 without duplicate talents; extended generic validation and real ability layouts for Monkey King/Morphling. Build suite passed after each hero; source skill/talent audit passed for seven roles; matchup suite and diff whitespace check passed. Preserved prior/unrelated edits and closed background research tab. Lobby purchase/active/talent checks remain outstanding; broader migration stays In Progress.
<!-- SECTION:NOTES:END -->
