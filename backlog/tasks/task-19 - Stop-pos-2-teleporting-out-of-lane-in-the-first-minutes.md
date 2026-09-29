---
id: TASK-19
title: Stop pos 2 teleporting out of lane in the first minutes
status: To Do
assignee: []
created_date: '2026-09-29 21:43'
labels:
  - laning
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - bots/FunLib/fight_response.lua
  - bots/FunLib/lane_rotation.lua
priority: high
type: bug
ordinal: 19000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Mid bots use TP scrolls very early, sometimes before 2:00, apparently to save or defend allies. A pos 2 should hold mid in the early game, not spend the TP and lose lane time. Two candidate paths: the help-ally TP branch in ConsiderItemDesire item_tpscroll (BOT_MODE_DEFEND_ALLY), which gates on J.Role.CanBeSupport(botName), a hero check rather than a position check, so many mid heroes pass; and the defend-tower TP from fight_response.lua / lane_rotation.lua added in a21e86d, which also starts laning-phase rotations. Which one fires still needs confirming (the TP cast motive shows which branch fired).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Pos 2 does not TP to help allies or defend towers during the early laning phase
- [ ] #2 Pos 2 can still TP to defend its own mid towers and to escape when in danger
- [ ] #3 Other positions' save and defend TPs are unchanged
- [ ] #4 Offline spec covers the early-game pos 2 case
<!-- AC:END -->
