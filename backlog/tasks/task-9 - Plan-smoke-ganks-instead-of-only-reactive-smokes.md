---
id: TASK-9
title: Plan smoke ganks instead of only reactive smokes
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
labels:
  - macro
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - bots/mode_team_roam_generic.lua
  - bots/FunLib/objectives.lua
priority: medium
ordinal: 9000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Smoke of Deceit is only used before the horn or when an ally nearby already sees an enemy hero or tower (ability_item_usage_generic ConsiderItemDesire smoke). Bots never group, smoke and gank a planned target, so smoke ganks are absent.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Bots occasionally plan a smoke gank: pick a target, gather, smoke and move together
- [ ] #2 Gank plans are cancelled when the target disappears or the group gets revealed
<!-- AC:END -->
