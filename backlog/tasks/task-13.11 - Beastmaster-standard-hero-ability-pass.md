---
id: TASK-13.11
title: 'Beastmaster: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 14:21'
updated_date: '2026-10-01 14:54'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_beastmaster.lua
  - bots/FunLib/rubick_hero/beastmaster.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 51000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beastmaster is in the next standard-pass batch after Abaddon/Underlord/Alchemist/Anti-Mage/Arc Warden. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing builds and future role differentiation in TASK-37 remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify current active slots, Wild Axes path/damage amplification, autonomous Raptors, passive Drums and immunity-piercing Roar against pinned Valve KV/localization, TDL and full dotacoach advice.
2. Fix direct Roar priority/legal reach, safe bounded Blink initiation and standalone stolen Roar; add channel interrupts, retreat control and explicit reflection guards.
3. Correct Axes placement, camp targeting and lane pressure; keep summons available for lane trades, close fights, objectives and farming without restoring obsolete scouting/Shard behavior.
4. Mirror applicable decisions in Rubick, preserve D2PT builds and generic minion ownership, and add meaningful offline scenarios with a distinct success marker.
5. Run focused spec, Valve and syntax/whitespace checks; record source exclusions, item/counterplay follow-ups and lobby scenarios for parent shared-suite validation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01):
- Pinned Valve hero KV/localization: https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_beastmaster.txt and matching dota/resource/localization/abilities_english.txt. Active slots are Wild Axes, Razorback, Raptors, passive innate Inner Beast, passive Scepter Drums, and Roar. Roar pierces debuff immunity; base range 600 and talent +200, stun 3/3.5/4. Wild Axes are point/path damage, one hit per axe, travel duration 0.4–1 seconds; amplification is on enemies, not a global damage bonus. Shard applies stacks on Beastmaster attacks against heroes. Raptors are autonomous, radius 500, duration 25 seconds, two hawks; Drums radius 525 with 10 stacks from Roar. No active Drums or obsolete Inner Beast activation added.
- TDL guide 129134687, 7.41f Zoo/offlane, fetched with node tools/tdl/fetch.cjs beastmaster: reviewed Roar initiation and summon focus, Axes lane pressure, mana/aura/item follow-through. Excluded old shared Call of the Wild/scouting Hawk/random level-four creep tips, Inner Beast affecting all nearby allies, Shard extra-hawk/cooldown advice, damage-taken Drums trigger, and enemy-target Solar Crest claims. Current Solar Crest KV is friendly-target only; item build untouched.
- dotacoach Strategy/Counter Strategy: https://dotacoach.gg/en/heroes/beastmaster — reviewed summon safety, Raptors close control, lane last-hit support, siege and early Roshan pressure, avoiding solo walks into root/Roar, and spell block/reflection responses.
- Full dotacoach Matchup/core/counter-item/synergy page: https://dotacoach.gg/en/heroes/counters/beastmaster — reviewed every gameplay entry and item section. Roar sets up delayed ally nukes (AA/Invoker/Skywrath) and global arrivals (Spectre/Prophet); summons support siege, while AoE clearing, armor, barriers, repositioning and spell block/reflection oppose it. Current Shard and passive Drums claims agree with Valve. Excluded old scouting/vision implications, universal Cold Blooded claims, and Chakra reducing ultimate cooldown; those are not supported by current Beastmaster definitions. Statistical win-rate rankings were not converted to logic.

