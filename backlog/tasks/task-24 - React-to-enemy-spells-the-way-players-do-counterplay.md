---
id: TASK-24
title: React to enemy spells the way players do (counterplay)
status: To Do
assignee: []
created_date: '2026-09-30 13:58'
updated_date: '2026-09-30 13:59'
labels:
  - teamfight
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - 'https://dotacoach.gg/en/heroes/counters/ancient-apparition'
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
priority: medium
type: feature
ordinal: 27000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Guides describe how players respond to specific enemy spells, and bots ignore most of it. dotacoach's "Counter Strategy" and "Bad against" sections (/en/heroes/counters/<slug>) are the main source; each hero pass under TASK-13 adds entries here instead of changing the enemy hero's file. These rules help every bot, including bot-vs-bot games.

The first two come from the Ancient Apparition review (2026-09-30): no generic code reacts to `modifier_cold_feet`, so bots stand still and take the stun; heal items such as Salve (`item_flask`) do not check `modifier_ice_blast`, so bots waste them while Frostbitten. The heal-item side overlaps TASK-21.2, which reworks when heal items are used.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A bot cursed by an enemy Cold Feet moves beyond the break distance before the stun when it can move and is not committed to a fight
- [ ] #2 Healing items and healing abilities are not used on a Frostbitten unit (modifier_ice_blast)
- [ ] #3 Offline specs cover both reactions
<!-- AC:END -->
