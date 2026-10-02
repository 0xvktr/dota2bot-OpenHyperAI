---
id: TASK-13.51
title: 'Jakiro: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_jakiro.lua
  - tests/jakiro_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_jakiro.lua
  - bots/FunLib/rubick_hero/jakiro.lua
  - tests/jakiro_ability_spec.lua
  - bots/FunLib/jakiro_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 91000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Jakiro is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Actual line geometry, delays, current liquid attack choices and Scepter Macropyre immunity rules.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs jakiro; https://dotacoach.gg/en/heroes/jakiro and https://dotacoach.gg/en/heroes/counters/jakiro (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Breath: 850 range, 0.35 s cast point, 1050 speed, 5 s burn at 20/40/60/80 DPS; point cast ignores targeted block/reflection.
- Ice Path: 1100 range, 0.65 s cast point plus 0.2 s formation delay, 150 radius; stun 1.25/1.5/1.75/2 and path 3/3.5/4/4.5 s.
- Liquid Fire/Frost: attack spells, 600 cast range, 20 mana, shared cooldown; Shard live shares_cooldown=0 and mana=0. Fire affects buildings, Frost does not.
- Macropyre: 1400 range, 500 width, 100/150/200 DPS, 10 s duration. Scepter sets pure_damage_type and pierces_magic_immunity=1, duration +5 and ice edge slow 60%.
- Double Trouble innate is passive and not assumed on copied attacks; hidden Ice Path detonation has zero current values and is not automated.

Implemented behavior
- Shared point line decisions count enemies along actual path rather than circles; prediction includes actual cast/formation/travel delay and endpoints obey real Lens/Supremacy range.
- Breath lethal evaluation uses full current duration times DPS and retains native waveclear/objective modes.
- Ice Path no longer targets channeling enemies beyond cast range using +200 padding.
- Macropyre uses held enemies or actual line clusters, supports current pure immunity-piercing Scepter flags and removes arbitrary caster HP>50% requirement.
- Liquid attacks honor disarm/ethereal and live debuffs; Frost amplification follows Ice Path before burst, Fire handles buildings. Copied handlers work independently with canonical result contract.

Rejected or stale source claims
- Torte zero-mana Liquid Fire requires current Shard; ordinary cost is 20.
- Frost does not affect towers and current base damage does not contain guaranteed max-health scaling; max-health damage is a talent.
- Old attack range talent names, unsupported hidden detonation and generic claims all actives ground-target ignored.

Item follow-up observations for TASK-21
- TASK-21: Euls/Atos can set actual delayed Ice Path; do not enqueue premature ground prediction before observation.
- TASK-21: Shard removes shared Liquid cooldown and mana via live values; Scepter changes Macro damage/immunity rather than merely adding cosmetic walls.

Enemy counterplay observations for TASK-24
- TASK-24: spread perpendicular to line spells, reposition out of Macro and exploit long cast points.
- TASK-24: ordinary immunity blocks spell debuffs; Scepter Macro pierces and deals pure.

Lobby validation checklist
- Validate current Liquid attack cast range and shared cooldown removal with Shard.
- Validate Ice Path formation and line extension at real endpoint.
- Validate Scepter pure immunity piercing and ice edges; copied spells do not presume Double Trouble.

Focused verification
- Native/copied Fengari passed; four files parse as Lua 5.2.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Jakiro standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
