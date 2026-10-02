---
id: TASK-13.73
title: 'Oracle: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_oracle.lua
  - tests/oracle_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_oracle.lua
  - bots/FunLib/rubick_hero/oracle.lua
  - tests/oracle_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 113000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Oracle is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Safe Promise/Edict/Flames combinations, purge supported enemy heals and basic ally debuffs, observed own Fortune channel release, true Rain centers; stolen parity.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs oracle; https://dotacoach.gg/en/heroes/oracle and https://dotacoach.gg/en/heroes/counters/oracle (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- TDL guide 344511398 fetched/read; full Strategy/Counter/Matchup https://dotacoach.gg/en/heroes/oracle and https://dotacoach.gg/en/heroes/counters/oracle.
- Valve Fortune 850/radius 350/damage 100..280, channel 2.5/projectile 1200, BASIC dispel/root 0.75..2.75, no stun or strong dispel.
- Edict 700/duration 3.5..5, magic resistance 100% and disarm; both sides dispellable, no debuff-immune allies.
- Flames 850/cast 0.1/mana 75,damage 90..360*enemy damage_modifier, regen 15..45 for 10 s, nonlethal allied initial damage; stacking healing.
- Promise 800/850/900,mana 100..200,duration 7/8.5/10,strong initial dispel and deferred healing+100%; not invulnerability.
- Rain 650/radius 650,duration 10,dps/hps 30,healamp 15%; Diviners Deck Scepter random passive not assumed.

Implemented behavior
- Urgent legal-range Promise respects current buff; independent Edict magical save, healing prep only when not sacrificing active attacks.
- Flames healing requires actual Edict or conservatively positive remaining Promise healing minus initial damage; excludes Ice Blast, BKB allies and late harmful Promise casts.
- Enemy Flames lethal or real affordable Fortune purge/projectile support; no assumed linked stolen spell; purge existing heal before repeating.
- Fortune dispels silence/roots/Vessel and selected enemy buffs, no blind queued Flames on its target; stored channel purpose and observed release support.
- Rain named Shard handle and real-range clamped centers; meaningful combined sustain/control clusters, includes allies beyond point-cast range.
- New five-actives Rubick module with exact unknown-name gate and independent channel callback.

Rejected or stale source claims
- TDL guide old Solar enemy armor/Arcane disassembly rejected.
- Matchup Scepter Promise/BAT steroid, Fortune strong Lasso dispel and spell-immunity Edict claims rejected; current Deck passive and Edict magic resistance only.

Item follow-up observations for TASK-21
- TASK 21: Lens/Blink safe timely saves, Locket/Salve heals during Promise, Glimmer reduces pending damage, Force defensive reposition and Aeon self protection; builds unchanged.

Enemy counterplay observations for TASK-24
- TASK 24: focus/silence save caster, antiheal near Promise expiry, pure/physical damage bypass Edict magic resistance; enemy dispels remove heal/Edict.

Lobby validation checklist
- Fortune early release Action_ClearActions(false), projectile-follow and invulnerable target engine behavior.
- Promise true damage/heal accounting and Edict allied attack tradeoffs; Deck actual spell/heal amplification.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/oracle_ability_spec.lua passed; native/stolen/spec Lua 5.2 parse passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Oracle standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