Implementation:
- Direct Roar now precedes Blink. Interrupts any valid channel, handles retreat pursuers, chooses only legal cast reach, and explicitly rejects current Counterspell in addition to shared block/reflection checks. Blink reaches targets outside direct range (including BKB targets), stops inside Roar range without exceeding its maximum distance, and refuses roots, Rupture, insufficient mana, impassable or Chronosphere/Black Hole landings and outnumbered initiations. Native Roar sets the bot target so existing controllable summons follow the focus.
- Axes predict outgoing travel, keep disabled targets stationary, clamp legal cast points, pressure enemy heroes in lane while preserving combat mana, and select real lane/camp clusters instead of reusing a lane AoE for unrelated neutrals. Kill estimates remain conservative at one axe; they do not assume both axes connect.
- Razorbacks are useful even inside melee range and during laning/siege/farm/objectives. Raptors can remain useful after an existing short disable and contribute in farming/objectives. Native MinionThink leaves autonomous Raptors alone and retains generic control for Razorbacks and dominated creeps.
- Applicable decisions mirrored in Rubick; stolen Roar no longer assumes stolen Wild Axes exists. Existing D2PT build/items/talents/skill progression preserved. Generic item, draft, counterplay and role differentiation changes stay out of this pass.

Offline verification:
- tests/beastmaster_ability_spec.lua passes with marker Beastmaster ability scenarios passed. Both native and stolen scenarios cover direct BKB Roar before Blink; all-channel interrupt; legal range; block/reflection/Counterspell/illusion rejection; retreat control; bounded Blink and root/Rupture/hazard/outnumbered/mana guards; Axes prediction/clamping/disabled targets; correct neutral camp; spread last-hit rejection; lane pressure/mana; melee Razorback; persistent Raptors/farm; independent stolen Roar; and autonomous-vs-controllable minions.
- Lua 5.2 parse passed for native/copy/spec, node tests/valve_ability_check.cjs passed, and owned-file git diff --check passed. Parent owns shared-suite integration and final AC/status.

Lobby checklist (not run):
1. Direct-range and 1600-range Blink Roar on BKB enemies; confirm current talent/item cast range and Blink landing followed by immediate stun.
2. Interrupt TP and non-ultimate channels; verify Linkens/Lotus/current Counterspell rejection and retreat Roar on a pursuer.
3. Axes on close stunned, moving edge-range and clustered/spread wave/camp targets; check the curved paths and conservative kill estimates in engine.
4. Lane mana preservation; Razorback in melee combat and tower pressure; two Raptors attack the current target and remain useful after initial stun/root.
5. Scepter passive Drums builds from attacks and Roar, with no attempted active cast; Shard attacks apply stacks without legacy extra-hawk behavior.
6. Rubick stealing Roar alone and the summon spells; observe autonomous Raptors, generic boar control, range bonuses and spell-steal lifetime changes.

Cross-review follow-up: cast reach now adds real Aether Lens and active Rubick Arcane Supremacy bonuses; no movement allowance is used, and broken Supremacy adds nothing. Blink reserve includes Blink plus Roar cost; optional BKB is queued only when the total including its mana cost remains affordable. Native and stolen regressions cover range bonuses, broken passive, insufficient combined mana, skipped unaffordable BKB and affordable full combo. Focused spec, Valve checker, Lua parse and whitespace passed again.

Final review: Axes rejects predicted positions beyond the legal clamped endpoint plus axe radius instead of issuing a guaranteed miss or a nil location. Both native/stolen tests also prove an unreachable kill candidate does not hide another reachable kill. Supremacy break detection now uses the shared bot-compatible J.HasBreakModifier helper supplied by parent; server-only PassivesDisabled is not used. The helper covers verified known break modifiers, with additional future break sources requiring updates.

Final integrated verification: node tests/run-builds.cjs passed (exit 0): Lua syntax336 files; Valve128 hero files/21 Rubick copies, zero allowlist findings;127 heroes/253 migrated roles;85 specialized Rubick spell dispatches;58 Rubick hero cases;272 purchase lists; all new hero, Split and Break scenarios. git diff --check passed. Sources and lobby checklist recorded; no game run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Beastmaster standard pass: direct immunity-piercing Roar, safe budgeted Blink, reachable predicted Axes and modern summon use. Standalone Rubick Roar and behavior scenarios covered; full offline suite passed; ready for lobby.
<!-- SECTION:FINAL_SUMMARY:END -->
