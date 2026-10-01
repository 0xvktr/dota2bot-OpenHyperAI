---
id: TASK-24
title: React to enemy spells the way players do (counterplay)
status: To Do
assignee: []
created_date: '2026-09-30 13:58'
updated_date: '2026-10-01 18:01'
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

Standard batch TASK13.13–13.17 counterplay observations (reviewed sources in subtasks; no generic-policy changes): Bloodseeker Rupture pierces immunity, so control/TP/untargetable mobility and healing suppression need effect-specific checks; Rite is delayed, and enemies can interrupt follow-up. Bounty Track is dispellable vision/damage amplification; detection routes, dispel timing and avoiding tracked Shuriken relay clusters matter; current Toss slows, so do not treat it as a channel interrupt. Bristleback is vulnerable to particular Break effects, forced facing, armor and healing suppression; not every dispel removes every Break. Broodmother's swarm needs AoE/armor/attack-immunity/anti-heal responses; scout and Roshan-clap spider micro remain generic-unit follow-ups. Centaur threatens Blink/Stomp clusters and global mobility saves; spacing, Blink cancellation and roots limit that mobility, while magic mitigation affects Edge. Current batch targeted handlers guard both Counterspell and Counterspell Ally; existing shared helper still needs wider current-modifier audit. No stale Rawhide, Silken Bola, Seeing Red or old Shuriken stun policies added.

Standard batch TASK13.18–13.22 counterplay observations (sources and stale exclusions in subtasks): Chaos Knight rewards spreading, armor/attack protection, illusion control and timely dispels; current Bolt random damage must not be assumed at its maximum. Chen camp blocking, early Roshan vision, healing reduction, army AoE/armor and Scepter-channel interruption; automatic creep disposal/spread/scout policy remains generic minion work. Clinkz detection, armor/attack immunity, reflected damage, Pact-duration windows and lateral Barrage escape. Crystal Maiden spread against Nova/Field, dispel Frostbite and interrupt Field through appropriate immunity/positioning; roots alone do not cancel arbitrary channels. Dark Seer spread against Vacuum/Wall, avoid dangerous Shell hosts, use relevant dispels/roots to deny Surge pursuit and avoid feeding valuable replica targets. Precise vector placement, copied item/passive inheritance and unusual invulnerability interactions need engine validation. No generic counterplay policy or draft changes in this batch.

Standard batch TASK13.23–13.27 counterplay observations (audited sources and capability limits in subtasks): Dark Willow Crown isolation/dispels with Shard-bramble awareness, Bedlam damage sharing through units, maze path avoidance and untargetable Realm versus area damage. Dawnbreaker avoid full physical Starbreaker arc, sidestep Hammer trail, interrupt unprotected global channel and spread/reposition from visible landing; Shard immunity and heal suppression require current mechanics. Death Prophet kite Exorcism and Siphon break buffer, pressure cooldown windows, use physical armor against ghosts and reduce healing. Disruptor avoid visibly tracked TP arrivals, leave Field before formation, spread Storm and activate immunity before Scepter mute; Glimpse is not assumed undodgeable. Doom Linkens/Lotus/current Counterspell, pre-cast disables, Earth heal suppression, Scepter-aura spacing and item/TP escape before mute talent; ordinary Doom does not universally disable items. Existing counter policy/draft tables unchanged.

Elder Titan standard pass (TASK-13.32): avoid feeding Spirit touches and respect observed returned damage/movement/Scepter immunity; disperse beyond actual Stomp origins, interrupt full Stomp windup, and move across delayed Splitter line before impact. Bonus armor, bonus magic resistance/barriers and appropriate Spirit-buff dispels retain value because Natural Order removes base defenses. Save/control synergy includes actual remaining Stomp/BH/Chronosphere duration; low-level Stomp is not a guaranteed Splitter setup. Generic wake prevention, camp/portal policy and draft matchup weights are separate follow-ups. No counterplay/draft code changed.

Dragon Knight/Drow Ranger/Earth Spirit standard-pass counterplay/draft inputs (TASK-13.28–30). DK: regen reduction and break, unit-target Tail protection through Linkens/Counterspell versus point-cast Breathe Fire. Drow: close300-range Marksmanship suppression even on Glacier, Blink/Force/Pike repositioning, bonus armor versus base-armor-ignoring procs, disarm/Ghost physical protection and appropriate Gust dispels. Earth Spirit: vision and sidesteps for fog Rolls, collision blockers, tower kick angles, actual Grip/Magnetize dispels, resistance/debuff immunity and vulnerability to silence/control. Source matchup advice is evidence for later review, not new draft weights. No counterplay/draft code changed.

Earthshaker standard pass (TASK-13.31) counterplay/draft inputs: spread from actual nearby bodies including summons/illusions and real double-emitting heroes before Echo; chip caster to deny Blink; respect full Fissure windup and wall crossings, use appropriate immunity before control, terrain/flight escape and interrupt Scepter landing. Strong dispels and reflection have current-mechanics limits. Group-control synergy is evidence for later matchup review. Discard obsolete facets and no-budget double-Echo advice. No counterplay or draft code changed.
<!-- SECTION:NOTES:END -->
