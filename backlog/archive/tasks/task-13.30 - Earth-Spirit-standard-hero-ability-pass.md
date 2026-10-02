---
id: TASK-13.30
title: 'Earth Spirit: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:35'
updated_date: '2026-10-01 18:02'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_earth_spirit.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 70000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Earth Spirit is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify pinned Valve cf0d37a KV/localization, fetched TDL core/support guides and complete dotacoach Strategy/Counter/Matchup; preserve native D2PT prefix. 2. Implement legal existing/new remnant geometry, current Roll STR/distance/blockers and safe escape, Grip base ally saves plus Shard range, Magnetize initiation/charge-conscious refresh, and bounded Scepter defensive/offensive casts without random kicks. 3. Add Rubick native-equivalent decisions only with actual linked abilities; expose safe cooldown-time Magnetize refresh to root for shared registration. No assumed vector API or control during invulnerable rolling. 4. Exercise meaningful native/copy scenarios with faithful remnant immunity/geometry, charges/mana, reflection and spell ranges; parse Lua 5.2 and run Valve/whitespace checks. Root owns integrated suite and finalization. 5. Record source exclusions, item/counter candidates and specific live-engine lobby limits.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist: pinned dotabuff/d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f scripts/npc/heroes/npc_dota_hero_earth_spirit.txt and resource/localization/abilities_english.txt; tests/valve/abilities.json; TDL fetched core Workshop 195048794 and support Workshop 319111870 (both 7.41f); https://dotacoach.gg/en/heroes/earth-spirit complete Strategy/Counter Strategy and https://dotacoach.gg/en/heroes/counters/earth-spirit complete Matchup, including synergy/core item, favorable matchup, bad matchup and counteritem sections. Checked initiation/follow-up disables, reuse and conservation of stones, ally Grip saves, rolling escape/geometry, Magnetize refresh and spell-effect sharing, and Enchant saves against Valve. Current Grip already pulls allied heroes/creeps at reduced range; Shard enhances ally range/speed and cooldown. Roll has STR scaling, fixed travel distance and stop-on-hero collision. Smash slows and has no current stun. All are conventional POINT/UNIT/NO_TARGET combinations; KV has no VECTOR_TARGETING flag. Ability Draft linked grants and tooltip requirements do not prove Rubick grants, so code requires actual live linked abilities. Excluded deprecated Stepping Stone/Ready to Roll/Resonance facets, old Grip unlock talent/Shard premise, old Smash stun and TDL Magnetize stun-spread claim, spam-idle Stone placement, dotacoach obsolete Chen channel/Test of Faith claim, and Lens increasing actual Roll distance. Hero primary attribute claims were not copied from item tips; strength calculation reads actual bot attribute for Roll.

Implementation: preserved native build/skill/talent/custom/MinionThink prefix exactly. New native and Rubick decisions use alive invulnerable friendly remnant handles instead of J.IsValid, explicit line projection, nearest-stone selection for Smash, actual rock versus unit travel/range, base versus boosted Roll speed/distance with conservative center pickup time, predicted target impacts and mitigation/regeneration-aware lethal checks, intervening hero blockers, safe escape landing and root/Rupture guards. Fresh Stone combos check actual linked Stone, charges and combined mana and queue placement then primary; farm creates stones only above two-charge reserve with Magnetize/mana budget, aligns wave targets and can secure ranged creep. Existing stones are reused. Smash uses a nearby legal directional cast point and explicit actual projectile origin rather than walking toward a far enemy; direct close unit kicks peel pursuers and guard current Counterspell and Ally reflection. Grip has base ally saves, actual resolved Shard ally range plus Lens/unbroken Supremacy once, and refuses pulling into caster danger or from Duel/Chronosphere/Black Hole/Rupture. Offensive Grip pulls a real aligned stone or places behind target within both Stone/Grip ranges; silence is useful without a lethal-only requirement. Magnetize can affect immune enemies, starts before a redundant close roll, avoids already affected groups, and refreshes own active cast sessions late via real Stone only; timing throttle/existing owned stones/remaining lethal damage prevent duplicate charges. UseMagnetizeStone preserves unrelated channels/casts/queues and requires current live Magnetize/Stone handles, and root integrated cooldown-time shared hook. Visible trained Enchant now protects threatened ally/self or captures close legal enemy, with reflection guards and separate ally range; no random kick or invented vector/movement control.

