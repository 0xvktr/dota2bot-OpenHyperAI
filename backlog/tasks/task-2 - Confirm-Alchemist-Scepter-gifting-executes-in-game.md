---
id: TASK-2
title: Confirm Alchemist Scepter gifting executes in game
status: Needs In-Game Test
assignee: []
created_date: '2026-09-29 21:29'
labels:
  - hero
dependencies: []
references:
  - bots/FunLib/alchemist_scepter.lua
  - tests/alchemist_scepter_spec.lua
priority: medium
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Alchemist gifts Aghanim's Scepter (global cast) to his pos 2, then pos 3 ally once his core build is done. Purchase, recipient choice and inventory handling are covered offline, but whether the engine accepts Action_UseAbilityOnEntity with the Scepter on an ally has never been observed.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Alchemist buys and gifts a Scepter to an ally without it in a late game
- [ ] #2 The recipient gets the Aghanim's Blessing buff and Alchemist keeps no leftover Scepter in inventory
- [ ] #3 A failed gift does not loop purchases
<!-- AC:END -->
