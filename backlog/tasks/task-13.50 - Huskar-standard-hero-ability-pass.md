---
id: TASK-13.50
title: 'Huskar: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_huskar.lua
  - tests/huskar_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_huskar.lua
  - bots/FunLib/rubick_hero/huskar.lua
  - tests/huskar_ability_spec.lua
  - bots/FunLib/huskar_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 90000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Huskar is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Current health-cost spells, new Shard active dispel, safe Life Break and Spear autocast with native/copied parity.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs huskar; https://dotacoach.gg/en/heroes/huskar and https://dotacoach.gg/en/heroes/counters/huskar (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Inner Fire: no-target 500 radius, 0.35 s cast point, flat health cost 75/100/125/150 and magical damage 110/180/250/320; no Shard upgrade.
- Spears: attack/autocast, 2% maximum health cost, burn 4/8/12/16 plus 0.5% enemy max health each second for 9 s; no Roshan max-health burn.
- Berserker’s Blood: breakable passive, max bonus below 10% HP. Shard activatable=1, costs 30% current HP, basic dispel, 3 s delayed heal plus 3% max HP per debuff, 20 s cooldown.
- Life Break: immunity-piercing magical, 550 range with Scepter +250 live range bonus, 0.32/0.38/0.44 current-health damage and self cost; root-disallowed leap, 60% magic resistance while leaping, basic dispel.
- Scepter adds 3 s taunt; Blood Magic innate controls native health resource.

Implemented behavior
- Added current Shard Berserker’s Blood activation using precise live activatable-special guard; dispels roots and known basic negative buffs when health supports delayed recovery, avoids Ice Blast.
- Life Break respects actual cast range, root/disarm, reflection/block and dangerous Rupture/Blade Mail. Health floor is stricter with absent/broken regeneration or Ice Blast, including copied Life Break.
- Spear autocast updates even when health makes another attack uncastable; uses 2% max HP cost and actual attack range, immunity/ethereal/disarm checks. Copied Spears do not assume native Blood regeneration.
- Inner Fire uses shared current combat gates and health floor; retained native lane/farm/objective branches. Removed stale guaranteed four Pike Spears queue; item policy owns actual Pike use.
- Native ability handles resolve explicit current names; copied handler supports only active stealable Fire/Spears/Life Break and canonical dispatch returns.

Rejected or stale source claims
- Shard no longer makes Inner Fire usable during silence or adds healing; current Shard belongs to Berserker’s Blood.
- Unused old Inner Vitality definition and old talent commentary excluded.
- Matchup advice about freely jumping while rooted rejected by displacement restrictions; no guaranteed regeneration while broken/AA.

Item follow-up observations for TASK-21
- TASK-21: preserve current Armlet/BKB/Satanic health and attack uptime policy; Pike needs observed buff before repeated attacks.
- TASK-21: current Shard dispel changes health immediately and heals after 3 s; do not treat it as instant emergency heal.

Enemy counterplay observations for TASK-24
- TASK-24: Break and anti-heal make low-health dives unsafe; Rupture damages displacement.
- TASK-24: magic resistance reduces Spear/Life Break output; disarm and ethereal prevent Spear attacks.

Lobby validation checklist
- Validate Shard active component exposed on passive ability handle and actual basic dispel/heal timing.
- Validate live Scepter Life Break range and taunt on immunity.
- Validate health resource conversion for native versus copied ability and current Spear attack cost.

Focused verification
- Native/copied Fengari scenarios passed; four files parse as Lua 5.2.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Huskar standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
