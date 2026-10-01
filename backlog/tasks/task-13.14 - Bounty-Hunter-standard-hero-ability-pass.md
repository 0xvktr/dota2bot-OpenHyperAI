---
id: TASK-13.14
title: 'Bounty Hunter: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 15:23'
updated_date: '2026-10-01 15:54'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_bounty_hunter.lua
  - bots/FunLib/rubick_hero/bounty_hunter.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 54000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bounty Hunter is in the next standard-pass batch after Axe/Bane/Batrider/Beastmaster/Brewmaster. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing D2PT builds, separate TASK14 build findings and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve/localization, TDL and full dotacoach advice; reject old Shuriken mini-stun and Track crit claims. 2. Replace unrelated bounce targeting with bounded reachable Track paths, fix Track selection/range and invisible cast priorities, scout mana threshold and Friendly Shadow saves; add current manual Jinada targeting without build changes. 3. Test native/copy behavior and document source/item/lobby findings for root verification.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01 standard pass):
- [x] Pinned Valve KV and English localization at cf0d37a32c8df338a7832fd32a282747969e9a5f: https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_bounty_hunter.txt ; English abilities localization same snapshot. Toss is magical damage plus short100% slow, radius1200 Track bounces; no current stun. Jinada is unit-target/autocast/attack with breakable bonus and immunity piercing. Track pierces immunity, grants True Sight/damage amplification and preserves invisibility. Friendly Shadow650 range, allied immunity allowed, Shard-granted,0.5-second fade, preserves caster invisibility. Scepter Toss600 cast range and Jinada on impact.
- [x] Torte de Lini workshop128751287 (pos4),7.41f, via tools/tdl/fetch.cjs. Adopted invisible Track opening, manual Jinada, tracked bounce network, lane Toss harassment/ranged last hit and allied Shadow save/setup.
- [x] dotacoach Strategy/Counter https://dotacoach.gg/en/heroes/bounty-hunter . Reviewed Jinada trade/last hit, detection inventories and sentried routes, forward scouting/Track and dispel counters. Detection-route navigation remains out of this ability pass.
- [x] Complete Matchup including every gameplay/core/counter item block https://dotacoach.gg/en/heroes/counters/bounty-hunter . Track vision enables Spirit Breaker/Spectre/Zeus/Prophet/Invoker/Dawnbreaker follow-up; reveals invisible heroes. Dispel saves and untargetable concealment deny value. Reviewed allied invis setup, Eul/Wind Waker, drums/Bearing, Scythe and Lotus; detection, armor, dispels and lockdown oppose Bounty.

Source exclusions: Legacy Shuriken mini-stun/channel-interrupt code rejected; pinned KV and localization specify slow. Old Track crit/movement-speed benefit and Scepter Shuriken critical strike advice rejected: current Track is damage amplification, Scepter applies Jinada. TDL Solar Crest self-cast advice inconsistent with current item restrictions and not adopted. Friendly Shadow fade0.5 is not an instant guaranteed projectile disjoint, so no unsupported projectile save branch. Big Game Hunter passive income does not require a cast; retained Lookout definition is not in current active slot/upgrades. No new courier, ward, wisdom or detection-route behavior introduced.

Implementation: Native/copy evaluate real direct cast range and tracked1200-unit paths; choose launch unit whose actual bounce chain reaches desired target, including multiple tracked relays, and estimate travel along that path. Removes unrelated-creep casts, arbitrary+100/+200 range, copy undefined npcEnemy and stale channel interruption claims. Legal Track selects lowest-health untracked valid hero without resetting score on tracked enemies, permits immunity, rejects reflection/block/duplicate/Tempest Double. Native allied save and retreat invis precede Track; Track precedes Toss/Jinada, preserving invisible opening stun unless Toss is lethal. Both handle lane Toss harassment/contested ranged last hit and absolute280 scouting mana instead of fractional mana. Friendly Shadow saves retreating ally before healthy approaching initiator, avoids already invisible or actively attacking ally. Manual Jinada targets enemy at actual attack reach and suppresses priority during break/disarm/retreat. Copy recognizes active Jinada as well as existing four spells. D2PT build/skill/talent prefixes unchanged; role differentiation remains separate.

Offline verification: tests/bounty_hunter_ability_spec.lua passes marker Bounty Hunter ability scenarios passed; native/copy tests cover Track selection/BKB/reflection/range, unrelated/out-of-range bounce,1200 boundary, multi-relay chain, no imaginary channel interrupt, invisible nonlethal/lethal Toss choice, lane mana gating, scout mana/invisibility, allied save ordering, attack-follow-through Jinada and break. git diff --check clean. Root owns shared dispatch active Jinada smoke, Valve/full suite and criteria/status.

Lobby checklist: (1) Invisible Track->Jinada opening and lethal Toss exception; confirm spell and attack preserve/break invis as expected. (2) Creep launch to tracked hero,1200 boundary and chained tracks including moving/untargetable/immune hero; verify actual bounce eligibility and per-hop travel. (3) Lane manual Jinada creep aggro behavior, break/disarm and ability availability/autocast interaction; native/stolen active Jinada. (4) Detection-present retreat Shadow movement/damage reduction and repeat-cast prevention; scout threshold280. (5) Friendly Shadow0.5 fade allied BKB save/setup, avoiding attack-immediate break; actual Lens/Supremacy bonus handling. Scepter Toss physical Jinada damage is conservatively excluded from lethal magical-only estimator pending native/Rubick upgrade interaction validation. No game/lobby launched.

TASK21/24 candidates: detection-aware safe routes, Dust dispel outside area via Lotus/Eul/Greaves, allied Bearing pursuit/escape and Eul into Shadow-hit control, Scythe instant initiation from invis, Track purge/reapply after saves. Generic item/draft/minion code and TASK14 builds untouched.

Final targeted-spell review: native and stolen Track/Shuriken reject modifier_antimage_counterspell_ally on direct targets, launch units and tracked bounce recipients. Native/copy regression scenarios cover allied protection and cast after expiry. Bounty Hunter ability scenarios passed marker confirmed.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 with all five new hero success markers and prior regressions. Lua syntax: 341 files; pinned Valve check: 128 native hero files / 21 Rubick copies / 0 allowlisted findings; builds: 127 heroes / 253 roles; specialized Rubick: 85 dispatches; Rubick hero behavior: 59 cases; purchase planning: 272 buy lists. git diff --check passed. Scripted HEAD comparison confirms all five build/skill/talent prefixes unchanged. Lobby scenarios remain pending; no game launched. Standard pass is ready for in-game testing, with documented engine/capability limits.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated native/stolen Bounty Hunter Track selection and invisible opening, real tracked Shuriken bounce paths, allied Shadow saves, scouting mana and active Jinada. Reconciled obsolete mini-stun/crit advice. Focused and full suite/Valve/diff checks pass; lobby validation pending.
<!-- SECTION:FINAL_SUMMARY:END -->
