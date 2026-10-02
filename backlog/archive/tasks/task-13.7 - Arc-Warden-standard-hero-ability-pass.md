---
id: TASK-13.7
title: 'Arc Warden: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 13:29'
updated_date: '2026-10-01 14:05'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_arc_warden.lua
  - bots/FunLib/rubick_hero/arc_warden.lua
  - >-
    https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_arc_warden.txt
  - 'https://dotacoach.gg/en/heroes/arc-warden'
  - 'https://dotacoach.gg/en/heroes/counters/arc-warden'
  - tests/arc_warden_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_arc_warden.lua
  - bots/FunLib/rubick_hero/arc_warden.lua
  - tests/arc_warden_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 46000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Arc Warden is part of the next standard hero batch after Dazzle. Review current spell decisions and combos against guide strategy and current Valve mechanics, including the dedicated Rubick copy, to address weak or incorrect ability use.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against Valve definitions and localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and Matchup advice; findings and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the hero and applicable Rubick copy, with meaningful offline behavior scenarios
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and task is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify current Flux isolation, point-target Field/rune interaction, single-target Spark delay, Double and upgrades against pinned Valve definitions/localization; compare the complete TDL and dotacoach strategy/matchup advice. 2. Correct reachable Flux decisions and isolated kill estimates; prioritize Flux before offensive Double/Field, add defensive/self and remote ally Field plus rune capture, clamp Spark prediction and creep-safe kill/laning use; refresh Double ownership/liveness. Mirror current stolen spell behavior without changing shared minion code or builds. 3. Add main and stolen spell scenarios on hero_harness, run focused spec and Valve check, record sources and lobby checks; await parent full-suite integration before acceptance/status finalization.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Research completed: TDL 7.41f retrieved; dotacoach hero Strategy/Counter Strategy and complete matchup/core/counter-item sections read. Authoritative pinned cf0d37a32c8df338a7832fd32a282747969e9a5f hero KV and Valve abilities_english localization checked. Active slots are Flux, Magnetic Field, Spark Wraith, Runic Infusion, hidden, Double. Flux search radius 225 pauses damage (not slow); Scepter belongs to Flux (+duration, damage, isolated silence). Field is point-target radius 300 / range 900 and now pulls/activates runes; knockback=0 and affects_buildings=0. Spark is one target, radius 375, activation 1.5 + cast point 0.3, range 2000. Double range 700, own cooldowns, Shard supplies three rune buffs. Stale TDL claims excluded: Field damage/attack range/knockback and old Field Shard; Rune Forge Scepter definition has no active slot/current localization, not implemented. Dotacoach silence/Scepter advice is current for Flux, while generic Double bounty 70 omits +10 per hero level. Spell-use gaps: inflated ranges, Flux kill assumptions inside friendly packs, Field omits self and wrong remote center, ranged Spark raw damage/walk cast, Double stale/other-owner handle and pre-combo dispatch.

Implemented: Flux kill estimates now require isolation from visible enemy heroes/creeps; isolated lane/gank use precedes Double and offensive Field, while retreat still uses the unconditional slow in a pack. Flux and all point casts use actual ability ranges. Field includes self and casts at a reachable attacking/protected ally; existing Field is respected for chaining, defensive outside-attacker protection wins first, and Rune mode can capture a reachable river rune. Spark kill attempts avoid visible creep/summon interception, predict through 1.5 + 0.3 seconds, clamp every real Consider return to legal range, and ranged-creep securing uses magical incoming damage. Existing farming/scouting branches retained. Double scans only living clones belonging to this player, refreshes dead handles, cannot recursively summon, and ready main Midas can trigger local farming. Removed dead Double casting/Midas helpers. Main Double-specific local engine queries bypass a confirmed shared J.GetNearbyHeroes bug that drops all queried heroes when caller is a Double; shared libraries unchanged. Applicable Flux/Field/Spark changes mirrored into Rubick copy with local dispatch variables.

Offline verification passed: node .test-tools/node_modules/fengari-node-cli/src/lua-cli.js tests/arc_warden_ability_spec.lua prints Arc Warden ability scenarios passed; Lua 5.2 luaparse passes hero/copy/spec; node tests/valve_ability_check.cjs passes 128 hero files and 21 Rubick copies with 0 allowlisted findings at cf0d37a. Shared Rubick handlers test initially exposed clamp-in-dispatch incompatibility; clamping moved into real Consider functions and plain-coordinate fixtures are supported. Its next run passed Arc dispatch then stopped at unrelated Alchemist GetModifierTime stub, reported to parent. Await parent full-suite result before final acceptance/status. No build, item list or shared minion/library changes.

Lobby checks: isolated Flux vs target beside allied creep/hero/summon; pack slow while escaping; Flux then Double then self/remote Field and Spark; main/Double chain Field without duplicating an active buff; outside ranged attacker evaded but attacker inside 300 not; secure river rune via Field; Spark activation prediction, creep interception and true 2000 range; ranged creep magic resistance; Double casts its basic spells despite shared-query bug, owned clone cooldown/liveness after expiry, Shard invisibility behavior, and independent Midas cooldown across summons; Rubick stolen spells. Remaining engine uncertainty: Spark interception/activation against moving packs, current Field modifier identity and rune ownership, Double engine dispatch/invisibility and item cooldown persistence. Counterplay/item/synergy findings sent to parent for TASK-21 / TASK-24; not implemented here.

Reviewed synergy setups: Axe/Shaman/Underlord lockdown supports Spark's1.8s activation prediction; Abaddon/Oracle protect the main/Double backline. Parent review fixed two accidentally duplicated query names in the stolen Spark retreat/scouting paths and added a retreat regression; the Arc focused spec passes.

Final integration review: added explicit current modifier_antimage_counterspell rejection to offensive Coil/Flux/Concoction target selection where applicable, because the older shared advanced-target helper only checks the legacy spell_shield name. Alchemist rejects the current shell even during the deadline Linkens-consumption exception. Native and stolen behavior scenarios cover these guards; the shared helper was not changed.

Final batch verification passed on the integrated state: node tests/run-builds.cjs (exit0 and all success markers), including all five new specs, Dazzle regression, Lua syntax for327 files,127 heroes/253 migrated roles,84 specialized Rubick dispatches,58 Rubick hero cases,272 purchase lists and all remaining shared scenarios. The suite includes node tests/valve_ability_check.cjs:128 hero files,21 Rubick copies,0 allowlisted findings at cf0d37a. git diff --check passed. Build/talent/skill-order data and Alchemist gifting were preserved. Offline acceptance is complete; lobby checklist remains outstanding and no live game was run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Corrected isolated Flux decisions/priority, self/remote/defensive/rune Field targeting, delayed bounded creep-safe Spark and owned Double liveness/query behavior; mirrored basic stolen spells and current Counterspell guards. Dedicated spec and full shared build/Valve suite pass. Field/rune/Double engine checks remain.
<!-- SECTION:FINAL_SUMMARY:END -->
