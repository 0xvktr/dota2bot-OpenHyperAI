---
id: TASK-13.76
title: 'Phantom Lancer: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 16:17'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_phantom_lancer.lua
  - tests/phantom_lancer_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_phantom_lancer.lua
  - bots/FunLib/rubick_hero/phantom_lancer.lua
parent_task_id: TASK-13
priority: medium
ordinal: 116000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Phantom Lancer is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Prioritize Doppelganger defense before Spirit Lance, restore the usable Shard invisibility spell, use actual ranges and flight time, conserve Phantom Rush, and mirror independent stolen abilities.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs phantom_lancer; https://dotacoach.gg/en/heroes/phantom-lancer and https://dotacoach.gg/en/heroes/counters/phantom-lancer (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Fetched and read TDL guide 129093311, full Strategy/Counter Strategy and Matchup: https://dotacoach.gg/en/heroes/phantom-lancer and https://dotacoach.gg/en/heroes/counters/phantom-lancer.
- Valve Spirit Lance deals 100/160/220/280 magical damage, does not pierce immunity, has range 600/650/700/750, projectile speed 1000 and mana cost 120. Its illusion deals 15% damage; current Scepter does not add Lance bounces.
- Doppelganger has range 575 plus a 125 talent, costs 70 mana, disappears for one second, scatters within 325 radius, applies a basic dispel and creates eight-second illusions. Roots prevent casting; it cannot escape an existing stun, hex or Dismember.
- Phantom Rush is a toggle with minimum trigger distance 275, maximum distance 600/675/750/825 plus 575 from Scepter, movement speed 800 and evasion 20/30/40/50%. Current Scepter adds path collision and illusions after each 600 units traveled. No old Agility bonus is assumed.
- Juxtapose has a Shard active: eight seconds of invisibility, 15% movement speed, 75 mana and 18-second cooldown. Without the upgrade it is passive. Random illusion generation is excluded from reliable kill calculations.

Implemented behavior
- Doppelganger now handles urgent incoming projectiles, basic dispels and escape before offense, with actual range and checks around the random reappearance area. Routine farming does not consume this escape.
- Restored the previously disabled Juxtapose active through its actual active, visible handle. Copied invisibility does not assume native illusion passives.
- Lance uses actual Lens and unbroken Arcane Supremacy range, flight time and regeneration, plus immunity, reflection and protection checks. Ranged creep last hits reserve escape mana.
- Rush toggle conserves cooldown in early laning and retreat, re-enables useful engagements or farming, and preserves an ongoing Rush without conflicting movement orders. Toggle-off remains available while the cooldown is running.
- Added a four-spell copied handler with an exact supported-name gate and meaningful toggle decisions.

Rejected or stale source claims
- Rejected obsolete Octarine cast range, Nullifier disabling passives, Rush granting Agility and Scepter improving Lance.
- Rejected advice claiming escape during Dismember, that Viper has no area damage, that Rot does not hit illusions, or that current Scepter improves Lance.

Item follow-up observations for TASK-21
- TASK-21: Review Manta dispel and split push, Scepter Rush through distant creep lines, Shard escape, stats for illusions, and Bloodthorn pressure. Illusion inheritance and current item stats need separate verification. Builds are unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: Punish Doppelganger cooldown, use area damage and real-hero detection, avoid long low-mana engagements, and assess armor, Crimson Guard, ethereal defenses and debuff immunity against Lance.

Lobby validation checklist
- Validate Rush toggle behavior and stolen Rush inheritance, the one-second disappearance and random cliff reappearance, Shard disjoint timing and illusion generation. No live game validation was performed.

Focused verification
- Fengari tests/phantom_lancer_ability_spec.lua passed; native, copied handler and spec parsed as Lua 5.2. Cooldown toggle-off and actual Break handling were also tested.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 shared movement safety follow-up: pinned English localization explicitly names modifier_puck_coiled (Dream Coiled). Replaced inherited modifier_puck_dream_coil checks with the actual debuff name in this previously passed hero. This is a narrow API/mechanics correction; preference assignments remain intact. The final Queen of Pain → Zeus integrated suite covers these files; lobby movement validation remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Phantom Lancer standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
