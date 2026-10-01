---
id: TASK-13.26
title: 'Disruptor: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:04'
updated_date: '2026-10-01 17:28'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_disruptor.lua
  - bots/FunLib/rubick_hero/disruptor.lua
  - tests/disruptor_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 66000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Disruptor is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Preserve D2PT prefixes. Audit pinned Valve cf0d37a KV/localization, TDL128871463 (7.41f) and full dotacoach Disruptor Strategy, Counter Strategy and Matchup advice.
2. Prioritize actual Glimpse and Storm interrupts before damage spells. Observe visible hero positions against four-second backtrack time for catch/save/TP arrival decisions; never assume unseen historical or future return positions. Use legal ranges and targeted reflection guards.
3. Predict Kinetic Field at cast point plus one-second formation, retain Storm-first instant silence with budgeted linked Field follow-up at their shared legal range, and support standalone Storm/Field casts without linked-spell dependencies. Refresh stolen handles every invocation.
4. Use Thunder Strike timed mitigated damage with strike progression, vision/harass/farming/objective value and no duplicate debuff; restore legal illusion Glimpse. Explicitly decline current vector Kinetic Fence until a verified two-endpoint bot API exists; stale Thunder Strike Shard ground targeting is excluded.
5. Add native/copy scenarios and marker, run focused parse/Valve/whitespace checks; record source, exclusions, implementation, lobby and shared-limit notes. Parent owns shared integration/full suite/status.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Sources: pinned npc_dota_hero_disruptor.txt and abilities_english.txt; TDL workshop128871463 Position5 / 7.41f; https://dotacoach.gg/en/heroes/disruptor and https://dotacoach.gg/en/heroes/counters/disruptor, complete Strategy/Counter and gameplay synergy/items/counters. Verified four-second Glimpse backtrack and illusion destruction; Field350 radius and one-second formation; Storm550 radius, instant silence and Scepter item mute, cannot affect already-immune enemies; independent vector Fence1200 length/current Shard. Exclude old Thunder Strike Shard ground/extra-range tips (KVHasShardUpgrade0), old Solar Crest enemy use, Arcane Boots disassembly and unverified blanket undodgeable Glimpse. Thunder Strike talent is progressive strike_damage_bonus, not simply added base damage. Generic initiation/Refresher/Atos and enemy counterplay belong TASK-21/TASK-24.

Implemented native and new dedicated Rubick handlers with all D2PT prefixes preserved. Both targeted spells use real raw cast ranges plus active Lens/unbroken Supremacy, explicit Counterspell and ally-Counterspell guards, visibility/immunity and target checks. Glimpse interrupts without history; actual threatening illusions can be removed despite the general Advanced helper excluding illusions. Catch/save/recent-TP-arrival decisions require continuous observed visible samples bracketing the real four-second backtrack; gaps/time rollback reset history, large discontinuities cannot be interpolated, and enemy already under Storm is not rescued. The exported ObserveGlimpseHistory refreshes and requires an actual trained non-null non-hidden Glimpse but does not require cooldown readiness; root wires an early Rubick tick hook so cooldown observations are preserved. Freshly stolen ability or visibility gaps deliberately require four seconds of new observations. No unseen return location or Glimpse travel/damage formula is fabricated.
Storm works standalone for interrupt/teamfight/core control; it applies before any linked Field to silence or Scepter-mute immediately. Field uses full cast+one-second formation prediction; linked Field uses live refreshed handles, whole mana budget decided before issuing Storm, legal range and predicted area occupancy. Thunder Strike checks progressive talent sum base*n+bonus*n*(n-1)/2, full strike-completion delay for regen/mitigation-aware kills, avoids duplicate debuffs, uses durable clustered waves and actual objective entities. Current vector Kinetic Fence is recognized and explicitly returns false rather than issuing an invalid point cast or generic fallback. Normal channels/queues are preserved.
Verified Disruptor ability scenarios passed native/copy, including cooldown observation, no-history/fog/discontinuity refusal, range/break, actual illusion, linked-handle removal, formation escape and mana295/294 boundaries. Lua5.1 and owned whitespace pass; pinned Valve scan128 heroes27 copies0 findings at checkpoint. Parent owns shared hook/runner/full suite and final task lifecycle.
Lobby checks: validate visible-history sampling cadence across Think throttling, precise Glimpse actual backtrack/travel and TP arrival timing, reflection and invulnerability dodges, illusion destruction, one-second Field formation and movement escape, Storm-first/Field queue timing and independent stolen slots, Scepter mute before enemy BKB activation and no effect through already-active immunity, progressive strikes and real boss spellblock. Vector Fence remains a documented capability gap until verified two-endpoint bot action exists. Engine lobby not launched.
TASK-21 candidates: Blink Storm before BKB activation (rooted/Ruptured/hazard/mana safety), Atos/Euls setup before delayed Field, support Glimmer/Force placement, Refresher only after first Storm with full second-combo budget. TASK-24 candidates: avoid visible TP arrivals, leave Field area during formation, disperse Storm clusters, activate immunity before Scepter mute, movement/dispels around tracked Glimpse; do not treat Glimpse as blanket undodgeable or Force as crossing established Field.

Final verification after all review repairs (2026-10-01): node tests/run-builds.cjs exited0; all five hero spec exact markers verified, 358 Lua files parsed, pinned Valve audit128 native heroes/27 Rubick copies/0 findings, 127 role tables, 112 specialized dispatches,64 Rubick behavior cases and272 purchase lists. git diff --check passed. All five original build/skill/talent prefixes remain byte-identical to HEAD. New handlers and early hooks are integrated; existing prior-batch scenarios still pass. TASK21/24 observations recorded. No lobby launched; standard pass handed off as Needs In-Game Test with capability limits above.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Disruptor native and dedicated Rubick logic improves interrupts, observed Glimpse catch/save/arrival decisions, progressive Thunder Strike damage, delayed Field and budgeted Storm/Field sequencing. Rubick observes history during cooldown/channel gates; no unseen past positions are invented. Builds retained. Hero scenarios, final full suite and Valve check pass. Current vector Fence is withheld pending verified endpoint API; lobby timing checks recorded.
<!-- SECTION:FINAL_SUMMARY:END -->
