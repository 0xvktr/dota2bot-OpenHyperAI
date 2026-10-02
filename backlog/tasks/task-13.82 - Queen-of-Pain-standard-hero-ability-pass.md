---
id: TASK-13.82
title: 'Queen of Pain: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:13'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_queenofpain.lua
  - tests/queenofpain_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_queenofpain.lua
  - bots/FunLib/rubick_hero/queenofpain.lua
  - tests/queenofpain_ability_spec.lua
  - bots/FunLib/queenofpain_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 122000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Queen of Pain is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use current Shadow Strike and Scepter refresh, health-aware Scream, directional pure Sonic Wave, and safe bounded Blink with real linked follow-up availability. Preserve farming and item preparation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs queenofpain; https://dotacoach.gg/en/heroes/queen-of-pain and https://dotacoach.gg/en/heroes/counters/queen-of-pain (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Shadow Strike: 600 maximum base range, 140 initial damage, 16 second debuff; Scepter live AoE 300 and generate_scream. Delayed ticks are not treated as immediate lethal damage.
- Blink: 1300 maximum base displacement, 200 minimum distance, 65 mana; root and known movement leash/Rupture guards. Shard effects are passive consequences of the cast.
- Scream: 600 radius, 345 base damage and 25 percent raw hero damage reflected nonlethally to self; current Succubus lifesteal is not assumed for copied spells.
- Sonic Wave: pure damage 625, 700 direction cast range, 900 travel distance and projectile speed, widening 100 to 450 area. Missing spells and unavailable upgrades are not presumed.
- Full Torte guide, Dotacoach Strategy and Counter Strategy, and Matchup synergy, gameplay and advanced item cards were read and compared to pinned mechanics.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Added shared native/copied ability decisions and canonical copied return behavior for all four castable spells.
- Replaced delayed-damage Shadow Strike kill estimates with initial damage and verified Scepter refresh burst only when the linked Scream exists.
- Added Scream health budget across observed real susceptible heroes; preserved lethal opportunities and native lane last hits.
- Replaced circular Sonic Wave estimates and inflated damage with predicted directional geometry and actual pure damage, including debuff-immune enemies.
- Prioritized emergency Blink, bounded its destination, rejected tower/Chronosphere/Black Hole destinations and required an affordable real follow-up before offensive Blink.
- Preserved native farm and objective routes, corrected a stale undefined farm target, and rejected magic-immune objective casts.
- Projectile lethal decisions use cast time plus travel time and account for target regeneration before impact.
- Movement guards use the actual pinned English modifier_puck_coiled, replacing an inherited nonexistent Dream Coil modifier name; native and copied negative coverage was rerun.

Rejected or stale source claims
- Excluded guide references to obsolete cooldown reduction and spell block talents, older facets, guaranteed Blink prevention from ordinary damage, and unsupported reflected damage claims.

Item follow-up observations for TASK-21
- TASK-21: dispelling silence through existing BKB/Euls policy enables Blink. Scream self reflection grants no spell lifesteal, so item healing must not be credited against that self damage. No item/build changes.

Enemy counterplay observations for TASK-24
- TASK-24: magic immunity prevents Shadow Strike and Scream but Sonic Wave pierces it; movement roots and leashes constrain Blink. Unit spell block differs from live Scepter point targeting. No generic counterplay changes.

Lobby validation checklist
- Confirm dynamic Scepter point cast shape and generated Scream source, damage and self reflection with native and copied abilities.
- Confirm Sonic Wave end caps and actual projectile collision geometry; the offline model uses conservative travel projection through 900 distance.
- Confirm Blink range modifiers and collision placement at cliffs, as movement is conservatively bounded by the live ability range without stretching displacement through cast bonuses.

Focused verification
- Fengari: 30 meaningful native/copied behavior scenarios passed, including regeneration before projectile impact.
- Lua 5.2 parsing passed for native, copied, companion and spec; owned diff whitespace check passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Queen of Pain standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
