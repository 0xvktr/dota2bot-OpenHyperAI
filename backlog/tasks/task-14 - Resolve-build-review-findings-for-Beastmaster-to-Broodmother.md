---
id: TASK-14
title: Resolve build review findings for Beastmaster to Broodmother
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
labels:
  - builds
dependencies: []
references:
  - bots/BotLib/Builds
  - docs/D2PT_BUILD_UPDATES.md
priority: medium
ordinal: 14000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
A read-only review of the D2PT-migrated Beastmaster, Bloodseeker, Bounty Hunter, Brewmaster, Bristleback and Broodmother builds found issues. Some may already be fixed, so verify each against current code first. Findings: Beastmaster T5 omits Book of the Dead and Witchbane although both have pools and handlers; Beastmaster mid Manic preference ignored by the attack profile; Beastmaster offlane buys Arcane Boots before the Helm/Dominator progression. Bristleback carry sells Linken's once Heart is owned although a slot is free. Brewmaster mid T4 includes Stormcrafter (a T3 item); offlane Manic ignored by the tank profile. Bloodseeker T3 includes Defiant Shell (a T2 item); T5 Vampiric excluded by the attack profile. Broodmother: consider replacing Soul Ring late. Bounty Hunter ward dispenser purchase and Wind Waker continuation.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each finding is fixed or recorded here as intentional
- [ ] #2 node tests/run-builds.cjs passes
<!-- AC:END -->
