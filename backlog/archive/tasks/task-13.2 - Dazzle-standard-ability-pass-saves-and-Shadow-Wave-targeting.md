---
id: TASK-13.2
title: 'Dazzle: standard ability pass, saves and Shadow Wave targeting'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 13:06'
updated_date: '2026-10-01 13:22'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_dazzle.lua
  - tests/hero_harness.lua
  - tests/dazzle_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 41000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Dazzle is the first standard hero pass after the Ancient Apparition pilot. Current ability decisions miss routine support healing and clustered Shadow Wave damage, while several guide tips refer to removed mechanics. Review spell use against current Valve data before changing behavior.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Dazzle ability decisions and cast order are reviewed against Valve data, Torte de Lini tips and dotacoach strategy; stale claims and findings are recorded
- [x] #2 Identified spell-use gaps are fixed with offline scenarios covering saves, healing, damage targeting and Projection behavior
- [x] #3 Dazzle spec, Valve ability check and build suite pass; lobby validation scenarios are recorded and task is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Compare current hero slots, upgrade keys and Valve localization with Torte de Lini/dotacoach; record verified mechanics and stale claims.
2. Keep Grave first; fix reachable, armor-aware save selection and urgent/routine Wave healing, physical damage geometry, target cap and Scepter enemy casts. Add laning Poison/fractional duration/Projection channel interrupt, safe useful Projection and body-aware exit; remove obsolete routines.
3. Add harness regression scenarios and runner integration, run Valve/build checks, record lobby scenarios and move to Needs In-Game Test.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01):
- Valve definitions and English localization at d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f were read directly, alongside Torte de Lini Workshop guide 128730475 (via tools/tdl/fetch.cjs dazzle), dotacoach /en/heroes/dazzle Strategy and /en/heroes/counters/dazzle.
- Poison Touch: physical damage, no debuff-immunity piercing; only Dazzle attacks refresh it. Duration includes fractional seconds (3.5 at level 1). Lane harass needs mana and attack follow-up reach. Projection supplies the hex; it can interrupt channels. Removed unconditional lane-creep farming; retained deliberate farming/pushing and boss-use decisions. Combat target selection uses reachable enemies.
- Shallow Grave: friendly hero target, immunity-compatible, non-dispellable, current cast point/range. Cast near death or for predicted lethal damage; heal while its amplification is active. Self is eligible, existing Grave and untargetable Projection souls are excluded. Incoming attack damage is adjusted for physical mitigation; reachable lethal saves outrank merely low health. The guide TP escape idea depends on generic item decisions and is recorded in TASK-21.
- Shadow Wave: physical damage, immunity piercing, radius 185, bounce radius 475, max_targets 3/4/5/6 other units plus automatic self heal. Heal one injured ally rather than waiting for a full group; urgent/Graved allies precede offensive spells. Damage requires an allied source within the actual damage radius and cast range; estimate is capped. Uses the level-15 heal/damage talent. Ice Blast blocks heal-only use. Current Scepter allows initial enemy unit targeting and enemy bounces; supports lethal/clustered direct enemy casts. Hero-priority bounce selection in mixed hero/creep groups still needs lobby confirmation.
- Nothl Projection: point cast, 450 range, 1600 leash, minimum 5 seconds, maximum 12 (+duration talent), empowered basics. Keep the physical body away from nearby enemies/towers; project for support or offensive hex even against healthy targets. Clamp the destination and reserve mana/reach for a currently usable spell. End reads the physical body threat and validates stale handles; retain useful support when no enemy is near the spirit.
- Innate Weave is passive; Shard heals on allied stacks (60 per stack). No active Weave or Bad Juju cast is appropriate. Removed legacy refresh logic and broken Wave damage helper. The guide remains stale despite its 7.41f label: active Weave, Bad Juju cooldown reductions, Poison Shard hex, Arcane Boots disassembly, and disabled-cast Projection Shard are rejected. Valve localization also retains obsolete entries, so current hero slots/upgrade keys are checked before applying descriptions. Rain of Vermin has an unused/unlocalized hidden definition; no speculative new ability handler was added.
- Dazzle is not on WeakHeroes; standard pass only. No dedicated Rubick Dazzle copy exists. D2PT build, talent preferences and item list are unchanged.
Sources: https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_dazzle.txt ; same commit dota/resource/localization/abilities_english.txt ; https://steamcommunity.com/sharedfiles/filedetails/?id=128730475 ; https://dotacoach.gg/en/heroes/dazzle ; https://dotacoach.gg/en/heroes/counters/dazzle

Verification: node .test-tools/node_modules/fengari-node-cli/src/lua-cli.js tests/dazzle_ability_spec.lua passed. node tests/valve_ability_check.cjs passed (128 hero files, 21 Rubick copies, zero allowlisted findings). node tests/run-builds.cjs passed (322 Lua files parsed, 127 heroes/253 migrated roles, all included behavior/integration scenarios). git diff --check passed. Independent read-only review plus regression-spec review integrated; Projection reach/mana and test Scepter-state isolation issues fixed.
Lobby checklist still required:
1. Position-5 Dazzle lane: observe Poison followed by attacks, retreat slow, and no support mana spent automatically poisoning lane creeps.
2. Threatened carry and Dazzle self: Grave before lethal damage, then Wave during Grave amplification; confirm target cast ranges and Aether Lens behavior. Try a high-HP ally with lethal incoming ranged damage and a heavily armored ally with nonlethal projectiles.
3. Injured isolated ally: timely Wave heal without waiting for teammates; no heal-only Wave under Ice Blast.
4. Enemy beside allied melee creeps/summons: Wave originates on a reachable nearby unit and stacks physical damage. Confirm target cap, hero-over-creep bounce priority, self damage contribution and tier-15 talent in mixed clusters. If Dazzle has a Scepter, confirm direct enemy unit targeting/bounces and heal priority.
5. Safe rear position: Projection activates to support frontline allies or hex a healthy enemy, stays within cast range and retains basic-spell mana; no activation near enemies/towers. Verify empowered Poison channel interrupt and reduced Wave cooldown.
6. During Projection: confirm distinct body/soul handles and body state remain accurate; return when the physical body is threatened, subject to engine minimum-duration gating. Continue support while allies remain threatened even if no enemy is near the spirit.
No lobby test was run in this session. Mixed Wave bounce choice and live Projection handle/minimum-duration behavior remain the main engine checks.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Dazzle standard pass implemented: reachable and armor-aware Grave saves, urgent/routine Wave healing, physical cluster/cap/talent/Scepter targeting, purposeful Poison harass and Projection hex, safe support Projection and body-aware exit. Added Dazzle harness spec and build-runner integration. Dazzle spec, Valve ability check, full build suite and diff whitespace checks passed. Current mechanics/stale tips and lobby checklist recorded; item/counterplay observations routed to TASK-21/TASK-24. Awaiting lobby validation.
<!-- SECTION:FINAL_SUMMARY:END -->
