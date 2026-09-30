---
id: TASK-31
title: Upgrade cores to Boots of Travel in the late game
status: To Do
assignee: []
created_date: '2026-09-30 15:22'
labels:
  - items
dependencies: []
references:
  - bots/item_purchase_generic.lua
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/156'
priority: low
ordinal: 35000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upstream feature request 156 proposes that after 45 minutes (25 in Turbo) bots buy Boots of Travel 1 then 2, replacing other boots but keeping Boots of Bearing and Guardian Greaves, with example code for item_purchase_generic.lua. Late-game mobility matters for defending and split pushing. D2PT builds (TASK-4) already give each hero a late continuation, so a generic rule must not fight those.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Late-game cores without utility boots move to Boots of Travel
- [ ] #2 Supports keep Greaves or Bearing
- [ ] #3 The rule defers to a hero's own late-game build when it already includes boots
<!-- AC:END -->
