---
id: TASK-33
title: 'Stop bots buying recipes that never combine (Magic Wand, Soul Ring)'
status: Needs In-Game Test
assignee:
  - '@claude'
created_date: '2026-09-30 20:24'
updated_date: '2026-09-30 20:54'
labels:
  - items
dependencies: []
references:
  - bots/item_purchase_generic.lua
  - bots/FunLib/aba_item.lua
  - bots/FunLib/inventory_upkeep.lua
  - bots/mode_team_roam_generic.lua
priority: high
type: bug
ordinal: 37000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Seen in a 7.41f game (2026-09-30, Radiant win 46-13): bots bought an item recipe while the other components were missing, so the recipe sat in a slot for the rest of the game.

- Winter Wyvern (pos 5): Magic Stick at 0:26, Magic Wand recipe at 3:27. Its build buys `item_double_branches` first, but no Iron Branches were in the inventory at the end, so the Wand never combined and the Stick and recipe used two slots.
- Mirana: Magic Stick in her starting items, recipe at 6:58, never got a Magic Wand.
- Dazzle: got a full Magic Wand at 2:17 (recipe at 1:34), then bought a second Magic Wand recipe at 31:31.
- Dragon Knight: bought the Soul Ring recipe and never got a Soul Ring.

The rest of the itemization in that game looked correct, so this points at recipe and component handling rather than at the builds: the component queue from `Item.GetBasicItems`, the owned-count dedupe in `_stillNeeds`, early-item sells and drops, and whatever makes a finished item get queued again.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A bot only buys a recipe when every other component of that item is in its inventory, stash or courier, or will be bought before the recipe
- [x] #2 Components lost before the recipe is bought (sold, dropped or used) are bought again, or the recipe is skipped
- [ ] #3 A bot that already has the finished item (Magic Wand, Soul Ring) never buys its recipe again
- [ ] #4 Offline spec reproduces the Winter Wyvern, Dazzle, Mirana and Dragon Knight cases and passes
- [ ] #5 A full-length test game ends with no recipe left in any bot inventory
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. aba_item.lua: plan a target by claiming owned copies of each component by count (one owned Iron Branch covers one of two), replacing the presence check and the bot.sLastRepeatItem hack for nested components; the top-level target keeps its current skip-if-owned behavior. Return the claimed counts with the missing list.
2. item_purchase_generic.lua: required counts = claimed + missing, so _stillNeeds re-buys a component lost before the recipe. When everything is bought but the item has not assembled, re-plan from the target instead of GetReducedPurchaseList, and skip a still-stuck target after a bounded time with no 2000-gold gate, so one broken item cannot freeze the queue.
3. Add tests/purchase_plan_spec.lua from the scratch audit: Valve recipes fixture refreshed by tests/valve/refresh.cjs, every hero x role buy list must assemble every composite target; plus unit cases for WW pos 4, Mirana, DK pos 3 and a lost-component case. Wire into tests/run-builds.cjs.
4. Merge carefully with the uncommitted Lone Druid changes in item_purchase_generic.lua (_stillNeeds and the planning block).
5. Dazzle second recipe: confirm which recipe it was (hover in the item graph) and look for the runtime cause separately.
6. In-game test: full game, no recipe left in any bot inventory; WW/Mirana/DK build Wand/Soul Ring.

7. Added during implementation: the recipe hold considers every item built with a recipe (Boots of Travel 2 reuses the Boots of Travel recipe), and gives up after 3 minutes so a held recipe cannot block the list.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Root cause (confirmed offline): Item.GetBasicItems drops an owned component from the plan by presence, not by count, and the purchase dedupe (_stillNeeds) then compares the full owned count against that reduced count. When a bot owns 1 of a component the recipe needs twice, the plan keeps one copy (via the bot.sLastRepeatItem hack), required=1, owned=1, so the second copy is never bought and only the recipe is.
- WW pos 4 opens with one `item_branches` and no stick: buys Stick + recipe, never the 2nd branch.
- Mirana (all roles) opens with one `item_branches`: same.
- DK pos 2/3 open with `item_double_gauntlets`; Bracer eats one, Soul Ring needs two: buys Ring of Protection + recipe, never the 2nd Gauntlets.

Second-order damage: once every planned component is "bought" but the item is missing, the rebuild (Item.GetReducedPurchaseList) filters by presence too and adds nothing, and the skip counter only runs while gold >= 2000. Supports rarely hold 2000, so the whole buy queue freezes: WW bought nothing from ~3:45 to ~18:35, Mirana from ~7:10 to ~14:10.

Blast radius: an offline audit (real aba_item.lua + Valve 7.41f recipes from d2vpkr items.txt, every hero x role) finds 48 targets that never assemble, 41 hero/role lists: Magic Wand (one-branch openings) and Soul Ring (one spare Gauntlets), plus knock-on Holy Locket (Undying pos 5). Dazzle's list passes the audit, so its 2nd recipe at 31:31 is a different, runtime cause (not yet explained; Holy Locket also has a paid recipe and all recipe icons look alike).

Implemented:
- aba_item.lua: GetBasicItems claims owned copies (slots 0-14) by count and returns the claims; the bot.sLastRepeatItem hack and the presence-based rebuild helpers (HasTargetItemCompositByItems, GetReducedPurchaseList, GetIntersection, MergeLists, RemoveIntersectedItems) are removed. Items built into another item are not in a slot and never count, so a Sange inside Sange and Yasha does not cover an Abyssal Blade Sange.
- item_purchase_generic.lua: required counts = claimed + missing (_queueComponents); a recipe waits while any item built with it lacks a part and re-plans the target when nothing is on the courier/stash (_recipeWaitsForParts), giving up after 3 min; the post-purchase retry re-plans from the target, rebuildCount resets per target, and the skip timer no longer needs 2000 gold. Plans containing a recipe and recipe holds are printed as [Purchase] lines to diagnose the Dazzle case in the next game.
- Tests: tests/purchase_plan_spec.lua (wired into run-builds.cjs) runs 273 distinct hero/role buy lists through the real planner and the extracted purchase-loop functions with Valve recipes, plus WW/Mirana one-branch, DK Soul Ring, Sange-in-S&Y -> Abyssal, lost branch, courier wait and give-up cases. tests/valve/recipes.json comes from refresh.cjs at the pinned d2vpkr commit (abilities.json unchanged). Mutation check: dropping the claimed counts makes the spec fail.
- Validation: node tests/run-builds.cjs passes (all suites); git diff --check clean.

Dazzle (7.41f game): the item graph shows Holy Locket at 20:40 (consuming the Wand), then a Magic Stick at 24:45 and a Magic Wand recipe at 31:31. Its buy list passes the spec and no code path found re-queues the Wand, so the cause is still unknown. The recipe hold now stops a recipe without its parts; the [Purchase] plan log will show what queued it. AC 3 stays open until that is explained.

Note: tests/run-builds.cjs also has uncommitted lane_pull/ping_recorder lines from other in-progress tasks; stage only this task's hunks.

AC 4: the spec covers Winter Wyvern, Mirana and Dragon Knight but not Dazzle (cause unknown), so it stays open with AC 3.
<!-- SECTION:NOTES:END -->
