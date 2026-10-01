---
id: TASK-13.27
title: 'Doom: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:04'
updated_date: '2026-10-01 17:28'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_doom_bringer.lua
  - bots/FunLib/rubick_hero/doom_bringer.lua
  - tests/doom_bringer_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 67000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Doom is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve/localization, TDL and full dotacoach sources; preserve builds. 2. Fix legal in-range Devour eligibility/ranking, real Infernal Blade burn damage and interrupts, useful Scorched Earth regeneration/mobility/farm budget, and immunity-piercing Doom threat control including Scepter aura targets. Add a narrow verified acquired-creep spell dispatcher rather than enabling unknown metadata-only spells. 3. Mirror stealable spells in a dedicated Rubick handler, add native/copy regression scenarios, record source exclusions and lobby limits; root runs integrated checks and finalizes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): pinned Valve hero KV and English localization cf0d37a32c8df338a7832fd32a282747969e9a5f, https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_doom_bringer.txt and npc_abilities.txt for acquired Stomp/Purge/Lightning. Devour range300/levels4–6, current Shard grants charges/ancients and15% AoE/40% amp on acquired spells. Blade is an attack effect with per-second base plus maxHP burn over4s, not one tick; Scorched Earth grants6.66 regen and movement, permanent talent changes its toggle semantics. Doom pierces immunity, prevents healing and silences; mute is talent-dependent, Break/self aura350 is Scepter. Passive Level? Pain is never cast.
TDL Workshop129098268 and143243384 (7.41f) fetched/read with tools/tdl/fetch.cjs doom_bringer. Applied eligible economic Devour/ranged lane creep and Centaur/sustain neutral preferences, channel-interrupt Blade, high-value caster/core Doom and pursuit/farming Earth. Stale Shard-Earth sustain and universal item-disable claims excluded. Current alt-cast keeps acquired spells; no unverified automatic alt-cast policy or invalid replacement action added.
dotacoach https://dotacoach.gg/en/heroes/doom Strategy/Counter and https://dotacoach.gg/en/heroes/counters/doom entire Matchup read. Useful follow-up vision/catch from Bloodseeker/Spectre/Spirit Breaker, Ghost Shroud purge and neutral control reviewed. Rejected blanket Doom mutes items, old universal Break, guaranteed Rubick duration/CD improvements, Shiva AoE amplification, numerical neutral-aura exaggerations and unverified save exceptions. Items/counter candidates for TASK21/24: Blink/Phase/Bearing/BKB pursuit and double-cast Refresher mana; Linkens/Lotus, targeted pre-cast disable, heal reduction against Earth, spread from Scepter aura, item/TP escape before mute. Existing builds/skills/talents unchanged.
Implementation: guarded real-range level/ancient Devour scoring replaces invalid highest-HP bypass; ready melee Blade validates attackability/range and counts full DOT with attack/cast delay and regeneration. Channel interruption precedes Doom; useful controlled/BKB targets are eligible for Doom, core/caster threat selection no longer picks an out-of-range enemy or rejects every disabled enemy. Ready Blink can initiate within bounded landing/predicted reach, preserving mana and avoiding roots/Rupture/hazards/outnumbered landings. Scepter self aura requires two actually predicted nearby meaningful targets and bypasses enemy-target reflection/block. Earth supports BKB pursuit/escape, blocked-heal-aware sustain, permanent on-only toggle, real creep clusters and objective farming with trained Doom mana reserve. Narrow native acquired slot3/4 dispatcher activates verified Stomp/Purge/Lightning only; unknown/passive acquired spells remain withheld, no metadata-only guess. New Rubick copy mirrors four stealable spells with current linked handles and its own safe Blink initiation, without assuming acquired neutral spells are transferred.
Lobby pending (no game launched): Doom/Rubick+vision/catch ally vs AM/Lotus/Linkens, BKB/healer, high-HP carrier and Aegis/illusion. Validate Devour eligible hero-like summons, creep levels, Shard ancients/charge semantics, current alt-cast preservation and actual acquired slot placement/names/amplification. Test Blade range/autocast attack behavior, attack immunity, full burn/regen and channel interruption; Lens/Supremacy engine range reporting under Break. Doom can follow a short stun, pierce BKB and prevent healing but cannot generally stop TP without mute/Blade/Stomp; validate passive/talent/Scepter linkage and self-aura modifiers/coverage. Check safe Blink landing/prediction, Earth regen under heal blocks, permanent toggle, boss interactions and farm budgets. Explicit scope limits: no invisible priority-target scouting, automatic Devour ability replacement, full neutral-spell catalog or Scepter pre-cast-to-Blink aura choreography; those need engine/coordination evidence. Standard pass only.

Read-only review repaired current Ghost Shroud and Doom aura modifiers using pinned localization. Existing enemy/self Doom aura states now avoid repeat casts after Refresher. Infernal Blade refuses disarmed casters and uses its live attack-spell reach without adding Lens/Supremacy spell-range bonuses; regressions cover these states and actual attack reach remains a lobby case. Doom ability scenarios passed after all repairs.

Final verification after all review repairs (2026-10-01): node tests/run-builds.cjs exited0; all five hero spec exact markers verified, 358 Lua files parsed, pinned Valve audit128 native heroes/27 Rubick copies/0 findings, 127 role tables, 112 specialized dispatches,64 Rubick behavior cases and272 purchase lists. git diff --check passed. All five original build/skill/talent prefixes remain byte-identical to HEAD. New handlers and early hooks are integrated; existing prior-batch scenarios still pass. TASK21/24 observations recorded. No lobby launched; standard pass handed off as Needs In-Game Test with capability limits above.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Doom native and dedicated Rubick logic fixes Devour eligibility/ranking, attack-specific full-burn Blade control, useful Earth sustain/mobility/farming, prioritized immunity-piercing Doom, safe Blink and Scepter aura states. Native uses reviewed acquired Stomp/Purge/Lightning only. Builds retained. Hero scenarios, final full suite and Valve check pass. Acquired spell catalog and live upgrade/range/attack semantics remain documented lobby/coordination limits.
<!-- SECTION:FINAL_SUMMARY:END -->
