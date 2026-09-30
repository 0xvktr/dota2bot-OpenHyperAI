---
id: TASK-25
title: Stop bots dropping and re-picking early items in an endless loop
status: To Do
assignee: []
created_date: '2026-09-30 15:22'
labels:
  - items
dependencies: []
references:
  - bots/mode_team_roam_generic.lua
  - bots/FunLib/inventory_upkeep.lua
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/155'
priority: high
type: bug
ordinal: 29000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Reported upstream (issue 155, 2026-07): with a nearly full inventory, bots drop Quelling Blade, Magic Stick or Magic Wand from the backpack, immediately pick it up again, and repeat, standing still and ignoring the game. The drop is still in our fork: TrySellOrDropItem in mode_team_roam_generic.lua sells early consumable items only at the fountain (or in Turbo) and otherwise calls Action_DropItem when the bot is 3000+ units from the fountain; something then picks the item back up.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A bot with a full inventory never re-picks an item it deliberately dropped, or sells instead of dropping
- [ ] #2 No drop and pick-up loop in a full-length test game
- [ ] #3 Offline spec covers the full-inventory case
<!-- AC:END -->
