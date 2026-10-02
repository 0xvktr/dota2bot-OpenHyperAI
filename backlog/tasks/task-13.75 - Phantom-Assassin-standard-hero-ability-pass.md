---
id: TASK-13.75
title: 'Phantom Assassin: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 16:17'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_phantom_assassin.lua
  - tests/phantom_assassin_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_phantom_assassin.lua
  - bots/FunLib/rubick_hero/phantom_assassin.lua
parent_task_id: TASK-13
priority: medium
ordinal: 115000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Phantom Assassin is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use reliable physical Dagger opportunities, safe charge-aware Phantom Strike, timely Blur, real Fan of Knives geometry and independent stolen actives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs phantom_assassin; https://dotacoach.gg/en/heroes/phantom-assassin and https://dotacoach.gg/en/heroes/counters/phantom-assassin (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Fetched and read TDL guide 128920907 and full Strategy, Counter Strategy and Matchup: https://dotacoach.gg/en/heroes/phantom-assassin and https://dotacoach.gg/en/heroes/counters/phantom-assassin.
- Valve Dagger has base physical damage 65/70/75/80 plus 30/45/60/75% attack damage and its talent, projectile speed 1200 and range 700/850/1000/1150. Random crits and procs are excluded from reliable kill estimates.
- Phantom Strike has two charges, restore time 21/18/15/12 seconds, range 650/750/850/950 plus the 200 talent, and attack speed 80/120/160/200 for three seconds plus its duration talent. Roots prevent casting.
- Blur is an innate active lasting 30 seconds, with radius 500, fade delay 0.8 and cooldown 45. Shard lowers cooldown to 35 and advances cooldowns by 60% on hero kills; no full reset, dispel or instant cast is assumed.
- Scepter Fan of Knives deals piercing physical damage based on 30% victim maximum HP, within radius 550 at speed 1000, and applies four seconds of Break. Immaterial passive evasion is distinct from Blur.

Implemented behavior
- Dagger uses actual range, flight time and regeneration, allows piercing physical damage against immune targets, and rejects ethereal, reflecting or protected victims. Added useful ranged last hits and correct boss target returns.
- Strike conserves farming charges, avoids refreshing an active attack-speed buff, supports friendly escape targets and checks roots, leash, Rupture, attackability and dangerous destinations.
- Blur handles incoming projectile disjoint, retreat, dangerous farming and approach with existing buff checks.
- Fan uses real maximum-health physical damage, predicted radius and upgrade/visibility guards. Added four independent copied actives and actual Break checks for Supremacy.

Rejected or stale source claims
- TDL old Mask of Madness disassembly/full cooldown resets rejected.
- Matchup Blur=evasion, Omniknight Degen Aura/Heavenly Grace, Snapfire armor reduction and Rolling Thunder disarm claims not encoded; current pinned mechanics override.

Item follow-up observations for TASK-21
- TASK21: Battle Fury cleave/farm, Desolator attack armor reduction, Basher chance, BKB freedom, Satanic dispel/lifesteal, Nullifier ethereal tools and Scepter passive-break use; chance procs not guaranteed damage, no build changes.

Enemy counterplay observations for TASK-24
- TASK-24: Armor, ethereal defenses, Force/Pike/Glimmer kiting, reflection, Carapace and control before BKB; Break and accuracy against passive evasion, plus vision in dangerous farming areas.

Lobby validation checklist
- Validate Strike charge restoration and stolen charge behavior, projectile disjoint timing, and Fan immunity, Break and protection interactions. No live game validation was performed.

Focused verification
- Fengari tests/phantom_assassin_ability_spec.lua passed; Lua5.2 native/copied/spec parsed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 shared movement safety follow-up: pinned English localization explicitly names modifier_puck_coiled (Dream Coiled). Replaced inherited modifier_puck_dream_coil checks with the actual debuff name in this previously passed hero. This is a narrow API/mechanics correction; preference assignments remain intact. The final Queen of Pain → Zeus integrated suite covers these files; lobby movement validation remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Phantom Assassin standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
