---
id: TASK-13.103
title: 'Techies: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:04'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_techies.lua
  - tests/techies_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_techies.lua
  - bots/FunLib/rubick_hero/techies.lua
  - tests/techies_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 143000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Techies is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair current ally Tazer and owned detonation, serialize safe Blast preparation, use real Sticky delay and mine charges/spacing, and support actual Scepter Sign and Shard M.A.D. handles.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs techies; https://dotacoach.gg/en/heroes/techies and https://dotacoach.gg/en/heroes/counters/techies (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native decisions and existing mining utility, full Torte guide 309919893, complete Dotacoach Strategy/Counter Strategy and every Matchup gameplay, synergy and advanced item card. Verify mechanics against pinned Valve and localization.
- Sticky range 1000, cast point 0.1, speed 500 with acceleration 2000, stick radius 300, explosion radius 350, countdown 2 and magical damage 95/170/245/320. Tazer always targets allies at range 600, costs 60, explosion radius 400 and damage 60/110/160/210; detonate is its actual immediate sub-ability.
- Blast is root-disabled, range 1000, cast point 1 plus leap 0.75, radius 400 and magical damage 200/300/400/500. It pays nonlethal pure self damage equal to 20% current health before enemy damage.
- Proximity Mines have 3 charges, range 450, radius 500, placement separation 350, full damage within 150 and minimum 50% edge damage, activation 1 plus proximity threshold 1. Damage 400/550/700 and buildings 30%; no invented two-mine burst or guaranteed enemy stay.
- Sign is Scepter granted, range 10, cast point 1.25, aura 1000, trigger 200, lifetime 240, movement damage 300 per 200 travel and mine damage bonus 15%. Current Shard activates M.A.D. at range 450; own barrel npc_dota_techies_innate_mine has radius 400 and 1.5 explosion delay. Localization identifies techies_focused_detonate as its real detonation handle.

Implemented behavior
- Sticky predicts accelerated travel and includes the two-second countdown in regeneration-aware magical kills. Point casts respect exact actual range and latch coverage; ally saves use actual human or bot attack threats rather than ally bot mode.
- Tazer now casts on threatened real allies at exact range, rejecting existing buff, illusions and invulnerability. Early detonation requires the observed buff on a real ally with actual matching Tazer source and caster; missing copied siblings cannot invent an explosion.
- Removed the speculative multi-command Tazer/Blast queue, stale fixed 0.6 delays and invented two-mine lethal total. Native preparation spends one Tazer action, then reevaluates Blast from observed state. Channel and queue gates remain intact.
- Blast uses actual cast-plus-leap timing for interrupts and teleport windows, predicts real landing and applies health, roots, Rupture/Coil, tower, Chronosphere, Black Hole and numerical safety guards. Low-health escape can use its verified nonlethal self cost.
- Mine placement checks finite passable candidates, exact range and 350 separation against real allied mines plus bounded pending requests. Several requests retain separate three-second spacing locks; canceled casts expire and are never reported as confirmed living mines.
- Mines respect charges, outer minimum damage and activation delay, use actual disable/disarm or verified single-mine kill opportunity, and reserve available combat spell mana for farming. Defending places legal local coverage instead of repeatedly issuing far waypoint orders.
- Sign plants at the actual caster point with meaningful nearby owned mine coverage or a disabled close trigger target. It no longer walks toward random distant locations or assumes Scepter absent behavior.
- Runtime active M.A.D. plants near a disabled enemy and avoids a real existing own barrel or bounded pending request. Detonation checks actual living same-team/player barrel and predicted target presence at 1.5 seconds; missing, passive or foreign-linked state declines.
- Native and copied decisions share runtime nil/null/hidden/deactivated/passive gates and nil-first unknown dispatch.

Rejected or stale source claims
- The guide retains obsolete Stasis Trap, remote mine and experience-talent prose. Current Matchup ally-Tazer Shard claims are stale: ally targeting is now baseline and Shard grants M.A.D.
- Current localization renames focused_detonate to Detonate M.A.D.; obsolete remote-mine KV fields do not justify old radius assumptions.
- The removed native combo assumed two successful mines and full damage without charges, separation or delay.

Item follow-up observations for TASK-21
- TASK-21: Lens extends actual spells, Force Staff supports retreat or mine positioning, Ethereal/Hex can prevent mine attacks, Shard supplies the M.A.D. active and Scepter grants Sign. Preserve builds and shared item policy; no item casting or mana discounts are invented.

Enemy counterplay observations for TASK-24
- TASK-24: debuff immunity, magic barriers, dispels, illusions and forced movement limit burst and mine reliability. Actual allied stuns/grouping provide mine windows. Avoid Blade Mail/Carapace and unsafe landings; do not assume enemy attack speed or escape cooldowns.

Lobby validation checklist
- No game was launched. Verify Tazer source exposure and early detonation around a human ally, actual leap action lock and observed preparation-to-arrival follow-up.
- Verify real mine charge consumption, spawn timing, pending spacing expiry, outer damage and activation/proximity countdown. The three-second request lock is conservative and does not certify a cast.
- Verify M.A.D. barrel GetPlayerID ownership, runtime passive-to-active and focused detonation availability. A barrel without documented player ownership is conservatively ignored; actual passive death barrels are not guessed from another hero.
- Verify Sign local placement, own mine invulnerability/damage bonus and trigger. Broader objective waypoint mining remains a separate map-awareness opportunity; this pass uses only legal local defensive coverage.

Focused verification
- Focused native/copied Techies scenarios passed under Fengari.
- Valve ability check passed at 128 native heroes and 103 copied modules with zero findings; owned whitespace is clean.
- Scenarios cover delayed Sticky kills/regeneration/accelerated aim/ally saves/farming, exact Tazer range and Lens/human allies, matching modifier source and missing sibling, safe and affordable serial Blast/root/selfcost/teleport timing/escape/occupied leap, real mine spacing and charges/minimum damage/delay/combat reserve/pending expiry, Sign runtime visibility and point, M.A.D. active/absent/foreign/dead ownership/predicted detonation, ordinary queues/channels/unavailable handles and nil-first unknown dispatch.
- Shared registration/full integration suite are root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Techies standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
