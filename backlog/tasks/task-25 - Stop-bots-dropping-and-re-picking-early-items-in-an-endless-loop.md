---
id: TASK-25
title: Stop bots dropping and re-picking early items in an endless loop
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-09-30 15:22'
updated_date: '2026-10-01 20:25'
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
- [x] #1 A bot with a full inventory never re-picks an item it deliberately dropped, or sells instead of dropping
- [ ] #2 No drop and pick-up loop in a full-length test game
- [x] #3 Offline spec covers the full-inventory case
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Remove field dropping from the existing early-item backpack cleanup; preserve its level, net worth, inventory pressure, fountain sale and interval gates. 2. Rename the helper/timer to describe sales and test the actual cleanup function with a full inventory, repeated field checks, fountain sales and ineligible items. 3. Run the relevant offline suites; leave full-game validation pending.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Removed the field Action_DropItem branch from team-roam early backpack cleanup and renamed the helper/timer for sales. Items are retained away from the fountain, eliminating ground items created by this cleanup for pickup logic to chase. Kept the existing level >=6, net worth >=14000, at most one empty backpack slot, fountain <=300 and greater-than-3-second interval gates and the existing item list. The current code had no Turbo remote-sale branch; none was introduced. Validation: 11 scenarios execute the actual helper and item list, including repeated full-inventory field checks, Wand/Stick/Quelling Blade retention and later fountain sales, sale rejection, thresholds and protected main/stash/non-listed items. Full run-objectives.cjs and run-builds.cjs passed. AC2 remains unchecked: a full-length native match was not run. In-game check: when backpack is full late in a match, verify the bot keeps farming/fighting without dropping/re-picking starting items, then sells eligible backpack items on a fountain visit.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Surplus early backpack items are retained in the field and sold on a fountain visit. Verified with 11 cleanup scenarios and both full offline suites; full-length match validation remains pending.
<!-- SECTION:FINAL_SUMMARY:END -->
