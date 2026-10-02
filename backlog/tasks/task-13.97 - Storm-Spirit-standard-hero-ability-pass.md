---
id: TASK-13.97
title: 'Storm Spirit: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:49'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_storm_spirit.lua
  - tests/storm_spirit_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_storm_spirit.lua
  - bots/FunLib/rubick_hero/storm_spirit.lua
  - tests/storm_spirit_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 137000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Storm Spirit is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair moving Remnant cast shape and timing, exact Vortex upgrade shape, current Shard activation, full Ball travel cost with escape reserve, and precise legal spells during observed own flight.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs storm_spirit; https://dotacoach.gg/en/heroes/storm-spirit and https://dotacoach.gg/en/heroes/counters/storm-spirit (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native decisions, full Torte guide 129143802, Dotacoach Strategy/Counter Strategy and complete Matchup synergy, gameplay and advanced item cards. Mechanics verified against pinned Valve and localization.
- Remnant uses runtime point behavior or is_point_targeted=1, range 800, speed 300, activation delay 0.75 seconds, trigger radius 235, damage radius 300 and magical damage 100/160/220/280. A genuine no-target runtime fallback uses only local trigger coverage.
- Vortex is unit targeting at range 300 with cast point 0.3. Scepter changes it to a no-target 475 radius spell. Electric Rave is the separate current Shard handle with radius 750, three charges, twelve seconds, 100 mana and thirty-second cooldown; an actual active Overload handle is also supported.
- Ball is point targeting, root-disabled and invulnerable during travel. Localization explicitly allows spells/items during flight. Cost is 25+7.5% maximum mana plus (10+0.65% maximum mana) per 100 units; speed is 1400/1850/2300.

Implemented behavior
- Moving Remnants now receive valid point commands, predict materialization and travel, require actual trigger coverage and use magical regeneration-aware kill timing. Farm and boss casts use relevant point coverage; the native no-target command no longer wastes distant opportunities.
- Vortex checks actual unit range or Scepter radius, immunity, block/reflect eligibility and teleport time. Copied Scepter behavior depends on the real caster upgrade without a hero-name restriction.
- Shard activation follows an actual human or bot ally attack within the real activation radius, rejects disarm, passive/hidden/deactivated handles, Break and an existing live charge buff.
- Ball checks full initial and travel cost, safe predicted landing and a 600-unit escape reserve plus available Vortex/Remnant mana. Retreat uses a finite affordable safe escape point; roots and Coil prevent invalid jumps.
- Removed queued fixed-delay Ball/Vortex and the reversed Vortex/Remnant mana comparison. Ordinary follow-ups re-evaluate actual position each tick and select one legal action.
- UseBallFlightSpells is limited to actual own Ball modifier with matching source ability and caster. It permits only available Vortex, Rave, Remnant or actual active Overload, retains every other forbidden state, uses one direct supported spell command and never recasts Ball or performs unrelated actions.

Rejected or stale source claims
- The base KV still declares NO_TARGET for Remnant while its point special and current localization describe movement; use real runtime behavior/special instead of assuming the old shape.
- Old guide Nullifier mute and Kaya reduced-mana-cost claims are stale item advice and are not used to invent mana savings.
- A Matchup sentence claims Storm dispels Razor buffs by mobility. No such dispel was added.

Item follow-up observations for TASK-21
- TASK-21: Bottle and Soul Ring maintain mana; Orchid/Hex offer lockdown, BKB/Linkens protect commitment, Shard helps allied attacks and Scepter changes Vortex to AoE. Preserve purchases and shared item policy; compute spell affordability from verified mana values.

Enemy counterplay observations for TASK-24
- TASK-24: instant silence, roots, Doom, mana burn and unsafe commitments restrict Storm. Frontline allies and actual attacks create safe follow-up; debuff immunity blocks ordinary Vortex. Preserve escape mana against Anti-Mage and avoid Carapace/protected targets.

Lobby validation checklist
- No game was launched. Verify runtime Remnant POINT behavior and special, movement/activation timing and actual trigger coverage with range items.
- Verify own Ball modifier source exposure and direct Vortex/Remnant/Rave use during invulnerability. If source is unavailable, the narrow callback declines and ordinary observed-arrival follow-up remains available.
- Verify fractional Ball mana drain and reserve under amplification/cost modifiers; the policy uses conservative undiscounted pinned formula rather than assuming item savings.

Focused verification
- Focused native/copied Storm Spirit scenarios passed under Fengari.
- Valve ability check passed at 128 native heroes and 96 copied modules with zero findings; owned whitespace is clean.
- Meaningful scenarios cover moving point/no-target shapes, trigger coverage, regeneration and travel, farm clusters, exact range and Lens, Scepter AoE/block exemption, teleport timing, human ally Shard parity, passive/hidden handles, full Ball travel/reserve thresholds, unsafe/root landings, missing flight source, observed own flight and all other forbidden states, arrival follow-up and nil-first copied unknown dispatch.
- Shared callback integration and full suite remain root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Framework integration
- UseBallFlightSpells before native global invulnerability and Rubick occupied-state gates, with actual owned Ball modifier/source validation.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Storm Spirit standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