Focused verification: tests/earth_spirit_ability_spec.lua prints Earth Spirit ability scenarios passed. Scenarios exercise native/copy STR/regen timing, missing linked Stone, range versus travel and Lens, front-stone queue order, real invulnerable and off-axis remnants, far pickup time, hero blockers, root/Rupture and escape hazards, base and Shard/Lens ally Grip with danger/control restrictions, aligned/new/off-line/remnant-travel Grip and moving regen, short directional Smash and actual-origin endpoint/timing, direct enemy kick reflection/short range, low charges and aligned/spread farming, ranged creep mitigation, immune and already-affected Magnetize, own cast history and cooldown refresh with low mana, duplicate/dead/missing-stone safeguards, channels/queues, live Enchant saves/capture/self and native cast priority. Lua 5.2 parse, git diff --check and Valve check passed (128 heroes, 32 copies, zero allowlisted findings). Exact prefix comparison with HEAD passed. Root owns final full suite, shared dispatch registration and status/AC finalization.

Lobby pending: verify local point Smash direction and actual nearest-remnant selection with multiple stones, friendly/foreign remnant usability, caster/rock endpoint geometry and direct unit kick facing; actual pre-roll queued Stone placement, consume timing, collision and full-distance escape landing across terrain; Grip targeting of invulnerable remnants, current base ally/Shard range and custom pull exceptions; Enchant invulnerability/custom ally range and enemy reflection. Current Enchant is deliberately standalone protection/capture; directional Enchant-kick rescue/catch and placing stones during invulnerable roll require live validation before adding control. Rubick linked Stone/Petrify availability must be observed in engine; missing handles stay safe. Magnetize refresh tracks own cast window but client modifier data cannot disambiguate overlapping casts from another Earth Spirit; owned stones and local session limit accidental maintenance. TASK-21 candidates: Urn/Vessel pressure/healing, Blink positioning into Enchant, BKB before committed combinations, Force Staff rescue/positioning, Euls dispel/setup, Treads before spell mana spend and Shiva/Glimmer utility. TASK-24 candidates: vision to detect fog rolls, sidestepping/blocking rollout, avoid diving near enemy tower with kick angle, dispel Grip/Magnetize, magic resistance/BKB, and silence/control while Earth Spirit is exposed. No shared item/minion/draft files or WeakHeroes flags changed; this remains standard pass, not deep dive.

Final integrated verification: node tests/run-builds.cjs exited0 after all final reviews/corrections. Exact five hero markers passed;368 Lua files parse,128 native/32 Rubick Valve checks with zero findings,127 heroes/253 roles,133 specialized dispatches,68 Rubick native behavior cases and272 purchase lists. All five native build/skill/talent prefixes remain byte-identical with HEAD; git diff --check passed. Shared dispatcher registers all five dedicated handlers; narrow observed Drow Glacier, Earth Spirit Magnetize Stone and owned Elder Titan Spirit/minion hooks are covered. TASK21/24 source-derived observations recorded. No engine lobby launched; remaining capability boundaries are in each task checklist.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Earth Spirit: corrected remnant geometry, STR/travel Roll, base ally Grip, moving Smash/Grip impacts, charge-conscious Magnetize and linked-copy safety. Native/copy specs, final integrated suite, pinned Valve validation, unchanged build prefixes and whitespace pass. Source audits and lobby limits recorded; ready for in-game test.
<!-- SECTION:FINAL_SUMMARY:END -->
