---
id: TASK-13.15
title: 'Bristleback: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 15:23'
updated_date: '2026-10-01 18:12'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_bristleback.lua
  - bots/FunLib/rubick_hero/bristleback.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 55000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bristleback is in the next standard-pass batch after Axe/Bane/Batrider/Beastmaster/Brewmaster. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing D2PT builds, separate TASK14 build findings and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve/localization with TDL guide 134962374 and dotacoach Strategy, Counter Strategy and full Matchup, rejecting removed Seeing Red/Snot Rocket facets and stale item/Break claims.
2. Preserve builds; fix Goo legal reach, reflection guards, real enemy selection, lane/retreat use and mana for Quill. Prioritize lethal Quill, Hairball/Goo setup before Scepter burst, and bound/predict Hairball centers including immune enemies.
3. Make Quill hit actual targets, secure physical/stack-aware lane last hits, farm groups and maintain Warpath only in useful combat/farm contexts when unbroken. Use current Scepter spray radius/timing rather than arbitrary 350-range gating, avoiding desperate self-slow or futile chasing. Remove obsolete Warpath active behavior. Mirror applicable decisions in Rubick without needing absent linked spells.
4. Add meaningful native/copy scenarios, focused Valve/parse/whitespace checks, and record source exclusions and fixed-roster lobby cases. Parent runs shared suite and finalizes status.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): pinned Valve npc_dota_hero_bristleback.txt and English abilities localization, commit cf0d37a32c8df338a7832fd32a282747969e9a5f; tests/valve/abilities.json matches. Valve confirms 650 Goo reach (talent extension remains engine-reported), 700 physical Quill radius/85+30 existing stacks capped at 500, 0.5s Scepter delay/five sprays/0.4s intervals/facing lock/disarm/40% slow, passive Warpath, deprecated facets, and Shard Hairball 750 center reach/700 radius/1200 projectile speed/one Quill/two Goo stacks. Hairball KV has anomalous SPELL_IMMUNITY_ALLIES_YES on an enemy ability; both current dotacoach mechanics and TDL explicitly support BKB targets, which remain in decisions and lobby checks.
TDL Workshop 134962374, Position 3, patch 7.41f: https://steamcommunity.com/sharedfiles/filedetails/?id=134962374, fetched using node tools/tdl/fetch.cjs bristleback. Reviewed early Goo setup, lane Quill harass/last hits, Warpath mobility, Shard catch, clustered farm and Scepter setup. Excluded old Seeing Red, removed talent tips, only-Goo/Quill stack claim, automatic passive-proc stack claim (pinned localization says spells cast), universal BKB-removes-Break claim, enemy Solar Crest and blanket passive removal by Nullifier. Existing builds and TASK14 findings unchanged.
dotacoach https://dotacoach.gg/en/heroes/bristleback and https://dotacoach.gg/en/heroes/counters/bristleback: read full Strategy, Counter Strategy, matchup synergy/core items/good-and-bad matchups/counter items. Applied lane Goo supporting physical teammates, physical AoE versus summons, protection from kiting, mana conservation versus Wand, and safe controlled Scepter bursts. Reviewed Abaddon/Dazzle/Oracle sustain/dispel support, Grimstroke/Ogre/Willow control, physical armor amplification, break/healing reduction and forced facing threats (Viper, AA, Duel/Call). Excluded obsolete Snot Rocket and Venomancer Poison Nova references, and unverified claims about every heal or support dispelling every Break. Item policy follow-ups (Lotus dispels, BKB versus specific breaks, armor, healing reduction, anti-TP disable) belong to TASK21/24, not this ability pass.
Implementation: native and Rubick decisions now use actual range bonuses with known Break handling for Supremacy; target selection skips out-of-range/reflected/immune Goo and refreshes fresh capped Goo only near expiry. Quill uses full real radius and physical stack damage for lane last hits, preserves farm mana, attacks actual nearby targets and can preload unbroken Warpath before a real engagement. It does not idle-spam. Lethal Quill precedes Hairball/Goo/Scepter setup; Hairball predicts impact, bounds centers to legal reach and checks predicted AoE coverage, including immune targets. Scepter uses the Quill radius, controlled/slow targets and clustered camps, avoiding self-slow while escaping. Removed obsolete Warpath active. Missing linked Rubick ability handles do not crash decisions.
Focused verification: tests/bristleback_ability_spec.lua exact marker Bristleback ability scenarios passed; native/copy scenarios cover range bonuses/known Break, Counterspell/block, capped Goo refresh, low-health escape slow, lane pressure, physical mitigation/stacks, immunity, no empty teamfight spam, predicted Hairball edge/coverage, safe Scepter control/farm, cast priority, useful Warpath maintenance and missing linked stolen Quill. Lua 5.2 parse and node tests/valve_ability_check.cjs pass (128 heroes, 21 copies, zero allowlisted findings); git diff --check clean. Parent integrates shared suite/final status.

