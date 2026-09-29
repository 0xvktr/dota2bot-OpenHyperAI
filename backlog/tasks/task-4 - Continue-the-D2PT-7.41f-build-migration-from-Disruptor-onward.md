---
id: TASK-4
title: Continue the D2PT 7.41f build migration from Disruptor onward
status: In Progress
assignee: []
created_date: '2026-09-29 21:29'
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
