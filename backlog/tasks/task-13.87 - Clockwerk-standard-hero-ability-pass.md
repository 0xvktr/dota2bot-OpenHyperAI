---
id: TASK-13.87
title: 'Clockwerk: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:26'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_rattletrap.lua
  - tests/rattletrap_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_rattletrap.lua
  - bots/FunLib/rubick_hero/rattletrap.lua
  - tests/rattletrap_ability_spec.lua
  - bots/FunLib/clockwerk_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 127000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Clockwerk is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use actual spell shapes, observed upgrades and owned cogs, global Flare prediction, safe Hookshot collision geometry, available linked setup, and current Jetpack toggle state. Preserve native farm, objectives, scouting and item preparation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs rattletrap; https://dotacoach.gg/en/heroes/clockwerk and https://dotacoach.gg/en/heroes/counters/clockwerk (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Full Torte guide 128732275, Clockwerk Strategy/Counter Strategy and all Matchup synergy, gameplay and advanced item cards were read and checked against pinned KV and English localization.
- Battery Assault: 275 radius, observed Overclock radius 330, 10.5 second buff, 0.7 interval, nonimmune visible targets. Cogs: 215 formation radius, Overclock 330, trigger 185 or 115; current mana burn contributes half as damage.
- Rocket Flare: global point cast, 2250 speed, .3 cast point, 600 radius,200 damage. True sight is talent-dependent. Observed Overclock increases damage 35 percent only when its real source handle is available.
- Hookshot:3000 maximum base range,125 latch radius,175 stun area,6000 speed and .3 cast point; pierces debuff immunity. Safe real allied latches support retreat.
- Jetpack:6 second Shard buff,75 mana, movement bonus 20 percent with disarm and constrained turning; observed tracker permits ordinary toggle decisions. Overclock:Scepter 90 mana,18 second enhancement and subsequent 3 second movement/attack slow. Innate armor scaling and item consumption are outside ability automation.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Added shared decisions and replaced duplicated copied/native branches that assumed linked spells were always present. Canonical unknown recognition precedes GetBot and gates.
- Battery Assault now uses observed enhanced radius, rejects invisible and immune enemies, avoids duplicate active buffs and protects threatened human or bot allies regardless of role.
- Cogs suppression uses actual nearby cog units with the actor player ownership rather than an issued-command timer; current enhanced radius and trigger range are honored and threatened allies are not enclosed.
- Hookshot uses predicted latch collision width plus unit hull, recognizes allied, summoned and neutral blockers, rejects unsafe or out-of-range predicted arrival, and supports debuff-immune targets and real allied escape anchors. Empty neutral camps are never treated as latch targets.
- Rocket Flare finds visible global lethal targets, predicts cast plus flight time and allows regeneration before impact; current observed Overclock damage uses a real linked source. Native teamfight scouting, Roshan scouting, lane wave clearing and objective damage remain available.
- Jetpack and toggle guard actual active/tracker state and movement constraints. Overclock activates only when an actual available, affordable linked cast will benefit.
- Movement guards use the actual pinned English modifier_puck_coiled, replacing an inherited nonexistent Dream Coil modifier name; native and copied negative coverage was rerun.

Rejected or stale source claims
- Excluded obsolete Overclock reset/self stun/attack-speed claims, the Matchup assertion that Hookshot receives no upgrade, universal Flare true sight, and old facet benefits absent live KV.

Item follow-up observations for TASK-21
- TASK-21: Blade Mail and mobility support Cogs isolation; Euls/Force Staff enable escape; the current Overclock penalty is a nondispellable slow, so do not schedule BKB against an obsolete self stun. Armor Power consumes Chainmail but no item/build behavior was changed.

Enemy counterplay observations for TASK-24
- TASK-24: visible summon and ally collision can intercept Hookshot; summons dilute unenhanced Battery Assault; debuff immunity prevents Battery/Flare but not Hookshot and Cogs. Supports can force movement out of Cogs and Linken only concerns actual unit casts, not Hookshot.

Lobby validation checklist
- Confirm Hookshot collision categories and neutral unit visibility, predicted unit hull geometry, root/leash displacement behavior, and cast-range modifiers at maximum range.
- Confirm cog player ownership for copied casts and retained friendly trap geometry; canceled casts must not create suppression state.
- Confirm Jetpack active/tracker transition and toggle readiness with copied Shard handles. No pre-gate exception is installed.
- Confirm Overclock upgrades on actual copied siblings and no assumed linked abilities, plus global Flare projectile impact on moving heroes.

Focused verification
- Fengari:35 meaningful native/copied behavior scenarios passed.
- Lua 5.2 parser passed native, copied, companion and spec. Owned whitespace check passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Clockwerk standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
