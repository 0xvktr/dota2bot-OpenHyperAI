---
id: TASK-13.55
title: 'Kunkka: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_kunkka.lua
  - tests/kunkka_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_kunkka.lua
  - bots/FunLib/rubick_hero/kunkka.lua
  - tests/kunkka_ability_spec.lua
  - bots/FunLib/kunkka_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 95000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kunkka is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Replace fixed queued combo timers with an observed own X mark, current spell predictions, one cast per reconsideration, and confirmed spell cooldown before timed Return. Correct Tidebringer geometry/attack gates, Ghostship protection and Shard wave direction, and add independent copied handlers.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs kunkka; https://dotacoach.gg/en/heroes/kunkka and https://dotacoach.gg/en/heroes/counters/kunkka (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Torrent: point 1300 range, 250 radius, 0.4 cast plus 1.6 delay, current 110/180/250/320 magical damage over knockup; actual future point must be in range.
- Tidebringer: active autocast attack, physical, Break/disarm/ethereal gates, real attacker range; trapezoid 150 starting/500–650 ending width, 650–1025 distance and 150% cleave.
- X Marks: actual unit hero 550/700/850/1000 range, 0.4 cast, 3-second enemy/6-second ally mark; linked Return is only used for tracked own enemy mark.
- Return: no target, 0.2 cast, only actual castable handle plus observed own mark; timed trigger requires actual source cooldown after issued Torrent/Ship.
- Ghostship: point 1000 cast, 0.3 cast plus 3.1 impact delay, 450 radius, 2000 path, 350/475/600 magical impact. Rum factor 2 buffs allies actually on its path; Scepter fleet count 2, interval 2.5 and 40% cannon damage are engine resolved, not guaranteed total damage.
- Tidal Wave: Shard actual ready point, 1050 cast, 0.2 cast, 700 speed, 750 radius, 180 magic damage and 600 displacement; safe outward aim for pursuer peel/interrupt/kill.
- Admiral’s Rum: current breakable innate threshold 65%, delayed damage 18%, buff for 5 seconds; Ship doubles it and cannot stack with other Rum sources.
- Torrent Storm: definition remains hidden/unassigned, IsGrantedByScepter=0; no fabricated current native/copy availability.

Implemented behavior
- Removed old three blind queues, manually fixed Return delays, and stale pending-state blocking. Native resolves the recorded enemy mark only once observed, then Ship/Torrent individually when actually legal and affordable. The observed modifier must report the exact issued source handle through GetModifierSourceAbility; foreign marks cannot be adopted.
- Recorded Torrent/Ship impact times use live cast point/special values; cooldown confirmation prevents canceled/rejected casts from starting timed Return. Lost, stale, dead, immune or unobserved marks cannot return.
- Added actual true-range full-delay prediction for standalone Torrent/Ship and active block/reflect checks for X. Native farm/defend/roshan and Tidebringer objective attacks remain supported.
- Tidebringer native autocast enabled; active primary must be actually within attack reach and physically attackable. A distant hero needs a real cleave primary and correct trapezoid geometry, not arbitrary facing angles.
- Ghostship now works for two enemies or a susceptible enemy plus a wounded ally actually along its path; no existing Rum protection duplicate or fake immunity benefit.
- Wave uses current values and outward peel direction; no unsupported vector endpoint call or unverified reverse pull. New native/copied shared helper and six active handlers; no assumed passive/linked source spells.

Rejected or stale source claims
- Fixed combo delays 2.25/3.35/1.95 and queued cast locations are obsolete with 3-second X and current cast timings.
- Torrent Storm is not current Scepter active; old guides referring to it excluded.
- Old Rum double-health/full immunity and obsolete facets excluded; current Ship delays 36% incoming damage for 10 seconds through 2x current innate at base level.
- Tidebringer Familiars instant-clear, X on Lone Druid bear, guaranteed instant X channel cancel and armor-sensitive pure damage claims are not trusted as generic decisions.

Item follow-up observations for TASK-21
- TASK-21: builds untouched; ordinary native spells pass actual handles into item-aware queued preparation. Observed mark combo casts directly so item prep cannot shift recorded timing.
- BKB interruption protection, Blink/Shadow Blade initiation, Armlet Tidebringer damage and Refresher mana are follow-up item-policy observations. X-fountain-TP routines need coordinated existing TP/item travel policy rather than an unverified ability-only queue.
- Scepter current fleet/cannon upgrade is recognized as engine behavior; no multiplicative guaranteed damage assumption.

Enemy counterplay observations for TASK-24
- TASK-24: X block/reflect/immunity, delayed spell prediction, Break/disarm and ethereal primary gates prevent wasted casts. Eul/invulnerability or BKB losing an observed mark invalidates combo state.
- Group control from Tide/Disruptor/Jakiro/Snapfire and allied Rum path benefit inform real setup, rather than Matchup win-rate deltas.
- Wave peels outward and avoids displacing an active observed X combo; offensive reverse-pull geometry remains lobby follow-up.

Lobby validation checklist
- Validate enemy mark point capture on first observation and exact Return interrupt semantics for stationary channels. Mark ownership is already guarded by the exact source ability handle.
- Validate cast-to-cooldown confirmation and timing margins with real server frames, animation backswing and latency; interrupted/canceled spells must never start Return.
- Validate native/copy X Return linked availability and independent two-stolen-spell ordering.
- Validate real Tidebringer trapezoid starting origin/width and attack range overrides for ranged copied attackers.
- Validate Ghostship touched ally path/Rum application and Scepter fleet/cannon damage; validate current Shard wave spawn/reverse-pull geometry.

Focused verification
Kunkka paired native/copied Fengari scenarios passed; 4 Lua 5.2 files parsed; targeted diff check clean. Scenarios include observed mark instead of pre-cast guess, Return timing/canceled cast, unrelated channel/lost state, current range/full predictions, immunity/block/reflect, Rum path, physical cleave geometry/Break/disarm and Wave peel. The canceled-own-X and foreign-mark regression also passes for native and copied handlers.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Kunkka standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
