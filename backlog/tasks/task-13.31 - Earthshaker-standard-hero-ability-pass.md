---
id: TASK-13.31
title: 'Earthshaker: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:35'
updated_date: '2026-10-01 18:02'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_earthshaker.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 71000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Earthshaker is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Preserve D2PT builds/skills/talents and native MinionThink. Audit pinned Valve cf0d37a Earthshaker KV/localization, TDL129137630 7.41f and full dotacoach Earthshaker Strategy/Counter/Matchup.
2. Prioritize reliable Fissure or real live Aftershock interrupts before initiation. Replace inflated ranges/radius-half assumptions with predicted legal Fissure line geometry, cast delay, real350 Aftershock and700 Echo radius. Include actual enemy basic/illusion echo bodies without inventing item-triggered Aftershock.
3. Use Scepter Totem live point behavior for bounded safe jumps and documented self-target shape for immediate non-jump casts; do not jump while rooted/Ruptured/leashed or into known hazards. Link refreshed live Totem/Echo handles only when full combo mana and predicted actual hero control justify them.
4. Support Totem buff preparation, base-damage-aware last hits, disabled/nonimmune Aftershock value, farming and real objective attacks. Confirm issued Fissures through observed cooldown before tracking own Shard ridge follow-up; no assumed remote Aftershock without a real live unbroken passive.
5. Add dedicated Rubick handler and native/copy behavior scenarios with marker Earthshaker ability scenarios passed. Run focused parse/Valve/whitespace; record source/stale/implementation/lobby and item/counter candidates. Root owns shared integration/full suite/status and AC.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist complete: /tmp/earthshaker-valve.txt from pinned https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_earthshaker.txt; same-pin abilities_english.txt; TDL129137630 Position4 /7.41f; https://dotacoach.gg/en/heroes/earthshaker and https://dotacoach.gg/en/heroes/counters/earthshaker, full Strategy/Counter, gameplay synergy/matchups and core/counter items. Fissure1600 range/radius225/cast0.69; Aftershock350 trained breakable passive, items never trigger it; Echo damage/search/echo ranges700 and no intrinsic stun without Aftershock; real heroes emit two echoes; Totem fixed base/primary-attribute amplification, bonus100 attack range, Scepter950 leap with0.8 travel and self-cast non-jump. Current Shard halves ridge Aftershock stun and reduces Fissure cooldown. Reject old shared-facet assumptions, blanket invis/dodge/crowdcontrol promises, no-cost Refresher use, stale upgrade/facet text, and item damage treated as Totem-amplified base. Generic item actives/draft/counterplay remain TASK-21/TASK-24.

Implemented native and dedicated Rubick handler, preserving the exact D2PT/build/skill/talent prefix and MinionThink. Fissure uses the full legal raw range plus active Lens/unbroken Supremacy,0.69 live castpoint prediction and line/circular endpoint geometry, not an AoE-center shortcut; targeted block/Counterspell do not suppress this point spell. Interrupts and immediate kills beat setup; faster actual Totem Aftershock or instant Echo Aftershock wins when truly available. Nonurgent walls avoid an obvious intersection with a damaged retreating ally route toward fountain; farm clears require aligned actual units and ultimate mana reserve; real boss branches remain.
Aftershock is evaluated only through a live non-null trained unbroken ability. No item-triggered pulse or intrinsic Echo stun is invented. Recorded own Fissures must show real cooldown after expected cast completion before supporting Shard ridge Totem follow-ups; failed casts, missing handles, expiry and delayed confirmation cannot create/extend imaginary ridges. All source damage/body checks use visible actual units, including neutral creeps, summons, illusions and real hero double emitters; unit lists are cached within a spell-think decision.
Echo uses actual700 initial/search/echo radii with pairwise emitter proximity. Useful real-hero clusters, a hero inside a summon cloud, and actual immediate initial/Aftershock kills are supported. Delayed echoes are deliberately excluded from guaranteed lethal predicates; reflected burst is estimated from observed emitting units and compared with caster health. Blink/Totem combos use legal reach, actual live point Totem shape, predicted cast+leap timing, full mana, passable/hazard checks and identity-correct allies versus real enemy threat counts. Root/Rupture/Pounce/Dead-in-Water prevent mobility; critically low health declines offensive mobility. Scepter self-entity Totem retains non-jump cast; escape heads fountain. A disarmed offensive jump must offer actual unbroken Aftershock control against a nonimmune target.
Totem supports near-fight preparation without overwriting unused buff, Aftershock cluster farming, building/Roshan/Tormentor attack buffs, physical immunity-piercing attacks and actual lane last-hit/deny targets queued after the cast. Powered damage uses total attack plus a lower-bound base-damage-only amplification, never multiplies green item damage; armor/regen/cast+attack time apply. Copy refreshes all live handles before linked decisions and does not assume secondary passive exists. Normal channel/queue/disable guard stays.
Checks: Earthshaker ability scenarios passed for native/copy; Lua5.1 native/copy/spec parse, exact prefix preservation, owned whitespace and pinned Valve128hero32copy0finding check passed. Parent handles shared dispatcher/runner/fullsuite and final task status/AC. No generic item/minion/draft file changes.
Lobby checks: live Scepter GetBehavior and documented self-target cast, cast speed plus0.8 leap/queue timing and interrupted leap; Aftershock actual hidden linked handles on Rubick, trained level and break behavior; cooldown-confirmed ridge placement/lifetime/half-stun and multiple own ridges; full Fissure line and endpoint225 hits after Lens/talent/Supremacy, terrain and obvious ally escape crossing; Echo emission from real heroes/Meepo/illusions/neutrals, emitter-self behavior and reflected burst; Totem base damage API versus primary-attribute contribution, empowered ranged last hits/denies and cleave. First-wave wall placement and map-specific isolation remain coordination/navigation checks; no universal safe-path guarantee is claimed. Engine lobby not launched.
TASK-21 candidates: prebuff Totem before Blink approach, BKB before exposing caster to disables, Euls setup and cast-speed alignment, Force reposition after combo, Refresher only with complete second combo mana. TASK-24 candidates: spread from nearby bodies including summons before Echo, chip caster to cancel Blink, respect long Fissure cast/wall crossing, immunity before control, terrain/flight escape and interrupt Scepter landing; strong dispels and reflection have current-mechanics limits. Source claims about obsolete Wraith King facets and no-budget double Echo are excluded; draft synergy with group control remains separate.

Final integrated verification: node tests/run-builds.cjs exited0 after all final reviews/corrections. Exact five hero markers passed;368 Lua files parse,128 native/32 Rubick Valve checks with zero findings,127 heroes/253 roles,133 specialized dispatches,68 Rubick native behavior cases and272 purchase lists. All five native build/skill/talent prefixes remain byte-identical with HEAD; git diff --check passed. Shared dispatcher registers all five dedicated handlers; narrow observed Drow Glacier, Earth Spirit Magnetize Stone and owned Elder Titan Spirit/minion hooks are covered. TASK21/24 source-derived observations recorded. No engine lobby launched; remaining capability boundaries are in each task checklist.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Earthshaker: corrected legal Fissure/Aftershock/Echo coverage, live copied passive requirements, safe Blink/Scepter combos, Totem damage and confirmed Shard ridges. Native/copy specs, final integrated suite, pinned Valve validation, unchanged build prefixes and whitespace pass. Source audits and lobby limits recorded; ready for in-game test.
<!-- SECTION:FINAL_SUMMARY:END -->
