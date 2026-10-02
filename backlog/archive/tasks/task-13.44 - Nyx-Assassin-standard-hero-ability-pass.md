---
id: TASK-13.44
title: 'Nyx Assassin: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:07'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_nyx_assassin.lua
  - tests/nyx_assassin_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_nyx_assassin.lua
  - bots/FunLib/rubick_hero/nyx_assassin.lua
  - tests/nyx_assassin_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 84000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nyx Assassin is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Protect Vendetta with Carapace, line predict Impale and actual burrow ranges; conservative Mind Flare after affordable damage openers, safe siege Burrow and timely Unburrow; mirror stolen actives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs nyx_assassin; https://dotacoach.gg/en/heroes/nyx-assassin and https://dotacoach.gg/en/heroes/counters/nyx-assassin (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- TDL guide 128932114 fetched; complete Strategy/Counter and Matchup: https://dotacoach.gg/en/heroes/nyx-assassin and https://dotacoach.gg/en/heroes/counters/nyx-assassin.
- Valve Impale point/line 750, speed 1600,width 140, damage 100/160/220/280 and stun 1.1/1.4/1.7/2; Mind Flare range 800, maximum mana 25/30/35/40%, echo 15% over 15 s, talentAoE 600.
- Carapace preserves Vendetta and negates/reflects first source damage for 2 s; burrow instant stun 400.
- Vendetta pure 300/400/500, break 4 s base, Shard 15 s haste/pathing, rangebonus 75; Burrow cast 1.5/range+500 stationary; linked handles optional.
- No exact damage attribution API: echo kept conservative, no guessed previous-health-loss math.

Implemented behavior
- Carapace before Vendetta/other spells, active buff guard, incoming/ongoing damage and burrow victims; works while invisible.
- Impale uses travel prediction and line geometry, clusters/farm rays, real Lens and Burrow range; urgent channel interrupts may break Vendetta while routine spells preserve attack.
- Mind Flare real range/advanced immunity/reflect/block gates; conservative base kill, delay feasible Impale/Dagon opener and select teamfight AoE/high mana fallback.
- Safe useful Burrow windup and release on retreat/no targets; nil/hidden activation guards.
- Vendetta resets stale assassination metadata, requires attackable target/no disarm; native innate untouched.
- New independent Rubick six-actives handler.

Rejected or stale source claims
- TDL guide legacy Intelligence Mana Burn and Shard needed for Break rejected; current Mind Flare maximum mana and base Vendetta Break.
- Site Mana Burn facet/Nyxth Sense/Strafe damage and passive Carapace wording stale; new innate Neuro Sting burn 12%, no extra spell assumptions.

Item follow-up observations for TASK-21
- TASK 21: Dagon before Mind Flare when targetheld/range/mana allow; Ethereal Blade after Vendetta attack; Euls landing time Impale, Blink/Force for approach/escape.

Enemy counterplay observations for TASK-24
- TASK 24: avoid triggering active Carapace, debuff immunity versus nonpiercing stuns; reveal Vendetta with detection and burst/control before escape.

Lobby validation checklist
- Burrow actual+500 range versus engine GetCastRange, firstdamage reflection and invisibility preservation.
- Mind Flare 15 s source attribution/600 AOE behavior; Dagon ordering with generic items.
- Stolen Burrow grants/retains linked Unburrow and independent Carapace.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/nyx_assassin_ability_spec.lua passed; Lua 5.2 native/stolen/spec parse passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Nyx Assassin standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
