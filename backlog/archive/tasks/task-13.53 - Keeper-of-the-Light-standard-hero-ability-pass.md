---
id: TASK-13.53
title: 'Keeper of the Light: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_keeper_of_the_light.lua
  - tests/keeper_of_the_light_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_keeper_of_the_light.lua
  - bots/FunLib/rubick_hero/keeper_of_the_light.lua
  - tests/keeper_of_the_light_ability_spec.lua
  - bots/FunLib/keeper_of_the_light_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 93000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Keeper of the Light is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Actual channel release, independent current spells, useful Chakra cooldowns, correct peel geometry and noninterrupting Wisp.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs keeper_of_the_light; https://dotacoach.gg/en/heroes/keeper-of-the-light and https://dotacoach.gg/en/heroes/counters/keeper-of-the-light (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Illuminate: 1800 cast versus 1550 actual travel range, 400 radius, 900 speed, 3 s max channel and 185/290/395/500 damage.
- Blind: 500/575/650/725 range, 425/450/475/500 radius, 45% miss for 4 s, knockback to edge with minimum 175; noninterrupting.
- Chakra: 900 range, 105/170/235/300 restore and 2.5/3.5/4.5/5.5 s basic cooldown reduction; self 30% more, ultimate excluded. Current strong dispel requires talent.
- Spirit: 40/45/50 s, 100/175/250 range bonus and 60% Illuminate heal, Shard adds 40% heal and two Solar Bind charges.
- Solar Bind: 750 range, 6 s and magic resistance reduction 20/30/40. Wisp: 800 range, 725 radius, noninterrupting pull, 7 hits and 13.4 s. Recall cached unused variant has 6/5/4 s delay and only actual ready handles considered.

Implemented behavior
- Repaired unreachable Illuminate early release via precise UseIlluminateRelease callback: records cast origin/line/source/time, permits only actual own channel or live separate spirit wave, predicts wave interception and accumulated damage, rejects unrelated channels/casts/queues/stale state. A separate Spirit wave cannot interrupt an unrelated active ability animation.
- Illuminate combat prediction includes real charge and flight; base channels avoid nearby threats. Existing native farm/objective/laning routes remain, Spirit can heal wounded allies on actual wave path.
- Chakra scores missing mana and observed allied basic cooldowns, excludes ultimates/passives/hidden spells and uses current self bonus; strong dispel prioritizes disabled in-range allies.
- Blind origin is on the ally side when peeling so displacement moves away; offensive origin behind enemy is range bounded.
- Wisp no longer claims TP interruption, counts actual susceptible heroes. Spirit Form offers combat/heal utility rather than requiring solo lethal attack estimate, does not refresh live form.
- Solar Bind shared native/copy rules obey range/block/reflection/live debuff; copied spells never require missing linked form. Recall conservative native route retained only when castable.

Rejected or stale source claims
- Removed Mana Leak/Special Reserve innate advice, deprecated Recall facet assumptions and zero-cooldown guarantees.
- Wisp/Blind displacements do not interrupt channels; old TP cancellation and broad hard-disable synergy claims rejected.
- Illuminate healing currently 60% in Form, 100% with Shard; no daylight-only or heal outside Form assumption.

Item follow-up observations for TASK-21
- TASK-21: Holy Locket supports current Spirit Illuminate healing; Shard adds heal and charges, Scepter supplies noninterrupting Wisp grouping.
- TASK-21: Chakra reduces basic ability cooldowns, not item or ultimate cooldowns; Lens plus active Form range read from actual source values.

Enemy counterplay observations for TASK-24
- TASK-24: jump base Illuminate channels and use immunity/magic resistance; Wisp is an attackable noninterrupting pull.
- TASK-24: Lotus/Linkens stop targeted Solar Bind, but ground Blind cannot be reflected as a unit spell.

Lobby validation checklist
- Validate root framework UseIlluminateRelease callback during actual base channel and separate Spirit wave; no unrelated channel cancellation.
- Validate recorded source/origin with engine wave projectile and early lethal threshold.
- Validate Form cast-range modifier and independent copied Spirit spell grants; Recall currently not assigned by native slots.

Focused verification
- Native/copied Fengari passed; four files parse as Lua 5.2. Void API correction spec also passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Keeper Of The Light standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