Fixed-roster lobby checklist (pending; no game launched): Bristleback/Rubick + Ogre/Abaddon/Dazzle versus Axe/Viper/Anti-Mage/Lifestealer/illusion or summon hero. 1. Lane: attack a creep before Quill, verify armor and existing stacks change last-hit threshold, use Goo for supported aggression without exhausting Quill mana. 2. Chasing/retreat: maintain useful Warpath, confirm zero stack gains under known Break, verify Goo ignores BKB/Counterspell/block and slows actual pursuer; verify Hairball and Quill affect BKB target. 3. Shard: moving target at 750–1450 range, confirm legal center/AoE edge and travel prediction; do not count a second hero that leaves impact area. 4. Scepter: Hairball/Goo setup then burst stationary or disabled enemy at 650 range; verify enemy-point targeting actually directs the rear cone at that enemy, all five pulses land, facing/disarm/slow and other casts during active behave correctly. Tooltip rotates toward point yet says rear cone, so facing semantics require direct observation before any opposite-direction change. Refuse fleeing target or emergency escape self-slow. Verify tight ancient group versus spread group. 5. Confirm passive Warpath never receives an active command and current talent/level prefixes remain unchanged. 6. Rubick: steal each available spell with/without Scepter/Shard, verify dynamic upgrade behavior and whether Hairball/Bristleback require granted linked Goo/Quill; test Lens/Supremacy reach with known Break and observe engine-reported cast bonuses to rule out duplication. Item-specific Break dispels and general movement/back-facing decisions remain broader policy follow-ups.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 with all five new hero success markers and prior regressions. Lua syntax: 341 files; pinned Valve check: 128 native hero files / 21 Rubick copies / 0 allowlisted findings; builds: 127 heroes / 253 roles; specialized Rubick: 85 dispatches; Rubick hero behavior: 59 cases; purchase planning: 272 buy lists. git diff --check passed. Scripted HEAD comparison confirms all five build/skill/talent prefixes unchanged. Lobby scenarios remain pending; no game launched. Standard pass is ready for in-game testing, with documented engine/capability limits.

Commit/push integration (2026-10-01): remote main advanced through6616fcb item policy and3c1501b early lane-defense. Rebase preserves both remote commits and all20 hero passes. BB Hairball/ordinary Quill retain selected ability handles for item/Treads policy. CK retains remote Clear/action lock and useful low-mana Chaos Bolt consideration, validated restoration in urgent/ordinary branches, and ability-aware normal Bolt/Rift/Phantasm prep; urgent Bolt retains immediate priority, and failed restoration allows other spells. Faithful CK tests cover enabling Mango, changed target, post-restoration reconsideration, no-item Rift fallback and queued lock. Independent merged review passed. Combined node tests/run-builds.cjs and node tests/run-objectives.cjs both exited0;375 Lua files,128 native/32 copy Valve checks with zero findings,133 copied dispatches,68 Rubick cases and272 purchase lists, plus remote item-policy and lane-defense/objective regressions. No game launched.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated native/stolen Bristleback legal Goo, stack/physical-aware Quill last hits and useful Warpath maintenance, predicted Hairball and controlled Scepter setup; removed obsolete Warpath active. Focused and full suite/Valve/diff checks pass; facing/upgrade semantics await lobby observation.
<!-- SECTION:FINAL_SUMMARY:END -->
