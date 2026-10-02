---
id: TASK-13.25
title: 'Death Prophet: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:04'
updated_date: '2026-10-01 17:28'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_death_prophet.lua
  - bots/FunLib/rubick_hero/death_prophet.lua
  - tests/death_prophet_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 65000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Death Prophet is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Preserve D2PT item, skill and talent prefixes. Audit pinned Valve cf0d37a KV/localization, TDL 129323738 (7.41f) and complete dotacoach Death Prophet Strategy, Counter Strategy and Matchup advice.
2. Replace stale range allowances and raw damage estimates with legal casts, projectile prediction and cone geometry for Swarm; prioritize Silence interrupts and current travel delay.
3. Make Siphon prioritize urgent sustain, distribute charges across durable distinct targets, use enemy creeps for lane healing and real objectives, and reject active reflected/blocked/immune targets. Respect actual fixed DPS, existing links, health/mana and last-charge decisions.
4. Use physical, immunity-piercing Exorcism for real fights, protected-building-aware pushes and bosses; avoid wasting active ultimate or low-health lone retreats. Add dedicated Rubick decisions with refreshed live handles and preserved channels.
5. Add meaningful native/copy scenarios and explicit marker, run focused Lua/Valve/whitespace checks; record sources, exclusions, implementation and lobby checks. Parent owns shared integration, full suite and final acceptance/status.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Research checklist: pinned npc_dota_hero_death_prophet.txt and abilities_english.txt; TDL workshop 129323738 Position 2 / 7.41f; https://dotacoach.gg/en/heroes/death-prophet and https://dotacoach.gg/en/heroes/counters/death-prophet, including Strategy, Counter Strategy, all gameplay synergy/matchup/core/counter-item sections. Swarm start/end radii 110/300, range900, speed1100; Silence projectile1750 and radius450; Siphon500 cast +250 break buffer, damage25/50/75/100 fixed DPS and six-second link, Shard extra charge/fear after three consecutive seconds; Exorcism700 acquisition radius, physical damage, hits immune enemies and structures. Reject percentage-drain and magic-Exorcism claims, obsolete slow assumptions, guaranteed Siphon crowd control without maintained Shard link, and guide item/build recommendations overriding D2PT. Generic Euls/BKB/Phase/Blink item use and enemy counterplay remain TASK-21/TASK-24.

Implemented native and new dedicated Rubick decisions with refreshed handles. Existing D2PT build/skill/talent/item prefix and MinionThink are preserved exactly. bDeafaultAbility remains its original true: generic AbilityUsageThink calls BotBuild.SkillsComplement after guards regardless of that otherwise unread local flag. Silence interrupt priority includes cast plus projectile travel and legal edge-radius clamping. Swarm uses actual damage and travel, conservative expanding-cone geometry, mitigated last hits/cluster farm, and physical geometry independent of Lens; point mode correctly ignores target spell block/Counterspell. Urgent Siphon precedes ultimate/nuke use, chooses durable separate linked targets, supports lane/neutral healing and actual bosses, rejects immunity/reflection/both Counterspell modifiers/active links, preserves last charge for mild creep sustain, and does not justify creep healing under Ice Blast. Exorcism uses700 acquisition radius and physical immunity-piercing target value for fights, friendly-wave-supported unprotected durable structures, healthy Roshan attacks and grouped Tormentor; active ultimate, attack-immunity, protected building and critically low health waste is suppressed.
Verified Death Prophet ability scenarios passed for native/copy, Lua5.1 parsing and owned whitespace; pinned Valve scan passes128 heroes27 copies0 allowlisted findings at this checkpoint. Parent owns full suite and final task lifecycle.
Lobby checks: confirm point Swarm projectile cone/end-cap hits beyond the conservative900 centerline (localization mentions1110 reach whereas KV range900/end_radius300), Lens/Supremacy effect on physical projectile versus point command reach, moving Silence edge hits and delay, Siphon low-level/Shard charge and exact modifier behavior, maintained three-second Shard fear, links through self-Euls/invisibility, Scepter ghosts from spell hits, objective ghosts/aggro/reflection and retreat survivability. No exact heal multiplier or guaranteed sustained-DPS kill is invented. Engine lobby was not launched.
TASK-21 candidates: Phase movement to maintain ghost/link range, self-Euls while already-linked for sustain, BKB before entering disables, Blink only after Exorcism startup and allies initiation, Shiva slow/Hex follow-up and dispels against heal reductions. TASK-24 candidates: kite live Exorcism/link break buffer, commit after ultimate expires, heal reduction and physical armor; do not assume Pipe negates ghost physical damage. Draft synergy setup remains separate.

Final verification after all review repairs (2026-10-01): node tests/run-builds.cjs exited0; all five hero spec exact markers verified, 358 Lua files parsed, pinned Valve audit128 native heroes/27 Rubick copies/0 findings, 127 role tables, 112 specialized dispatches,64 Rubick behavior cases and272 purchase lists. git diff --check passed. All five original build/skill/talent prefixes remain byte-identical to HEAD. New handlers and early hooks are integrated; existing prior-batch scenarios still pass. TASK21/24 observations recorded. No lobby launched; standard pass handed off as Needs In-Game Test with capability limits above.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Death Prophet native and dedicated Rubick logic improves Swarm geometry/timing, Silence interrupts, urgent Siphon sustain and physical Exorcism fights/structures/objectives. Builds retained. Hero scenarios, final full suite and Valve check pass. Projectile endpoint and sustained link/upgrade mechanics remain lobby checks.
<!-- SECTION:FINAL_SUMMARY:END -->
