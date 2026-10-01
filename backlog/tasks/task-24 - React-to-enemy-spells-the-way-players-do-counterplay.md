---
id: TASK-24
title: React to enemy spells the way players do (counterplay)
status: To Do
assignee: []
created_date: '2026-09-30 13:58'
updated_date: '2026-10-01 14:54'
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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Dazzle standard pass (TASK-13.2), sources: https://dotacoach.gg/en/heroes/dazzle and https://dotacoach.gg/en/heroes/counters/dazzle, checked against pinned Valve definitions/localization cf0d37a. Counterplay candidates: deny Dazzle attack follow-up while poisoned (only his attacks refresh it); spread away from allied units that multiply Shadow Wave physical damage; focus or gap-close onto the physical body rather than the invulnerable Projection spirit, whose tether exposes its position. Grave remains vulnerable to Axe Culling Blade. Healing suppression and save-item timing overlap TASK-21. Do not adopt the counters page claim that Shard grants Poison hex; current Shard heals allied Weave stacks, while Projection grants hex. No generic counterplay implementation in this hero pass.

2026-10-01 standard batch counterplay follow-up (TASK-13.3-.7). These are reviewed inputs to existing counterplay work, not new generic counterplay implementation:
- Abaddon: stop feeding damage into Borrowed Time and kite/cyclone it; time removable debuffs after Shield is spent; break can stop automatic activation but manual ultimate remains possible, so silence matters. Account for Shield explosion/visibility rather than chasing through it.
- Underlord: avoid standing together in Firestorm/Pit chokepoints, help allies leave the zone, and extend movement/defensive-item responses through repeated Pit roots; watch Gate arrivals including Scepter destination Pit.
- Alchemist: contest camps/bounties and pressure early; healing suppression limits Rage sustain; armor/ethereal protection helps against physical Acid/Concoction but does not negate magical Radiance damage. Disables/silence during brewing can prevent Throw.
- Anti-Mage: roots/silence and area control deny Blink; targeted spells risk reflection; replenish mana before Mana Void and spread away from a drained high-max-mana ally because splash uses that source's missing mana. Physical/pure damage bypasses passive magic resistance.
- Arc Warden: allied heroes/creeps/summons near a Flux target pause damage and Scepter silence while slow persists; enter Field to defeat its outside-only evasion; summons/illusions can intercept single-target Spark Wraith. Separate main/Double cooldowns and arrival threats.
Stale facet, passive-Nullifier, and Oracle Edict magic-immunity wording was excluded where encountered. Source evidence/checklists are in the hero subtasks; broad item responses/draft tables remain unchanged.

Concrete shared-helper follow-up found during batch integration: J.CanCastOnTargetAdvanced checks legacy modifier_antimage_spell_shield but omits current modifier_antimage_counterspell. The five-hero pass uses explicit local guards for relevant reviewed unit spells; audit the shared helper and other unit-target handlers in TASK-24 before broader counterplay changes.

Standard batch TASK13.8–13.12 counterplay observations (full source reconciliation in subtasks, no generic logic edits): Hunger can be removed by kills/building kills/basic dispels; spread against Call, cyclone Axe or save Called allies, break affects Helix. Bane Nightmare transfers on allied attack, preserve/interrupt Grip and all Scepter illusion channels; strong dispel removes Grip; block/reflection punishes targeted spells, BKB denies Nightmare/Enfeeble but Sap/Grip pierce. Batrider basic dispels remove Napalm/Flamebreak; Lasso needs strong dispel and pierces BKB; spread >650 from primary vs Scepter, block/reflection/current Counterspell and allied strong-dispel saves. Beastmaster remove bounty summons, resist physical attacks with armor/barriers and magical Axes/Drums with magic protection; defend Roar with block/reflection/reposition/strong dispel, avoid isolated root→Roar. Brewmaster silence/hex before Split, kite/avoid Split unless all spirits can be killed, immunity denies spirit Cyclone/Boulder and accuracy counters Storm evasion. Legacy Drunken Haze/Void/Companion and unverified numerical or old facet claims excluded.

API audit in second standard batch added J.HasBreakModifier using seven current localization-confirmed effects. It avoids unsupported server-only PassivesDisabled; conditional Break upgrades that reuse ordinary debuffs need source/engine validation before expanding this helper.
<!-- SECTION:NOTES:END -->
