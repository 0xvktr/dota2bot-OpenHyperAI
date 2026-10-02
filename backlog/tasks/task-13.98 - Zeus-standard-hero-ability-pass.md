---
id: TASK-13.98
title: 'Zeus: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:51'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_zuus.lua
  - tests/zuus_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_zuus.lua
  - bots/FunLib/rubick_hero/zuus.lua
  - tests/zuus_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 138000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Zeus is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair exact spell range and impact damage, conservative observed global support, true Nimbus dependency, useful safe facing-based Jump and actual Lightning Hands upgrade, preserving build/skill/talent preferences and narrow copied dispatch.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs zuus; https://dotacoach.gg/en/heroes/zeus and https://dotacoach.gg/en/heroes/counters/zeus (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native Zeus controller, full Torte guide 129065509 including all ability/item tips, complete Dotacoach Strategy/Counter Strategy/Matchup gameplay, synergy, core and counter item cards, pinned Valve KV and English localization.
- Arc runtime damage is 105/130/155/180 with 800 cast range, 0.2 cast point and 450 jump radius. Bolt has both unit and point shape, actual range 700/750/800/850, 0.3 cast point, 140/220/300/380 damage, closest enemy hero selection within 325 and actual AoE talent radius.
- Jump is no-target, immediate and root-disabled; runtime hop 375/450/525/600, 0.5 duration and shock range 700/800/900/1000. Wrath is global no-target with 0.4 cast point and runtime 275/425/575 plus actual talent damage.
- Nimbus is a global point spell granted by Scepter with 275 mana, 30-second duration, 450 radius and 2.5-second Bolt interval. Actual Bolt is required for damage, including Ability Draft or copied cases.
- Static Field is a separate breakable innate with 3.45% plus 0.05% per hero level. Lightning Hands is an actual free toggle granted by Shard, with 20 attack speed and 50% Arc damage; current behavior ignores silence and invisibility.

Implemented behavior
- Removed invented nine-percent field damage based on Lightning Hands and guessed full-combination kill math. Guaranteed kill checks use actual runtime spell damage and arrival regeneration without assumed copied siblings.
- Arc uses exact Lens/Supremacy range, real enemy or human ally pressure, ranged last hits, useful local creep packs and eligible bosses.
- Bolt uses direct unit casts inside exact reach and predicted legal point casts for current AoE or ground extension. Closest-hero checks reject an unintended interception; block/reflection/immunity gates remain conservative. Recent last-seen ground reveal during a damaged retreat uses location and age only, without hidden health.
- Wrath requires observed visible enemy health for kill decisions or multiple actual human/bot allied fights. All observed global reflectors are budgeted together, including own spell amplification, with a survival margin; observed Carapace blocks a damaging global cast.
- Nimbus supports actual global allied pressure, requires its real visible trained Bolt sibling, predicts the first conservative interval, and suppresses duplicate placement around actual owned living Clouds. No full-duration damage or guaranteed interrupt is assumed.
- Jump uses runtime hop distance, actual facing, passable safe landing, root/leash/Rupture/Coil restrictions, towers/Chronosphere/Black Hole and local numbers. Escape checks actual threat; approach checks predicted shock reach.
- Lightning Hands turns on once through an available actual handle while silenced or invisible, retaining all channel/queue/casting/disable/invulnerability and forced-movement locks. Copied spells remain independently usable, with nil-first unknown dispatch and actual optional readiness.
- Channel interrupts use actual observed teleport modifier remaining duration versus cast/projectile arrival, avoiding interrupt-only requests that are already too late.

Rejected or stale source claims
- Rejected obsolete Lightning Hands-as-Static-Field slots, hardcoded field percentages, guessed delayed global combos, old facets, Arcane Boots disassembly and full Nimbus repeated-damage claims.
- Dotacoach current Strategy says Wrath hits invisible units while some Smoke counter item prose describes the older dodge. Hidden/smoked eligibility stays a lobby check and hidden health never drives a guaranteed kill.
- Matchup claims concerning increased magical damage against current Muerta and magical blocking by Void Spirit Pulse conflict with current mechanics; no such multipliers were encoded.

Item follow-up observations for TASK-21
- TASK-21: current Shard toggle, actual Scepter Nimbus and Bolt dependency, Lens reach, defensive positioning, and useful Refresher mana reserve need shared item follow-up. Builds and generic item policy remain unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: respect actual block/reflection, immunity, spell resistance/barriers, lost vision, controlled landing, and Nimbus destruction; actual ally setup enables global support. Long-range burst, silences and mobility can deny safe spell access.

Lobby validation checklist
- Validate current Wrath invisible/smoked/untargetable interaction and live information exposure; no hidden-health forecasts were implemented.
- Validate actual Nimbus first strike, player ownership, closest-unit targeting and copied Bolt dependency. Validate Bolt ground closest-hero/AoE talent behavior and true sight at recent last-seen locations.
- Validate Jump facing, movement speed interaction and shock target priority; current Shard toggle must preserve invisibility and remain legal under silence. No game launched.

Focused verification
- Fengari tests/zuus_ability_spec.lua passed 118 native/copied positive and negative cases plus unknown dispatch, optional missing siblings, all current availability flags and independent Arc casting.
- Scenarios verify exact Lens boundaries, damage/regen, ranged last hits/Glyph/packs, human ally peel, unit/point shape and interception, recent/stale/out-of-range reveal, visible global kills and multiple reflector survival, global allied pressure, Nimbus actual dependency/owned duplicate, safe Jump and locks, and silence/invisible Lightning Hands without queue/channel/stun bypass.
- AST comparison confirms build/skill/talent preference assignments unchanged for all 43 scoped heroes; full integration and Valve checks passed.
- Float timing regression: integer fixture truncates values; Nimbus2.5s and Jump0.5s prediction now use GetSpecialValueFloat and moving-target boundary cases pass.
- Pinned localization3365 verifies modifier_puck_coiled; movement guard uses actual current name and focused scenarios pass.
- Final peer timing regression: actual modifier index/duration query rejects interrupt-only casts when teleport remaining0.1s is shorter than real spell arrival; remaining2s channel interrupt passes. Focused suite now 118 scenarios.

Framework integration
- Native/copied UseLightningHands is a narrow actual-toggle hook before normal silence/invisibility gates; ordinary spell logic retains its actor locks.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Zeus standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
