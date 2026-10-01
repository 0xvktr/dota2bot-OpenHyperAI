---
id: TASK-13.16
title: 'Broodmother: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 15:23'
updated_date: '2026-10-01 15:54'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_broodmother.lua
  - bots/FunLib/rubick_hero/broodmother.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 56000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Broodmother is in the next standard-pass batch after Axe/Bane/Batrider/Beastmaster/Brewmaster. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing D2PT builds, separate TASK14 build findings and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Audit pinned Valve KV/localization, TDL guide 128757681 and dotacoach Strategy/Counter/full Matchup; separate current Hunger/Spider Milk/Bite and vector-target Scepter Snare from obsolete Bola/web-regeneration advice.
2. Preserve build prefix; implement emergency Web priority and connected, legal web expansion with meaningful overlap; tactical Spawn slow/finishing/recruitment with range, immunity, reflection and mana checks; improve Hunger damage/sustain against controlled foes, lane creeps and objectives. Mirror applicable decisions in Rubick.
3. Add native/copy behavior scenarios including web ownership/connectivity, retreat priority, low-mana recruitment and protected spell targets. Verify marker, parse, Valve and whitespace; record live range/web ownership and Snare API limitations plus lobby cases for parent finalization.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): pinned Valve hero KV and English localization cf0d37a32c8df338a7832fd32a282747969e9a5f; tests/valve/abilities.json. https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_broodmother.txt . TDL Workshop 128757681, Position 2 / 7.41f, fetched using node tools/tdl/fetch.cjs broodmother (network retry succeeded). Reviewed all ability/item tips. Useful direction: Spawn recruitment/nuke; web jungle connections and escape; Hunger lane sustain/offensive windows; Orchid/Bloodthorn focus and BKB freedom to attack. Rejected stale Silken Bola initiation, universal attributes, web health regeneration, enemy Solar Crest targeting, Abyssal blink and old Arcane Boots disassembly. Current hero is agility; Spider Milk provides kill healing; Bite is passive; Shard ramps Hunger bonus damage. Scepter Snare remains a current vector-target/channelled ability, not Bola.
Dotacoach: https://dotacoach.gg/en/heroes/broodmother Strategy/Counter Strategy reviewed completely; preserve army, establish enemy-side farming territory after level 6, use safe web escape and remember AoE/armor/heal-reduction counters. https://dotacoach.gg/en/heroes/counters/broodmother full Matchup reviewed including gameplay allies (Beastmaster control/attack-speed, Dazzle swarm Wave, Dawn/Mars/Spirit Breaker/Rubick pressure/control), enemies, core and counter items. Follow allied control rather than reject disabled targets; recruit without crowding out a combat cast. Armor/Crimson, attack immunity, heal suppression and AoE threats constrain swarm engagement. Excluded unsupported claim that webs grant vision and misleading immediate Spider spawn assumption: targets have a 20-second death mark; current Spawn also slows for 4 seconds. No draft/build/item purchase changes; TASK14 remains separate.

Implementation: native and dedicated Rubick copy now recruit from neutral camps and use Spawn as a combat/chase/retreat slow before farming. Checks use actual magical incoming damage, death protection, illusions, immunity, spell block/reflection/current Counterspell, legal cast reach and farming mana reserve. Existing Spawn slow is not refreshed just for harassment; a lethal cast can still finish. Hunger uses controlled attack windows at healthy HP and supports lane/farm sustain and tower/objective damage, while refusing disarm, attack immunity and buff refresh. Web casts use owned units, meaningful edge overlap, direct legal range or connected remote placement; retreat places an escape corridor ahead and stuck/escape Web outranks Spawn. Throttling no longer consumes a tick that can activate Hunger. Removed obsolete dedicated Bola handling and inactive commented native code. Build/skill/talent/item prefix unchanged.
Offline evidence: tests/broodmother_ability_spec.lua emits Broodmother ability scenarios passed; covers native and stolen behavior, neutral recruitment, mana and mitigation, controlled-target synergy, protected/reflected targets, real reach with Lens/Supremacy and Break, owned web connectivity/duplication/expansion, emergency priority and throttle. Lua 5.1 parse of both production files and spec passed. Valve checker passed 128 hero files / 21 copies / 0 allowlisted findings. Focused git diff --check passed. Parent owns shared-suite integration and final AC/status.
Lobby checklist: (1) Native and stolen Spawn: blocked/reflected/immune foe, slow follow-up, mitigation-aware creep finish and neutral recruitment. (2) Hunger during allied Roar/Arena, lane recovery and tower attack; confirm Shard ramp and nearby spider lifesteal. (3) Web: retreat across trees/cliff, charge throttle, current edge expansion, owned versus another player web, remote connected cast. Confirm engine Web GetPlayerID ownership and whether ability GetCastRange already includes item/Supremacy bonuses. (4) Fixed roster versus Axe/Earthshaker AoE and Ghost/Crimson/anti-heal defenses; scouts and Roshan-clap spider micro remain a generic-unit coordination follow-up. (5) Current Scepter Spinner Snare remains unavailable to automatic cast until a bot API capable of selecting both vector endpoints is proven; do not miscast as a point nuke or claim full Scepter coverage.
Follow-up routing for parent: TASK21 contextual BKB before Hunger and Pipe/Greaves swarm protection, Orchid/Bloodthorn focus; TASK24 current attack-immunity/armor/anti-heal/AoE counterplay and generic spider scouting/Roshan-clap avoidance. No generic item, draft or minion changes were made.

Review follow-up: both native and stolen Spawn Spiderlings explicitly reject modifier_antimage_counterspell_ally in addition to the caster Counterspell modifier; the shared advanced-target helper does not cover this current ally protection. Added native/copy reflected-ally regression. Focused spec emits Broodmother ability scenarios passed; focused whitespace check clean.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 with all five new hero success markers and prior regressions. Lua syntax: 341 files; pinned Valve check: 128 native hero files / 21 Rubick copies / 0 allowlisted findings; builds: 127 heroes / 253 roles; specialized Rubick: 85 dispatches; Rubick hero behavior: 59 cases; purchase planning: 272 buy lists. git diff --check passed. Scripted HEAD comparison confirms all five build/skill/talent prefixes unchanged. Lobby scenarios remain pending; no game launched. Standard pass is ready for in-game testing, with documented engine/capability limits.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated native/stolen Broodmother tactical Spawn and neutral recruitment, owned connected web escapes/expansion and Hunger attack/sustain windows; removed obsolete Bola handling. Focused and full suite/Valve/diff checks pass. Lobby validation pending; vector-target Spinner Snare automation awaits a proven two-endpoint bot API.
<!-- SECTION:FINAL_SUMMARY:END -->
