---
id: TASK-13.40
title: 'Shadow Fiend: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 08:59'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_nevermore.lua
  - tests/nevermore_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_nevermore.lua
  - bots/FunLib/rubick_hero/nevermore.lua
  - tests/nevermore_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 80000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Shadow Fiend is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Update Feast for current collection mechanics, live facing Raze geometry/soul damage, Requiem timing/control opportunities and independent stolen spells.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs nevermore; https://dotacoach.gg/en/heroes/shadow-fiend and https://dotacoach.gg/en/heroes/counters/shadow-fiend (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- TDL guide 129081035 fetched; full Strategy/Counter/Matchup: https://dotacoach.gg/en/heroes/shadow-fiend and https://dotacoach.gg/en/heroes/counters/shadow-fiend.
- Valve Raze distance 200/450/700 radius 250 base 85/150/215/280 +2 per observed soul +35/50/65/80 per stack; cast 0.55; Shard slow 12 and hero hit cooldown 2.
- Feast has no soul requirement/cost, collection 600, speed 35/50/65/80, duration 8; base Necromastery maximum 20.
- Requiem radius 1000, windup 1.67 native, max souls 20, nonimmune fear; stolen NORMAL_WHEN_STOLEN own castpoint; Scepter return damage 100/heal 100 and cooldown 30 reduction.
- Reviewed full cast order/each consideration; item invisUlt combo and policy preparation retained.

Implemented behavior
- Removed unreachable 25-soul Feast condition; zero-soul early fights/farm, move-speed escape, attack/disarm and already-active guards.
- Raze uses own data for facing blast center and full predicted radius; soul and stack damage in kill estimates; one ranged last-hit can justify lane cast.
- Requiem supports held ally disables, Euls/Brew timing, nonimmune clusters, restrained escape fear; rejects 0 native souls and immune-only casts.
- Added independent stolen handlers; no sibling Raze/passive handles needed.

Rejected or stale source claims
- TDL guide says Scepter increases maximum souls; current Requiem max 20 and Scepter return/heal/cooldown changes only.
- Old Arcane Blink cast acceleration, Bloodthorn crit and Shadow Demon Soul Catcher guidance rejected.
- Site calls Requiem channeling; current spell has interruptible cast windup, no channel.

Item follow-up observations for TASK-21
- TASK 21: BKB before close Requiem, Blink/invisibility for positioning; maintain existing invisUlt coordination. Mask of Madness silence should not overlap required spells; Refresher needs mana for two casts.

Enemy counterplay observations for TASK-24
- TASK 24: flank/interrupt Requiem windup or leave radius; avoid facing triple Raze approach; armor vs Presence and magic resistance for spell burst.

Lobby validation checklist
- Windup interruption and Euls landing under cast-speed items.
- Raze facing prediction and per-soul spell damage including attack-damage talent.
- Stolen Requiem soul line behavior without native Necromastery, stolen Feast collection.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/nevermore_ability_spec.lua passed; native/stolen/spec Lua 5.2 parse passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Shadow Fiend standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
