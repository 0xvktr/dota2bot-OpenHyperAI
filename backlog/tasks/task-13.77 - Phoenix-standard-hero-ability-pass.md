---
id: TASK-13.77
title: 'Phoenix: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 16:17'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_phoenix.lua
  - tests/phoenix_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_phoenix.lua
  - bots/FunLib/rubick_hero/phoenix.lua
parent_task_id: TASK-13
priority: medium
ordinal: 117000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Phoenix is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use observed Dive movement and stop decisions, predicted Spirit launches, health-aware Ray damage and saves, conservative Supernova safety, independent stolen abilities and a precise Sun Ray callback during the egg.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs phoenix; https://dotacoach.gg/en/heroes/phoenix and https://dotacoach.gg/en/heroes/counters/phoenix (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Fetched and read TDL guide 222264754 and the full Strategy, Counter Strategy and Matchup sections: https://dotacoach.gg/en/heroes/phoenix and https://dotacoach.gg/en/heroes/counters/phoenix.
- Valve Icarus Dive length is 1100/1200/1300/1400 plus the 1000 talent, width 500 and collision radius 200, moving in an ellipse over two seconds. It costs 15% current HP and applies four seconds of magical burn at 20/40/60/80 per second. Roots prevent Dive.
- Fire Spirits grants five spirits for 20 seconds, with launch range 1400, radius 200 and speed 1000. Initial cost is 20% current HP and 100 mana. Burn lasts four seconds; launch uses its own special values rather than assuming the parent ability exists.
- Sun Ray is a 1200-length, 130-radius magical beam and does not pierce immunity. Damage and healing scale during its six-second duration. It consumes 5% current HP per second. Shard permits Sun Ray during Supernova.
- Supernova lasts six seconds with aura radius 1200. It requires 6/8/10 hero attacks to destroy, or 7/10/13 with Scepter, plus the attack-count talent. Its stun pierces immunity. The actual allied-target cast range is 450 despite stale 500-range tooltip text.

Implemented behavior
- Dive Stop requires the actual Dive modifier and an observed goal, then stops near a useful destination or during Rupture. It does not assume a guaranteed ellipse hit.
- Spirits launch during Dive and work independently of the parent handle. Actual range, radius, target prediction, pending projectile arrival and existing burn duration prevent repeated waste. Farming uses real local creep packs and health thresholds.
- Ray considers wounded allies, including human-controlled heroes, rejects Ice Blast healing and respects beam range. Stop and movement decisions account for HP, missing healing need and safe forward travel. Existing roam-mode sun_ray_target state is preserved.
- Supernova uses urgent self or ally saves and a conservative attack-rate/travel estimate at the actual Scepter range. Removed blind queued Spirit casts that delayed the save.
- Native ConsiderEggSunRay and copied ConsiderStolenEggSunRay require the actual egg hiding state and Shard. They bypass only that invulnerability and retain other locks, including engine IsNightmared.
- Added eight independent copied actives with exact name gating and optional sibling handles.

Rejected or stale source claims
- Rejected claims that Sun Ray is pure damage, armor reduction amplifies it, Dive escapes Overgrowth, silence cancels an already formed egg, or Oracle removes all burn damage automatically.
- Rejected old enemy Solar Crest debuffs and guaranteed full-channel Ray damage estimates.

Item follow-up observations for TASK-21
- TASK-21: Review Shiva setup, Halberd protection for the egg, Eul dispels before egg, Glimmer during Ray, Vessel/Urn sustain, Refresher second egg and Shard beam during egg. Builds are unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: Punish Dive cooldown, dodge Spirits and turn away from Ray, decide early whether to attack the egg or leave, avoid clustering, and assess attack speed, dispels, immunity, roots and Rupture.

Lobby validation checklist
- Validate conservative egg attacker estimates, transformed position and allied Scepter placement, Shard beam while invulnerable, pending Spirit flight and ellipse stopping. No live game validation was performed.

Focused verification
- Fengari tests/phoenix_ability_spec.lua passed; native, copied handler and spec parsed as Lua 5.2. Nightmare during egg and actual Break disabling Supremacy were also tested.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 shared movement safety follow-up: pinned English localization explicitly names modifier_puck_coiled (Dream Coiled). Replaced inherited modifier_puck_dream_coil checks with the actual debuff name in this previously passed hero. This is a narrow API/mechanics correction; preference assignments remain intact. The final Queen of Pain → Zeus integrated suite covers these files; lobby movement validation remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Phoenix standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
