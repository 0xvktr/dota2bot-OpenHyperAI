---
id: TASK-13.41
title: 'Night Stalker: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:02'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_night_stalker.lua
  - tests/night_stalker_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_night_stalker.lua
  - bots/FunLib/rubick_hero/night_stalker.lua
  - tests/night_stalker_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 81000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Night Stalker is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Real nighttime/range Fear and Void opportunity priorities, Shard cluster/ranged last hit, legal nonancient Midnight Feast recovery and offensive/escape Dark Ascension; stolen independent actives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs night_stalker; https://dotacoach.gg/en/heroes/night-stalker and https://dotacoach.gg/en/heroes/counters/night-stalker (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- TDL guide 128741319 fetched, full Strategy/Counter/Matchup: https://dotacoach.gg/en/heroes/night-stalker and https://dotacoach.gg/en/heroes/counters/night-stalker.
- Valve Void range 525 damage 80/160/240/320, night ministun, Shard cast radius 400; Fear radius 350 DPS 25/30/35/40, not Scepter toggle.
- Midnight Feast runtime active only at night/nonancient enemy 125, hp 10/15/20/25%, mp 10/12/14/16%,0 mana, underlying KV passive (require live castability).
- Dark Ascension flight/damage 30 s; no reset on cast; Scepter Hunter basic resets on hero kill. Engine GetTimeOfDay and active darkness replace fixed-clock assumptions.

Implemented behavior
- Fear silences reachable channel/escape threats before ultimate; actual radius, immune/silenced and existing aura guards.
- Void interrupts during real night or artificial darkness, advanced target/immunity/range gates; Shard picks accessible cluster center even when affected units beyond 525.
- Restored ranged creep Void last-hit; remove out-of-range retreat target casts.
- Feast recovers outside farm-only mode, no day/ancient/allied/out-of-range consumption and no heal-only use through Ice Blast.
- Dark Ascension broader engage/escape flight, existingbuff and follow-up mana guards; native channel/pending gate preserved.
- New independent stolen four-actives handler.

Rejected or stale source claims
- TDL guide Dark Ascension resets basics on cast rejected; current Scepter innate hero-kill reset.
- Old Shard eat ancients rejected: current Shard empowers Void, Feast nonancient only.
- Solar Crest enemy armor and passive Nullifier descriptions need item KV checking; not encoded.

Item follow-up observations for TASK-21
- TASK 21: Blink/Harpoon to get silence aura onto backline; BKB maintain attacks, Nullifier remove dispellable defenses. Existing generic item initiation remains responsible.

Enemy counterplay observations for TASK-24
- TASK 24: leave 350 Fear aura with displacement, fight before night/Dark, use Break on Hunter; avoid hiding behind trees vs flying vision.

Lobby validation checklist
- Runtime Midnight Feast IsPassive/activation changes at night.
- Artificial night from Dark Ascension/Eclipse and Void ministun.
- Fear-before-item-blink coordination and Shard AoE targeting.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/night_stalker_ability_spec.lua passed; native/handler/spec Lua 5.2 parsed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Night Stalker standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
