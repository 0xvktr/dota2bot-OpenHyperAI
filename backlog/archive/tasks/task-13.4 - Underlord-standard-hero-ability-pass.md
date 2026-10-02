---
id: TASK-13.4
title: 'Underlord: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 13:29'
updated_date: '2026-10-01 14:05'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_abyssal_underlord.lua
  - bots/FunLib/rubick_hero/abyssal_underlord.lua
  - >-
    https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_abyssal_underlord.txt
  - 'https://dotacoach.gg/en/heroes/underlord'
  - 'https://dotacoach.gg/en/heroes/counters/underlord'
  - tests/underlord_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_abyssal_underlord.lua
  - bots/FunLib/rubick_hero/abyssal_underlord.lua
  - bots/BotLib/hero_rubick.lua
  - bots/FunLib/rubick_utility.lua
  - tests/underlord_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 43000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Underlord is part of the next standard hero batch after Dazzle. Review current spell decisions and combos against guide strategy and current Valve mechanics, including the dedicated Rubick copy, to address weak or incorrect ability use.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against Valve definitions and localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and Matchup advice; findings and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the hero and applicable Rubick copy, with meaningful offline behavior scenarios
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and task is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Review current Valve slots/upgrade definitions/localization with Torte de Lini and dotacoach hero/Matchup strategy; record current mechanics and stale claims.
2. Correct Firestorm/Pit placement and combo follow-up, support Shard allied Firestorm and efficient wave farming, and repair safe Gate selection plus portal channel follow-through; mirror in the Rubick copy.
3. Add offline behavior scenarios for hero and stolen spells; run focused tests, then parent shared Valve/build checks and record lobby validation before Needs In-Game Test.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Sources and verification checklist (2026-10-01):
- Pinned Valve hero KV/localization at cf0d37a32c8df338a7832fd32a282747969e9a5f: active Firestorm/Pit/Atrophy/Gate slots and hidden portal_warp interaction. Firestorm point AoE range675/radius425; Pit range675/radius400, roots repeat every3.6s; Gate minimum distance1500, duration20s, unit-target warp channel3.5s, fountain offset1425. Shard adds allied unit Firestorm with extra/faster waves; Scepter belongs to Gate and spawns Pit. portal_warp is castable while hidden, ignores silence and is root-disabled.
- Torte de Lini fetched for abyssal_underlord (Workshop750410650, 7.41f): Pit into Firestorm, zone/reveal and clear clustered waves from level3, then jungle; Gate to join allies/objectives and escape early. Stale Dark Rift/old resistance-talent language excluded.
- dotacoach Strategy and Counter Strategy https://dotacoach.gg/en/heroes/underlord and full Matchup/core/counter-item sections https://dotacoach.gg/en/heroes/counters/underlord read. Guide suggests situational Firestorm before Pit/Atos; native order keeps Pit then Firestorm against an uncontrolled target, while existing allied disables trigger immediate Firestorm. Checklisted percent-health scaling, tower/wave defense, safe rotations/escape, mobile Shard storm, Gate Scepter global root and control follow-ups.
- Synergy setups retained as reviewed context: Spectre/mobile frontliner can carry Shard storm; Disruptor/Leshrac/Venge/AA control and follow-up complement AoE. Draft tables/builds untouched. Atos/cyclone control extension and anti-AoE/escape findings routed to TASK-21/TASK-24 rather than generic item/counterplay edits. Old Gleipnir terminology does not change the current D2PT build.

Implemented native and Rubick mechanics:
- Cast points are bounded to true range instead of overshooting close enemies by a full-range offset; unrelated enemies no longer drag Firestorm/Pit off the selected target. Coverage checks use predicted positions, including retreat Pit, so outward-moving edge targets do not cause guaranteed misses.
- Root/disable Firestorm follow-up, no redundant Pit on an already rooted target, actual clustered creep coverage and level3 lane farming. Shard entity casts attach storm to an allied frontliner close to the victim; no stale Pit Scepter mechanics.
- Gate joins a safe nonempty allied fight, fixes reversed source-enemy query and Vector-as-unit-list averaging, and opens retreat escape before critical health. Creating a Gate records travel intent for its20s lifetime, survives temporary roots, validates destination again and selects the nearby source portal including fountain-offset arrival.
- Hidden unit-target portal warp follows the opening cast. Rubick utility and native Rubick SkillsComplement process this pending entry before ordinary slot readiness/silence checks, so the cooling-down stolen Gate does not suppress travel; root/stun/queued actions and unsafe destinations still block entry.

Focused verification: tests/underlord_ability_spec.lua passes both native hero and real Rubick dispatcher, including stationary/close/outer-edge placement, outward prediction, root combo, clustered versus spread farming, Shard entity shape, Gate opening then hidden warp while Gate is on cooldown and caster silenced, a3s root, destination hazard change and remote allied fight. Rubick hero spec confirms pending entry precedes native decisions; shared dispatcher/channel guards pass. Full batch suite result recorded separately after integration.

Lobby checklist: compare Pit->Firestorm and allied control->Firestorm against moving targets/edge casts; level3 wave plus stacked-camp clear; Shard attachment/wave count while frontliner moves; Scepter Gate-generated Pit; Gate join/countergank/early fountain escape; portal unit discovery, hidden interaction while silenced, channel duration/root interruption, spawn latency/fountain offset and destination safety in native Underlord and stolen Gate Rubick. No lobby run performed.

Integration review also tightened multi-target AoE prediction after clamping and cached Gate travel geometry when the spell is created, avoiding stale stolen-spell handle access. Both regressions pass through native hero and real Rubick dispatcher. Rubick portal entry is the only shared dispatch change required by this batch; general cast readiness/channel protections remain covered by their existing specs.

Final batch verification passed on the integrated state: node tests/run-builds.cjs (exit0 and all success markers), including all five new specs, Dazzle regression, Lua syntax for327 files,127 heroes/253 migrated roles,84 specialized Rubick dispatches,58 Rubick hero cases,272 purchase lists and all remaining shared scenarios. The suite includes node tests/valve_ability_check.cjs:128 hero files,21 Rubick copies,0 allowlisted findings at cf0d37a. git diff --check passed. Build/talent/skill-order data and Alchemist gifting were preserved. Offline acceptance is complete; lobby checklist remains outstanding and no live game was run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated bounded/predicted Firestorm/Pit placement, root follow-up, level3 clustered farming, Shard allied targeting and safe Gate opening/entry. Mirrored stolen mechanics with pending travel before Rubick cooldown/silence gating. Native and real-dispatch specs plus full shared build/Valve suite pass; Gate/channel and upgrade lobby checks remain.
<!-- SECTION:FINAL_SUMMARY:END -->
