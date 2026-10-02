---
id: TASK-13.101
title: 'Sven: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:56'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_sven.lua
  - tests/sven_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_sven.lua
  - bots/FunLib/rubick_hero/sven.lua
  - tests/sven_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 141000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Sven is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair exact Hammer reach, impact timing and AoE proxies, protect Scepter travel, improve human ally Warcry and usable God Strength opportunities while preserving real mana-item preparation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs sven; https://dotacoach.gg/en/heroes/sven and https://dotacoach.gg/en/heroes/counters/sven (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native pass, full Torte guide 129079469, complete Dotacoach Strategy/Counter and full Matchup gameplay, synergy, core and counter item cards. Verify every mechanic using pinned Valve and localization.
- Hammer unit cast range is 600 with runtime Scepter +25%, projectile speed 1000 with runtime +25%, cast point 0.2, magical damage 80/160/240/320 and radius 250/270/290/310. Scepter basic dispel and invulnerable targeting are distinct from alt-cast travel and its additional 180 damage.
- Current Warcry radius is supplied at runtime as 700 or 900 with Shard, grants armor and speed for eight seconds, and Shard adds an undispellable 300 physical barrier. No extra manual Shard radius or talent bonus is applied.
- God Strength lasts thirty seconds, uses cast point 0.3, increases base/primary-attribute damage by 110/150/190% and supplies 40% slow resistance. Cleave is a breakable passive with actual 400/500/600/700 reach.

Implemented behavior
- Hammer no longer inflates range based on the enemy attack range or extra approach padding. Direct interrupts require actual reach and enough teleport time for cast plus projectile flight. Magical kills include regeneration and impact delay.
- AoE proxies can catch a distant hero through a legal nearby creep or hero, but the anchor must satisfy exact range, immunity and block/reflect gates. Predicted impact coverage determines cluster value.
- Actual Scepter autocast travel includes only its verified extra damage and requires unrooted safe landing, no Rupture/Coil, no tower/Chronosphere/Black Hole and acceptable numbers. Ordinary Hammer remains available independently of travel.
- Warcry covers a threatened real human or bot ally based on observed enemy attacks, pursuit or ally attacks. It uses runtime radius, ignores illusions/invulnerable allies and existing buffs, and does not ask human allies for bot mode.
- God Strength rejects disarm, existing buff, attack immunity and Blade Mail. Distant attacks reserve actual Hammer mana; nearby attacks, bosses and substantial unbroken-Cleave neutral stacks provide opportunities. It no longer spends the offensive ultimate merely because the bot is retreating.
- Fixed the stale native retarget variable that referenced an undefined weakest hero instead of the queried nearest hero. Native target decisions refresh the actual target before use.
- Preserved native PowerTreads action locks, overridable Consider APIs, ItemCastPolicy low-mana Hammer request/revalidation and fallback Warcry. Unknown copied handlers return nil first; actual missing/unavailable spell handles retain readiness gates.

Rejected or stale source claims
- Old Warcry damage-block or passive Shard armor advice conflicts with the current physical barrier upgrade.
- Some Matchup prose says Warcry shrugs off Ion Shell or Nullifier removes Refraction; no such mechanics were implemented.
- A guide sentence claims Nullifier removes hero passive abilities. Preserve actual dispel behavior and item policy rather than inventing Break.

Item follow-up observations for TASK-21
- TASK-21: activate combat buffs before Mask of Madness silence, use Blink/Harpoon for attack access, BKB against kiting, and Satanic for sustain. Current Scepter travel depends on actual autocast state; current Shard is a physical barrier/radius upgrade. Builds and shared item policy remain unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: avoid Blade Mail, attack immunity, disarm and protected targets; prioritize actual clustered AoE anchors. Armor, force movement, disables and prolonged fights can waste the God Strength window. Grouping allies such as Dark Seer/Magnus and real frontline attacks create meaningful cleave opportunities.

Lobby validation checklist
- No game was launched. Verify Scepter runtime range/speed and alt-cast travel, actual invulnerable target dispel and safe landing. This conservative pass does not target invulnerable units without verified immediate eligibility.
- Verify physical barrier, radius and active duration with Shard, human ally threat detection, buff preparation order and neutral stack value.
- Verify real mana-item request then cast, Treads action locks and Hammer proxy arrival under moving targets and spell block.

Focused verification
- Focused native/copied Sven scenarios passed under Fengari, including real ItemCastPolicy request/revalidation.
- Valve ability check passed at 128 native heroes and 98 copied modules with zero findings; owned whitespace clean.
- Existing native OD/Sven/CK item-policy scenarios pass using an external temporary copy with only the missing documented HasScepter=false fixture method. Root owns the actual legacy fixture update.
- Scenarios cover exact range/Lens, creep proxy boundaries, projectile time and regeneration, real Scepter travel damage/root/unsafe landing, ranged creep and Glyph, runtime Warcry radius/human ally/illusion/repeat, ultimate mana reserve/disarm/attack immunity/Blade Mail/retreat, stack farming and missing Cleave/Break, unavailable handles, queues/channels and nil-first copied unknown dispatch.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Sven standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
