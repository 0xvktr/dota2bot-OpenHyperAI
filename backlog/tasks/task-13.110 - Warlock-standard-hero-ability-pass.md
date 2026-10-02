---
id: TASK-13.110
title: 'Warlock: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:22'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_warlock.lua
  - tests/warlock_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_warlock.lua
  - bots/FunLib/rubick_hero/warlock.lua
  - tests/warlock_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 150000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Warlock is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Prioritize current Shadow Word healing anchors and actual visible Fatal Bonds link opportunities.
- Use legal predicted Offering opportunities and useful safe Upheaval without ready-sibling deadlocks.
- Replace blind queued double-Offering with an observed cooldown/mana/current-opportunity Refresher decision through the existing native interface.
- Cancel only an actual Upheaval channel under observed survival threat; preserve unrelated actions and existing golem/imp behavior.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs warlock; https://dotacoach.gg/en/heroes/warlock and https://dotacoach.gg/en/heroes/counters/warlock (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read complete native controller and every consideration, TDL guide 128891336, full Dotacoach Strategy/Counter Strategy and all Matchup synergy, gameplay, core and counter-item cards. Refreshed TDL through node tools/tdl/fetch.cjs warlock.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Fatal Bonds unit target, range 1000, cast 0.2, visible link search 700, target cap six plus five talent, share 15/18/21/24% plus talent and duration 18. Shared damage preserves damage type and is reflected damage, with no lifesteal/re-reflection.
- Shadow Word is unit-target on either team, range 650/700/750/800, cast 0.2, rate 15/25/35/45, duration ten seconds, tick 0.5, always effect radius 225 plus 150 talent. Both allied and enemy hosts affect nearby units; default AoE does not require a talent or obsolete Shard.
- Upheaval is point/channelled, range 800, cast 0.4, area 575/600/625/650, maximum channel 10/12/14/16, slow grows 11/14/17/20 per second to 55/70/85/100%, linger one second and damage ramps to 35/60/85/110. Current cooldown 45/40/35/30; Shard spawns an imp every two seconds for 15 seconds.
- Offering pierces debuff immunity, cast 0.5 plus stun delay 0.5, range 900, radius 600, stun 0.8, mana 200/400/600, cooldown 165 and golem lifetime 60. Scepter calls two golems; current Scepter HP stays 1500/2250/3000 while damage is 80/120/160 compared with ordinary 100/150/200.
- Eldritch Summoning is current innate, scales imp HP and speed by hero level and damage by every three levels; Shard adds 80 HP and 45 explosion damage. Minor imps auto-seek affected targets and do not explode when enemy heroes kill them. Copied spells do not assume an absent innate.
- Existing shared ConsiderItemDesire[item_refresher] consumes BotBuild.CanUseRefresherShard; only the native Warlock interface is added, leaving shared item code untouched.

Implemented behavior
- Shadow Word heals self and visible human/bot allies including immune allies, scores actual healable missing HP around each legal host, avoids ineffective Ice Blast targets and existing Word hosts, and uses conservative first-tick damage for lethals.
- Fatal Bonds selects a legal visible local cluster containing actual useful heroes and creeps, caps its heuristic count at the current special value and supports lane links. Offering is no longer indefinitely blocked by a ready Bonds with no target.
- Offering interrupts visible channeling targets through BKB and uses actual cast/landing prediction with a cast point clamped within true Lens/Supremacy range; useful current multihero counter-initiation and threatened retreat are supported. Urgent interrupts precede healing/Bonds; ordinary useful Bonds prepares the next observed tick.
- Upheaval considers actual eligible target area, safe caster position, pressure and current Shard local creep packs; it no longer declines simply because an unrelated sibling is ready. Current action gates and item-aware Power Treads preparation remain.
- Blind queued Offering/Refresher/Offering sequence is removed. Native CanUseRefresherShard requires actual observed Offering cooldown, ready Refresher and mana for Refresher plus one Offering, with at least two current eligible targets; no successful first summon is inferred from a request.
- Native and copied Upheaval safety callbacks inspect the actual current channel ability before issuing survival cancellation and movement. Other channels, queues, disables and no-threat channels are preserved. Existing ordinary golem control and automatic minor imp behavior remain.

Rejected or stale source claims
- Rejected old talent-only Shadow Word AoE and obsolete Shadow Word Shard movement, ordinary healing of Supernova, ability use while trapped by Black Hole, guaranteed Offering wipes, and claims that BKB makes Warlock entirely unable to interrupt. Source card self Solar Crest and Glimmer channel claims need item-specific current mechanics review.

Item follow-up observations for TASK-21
- TASK-21: Observed Refresher mana/readiness and useful multihero opportunity now integrate through the existing native interface. Generic Refresher fallback still uses shared policy and was not edited. Review Glimmer/Ghost channel protection, current Solar Crest self-cast limits, Bearing/golem buffs and actual Shard imp generation; no build changes.

Enemy counterplay observations for TASK-24
- TASK-24: Respect actual dispels of Bonds/Word, immunity versus Upheaval, Offering piercing interruption, dangerous visible caster pursuit, and golem gold feeding. Reflected Bonds damage must not be counted as extra lifesteal or reflected again; enemy cooldowns are not inspected.

Lobby validation checklist
- No game run. Validate actual Word host modifier and nearby heal tick behavior, visible link selection/order and chain expansion, Offering stun/golem ownership timing, Scepter stat differences and Shard imp lifecycle.
- Existing golem generic controller and automatic imp seeking remain; this pass does not claim a deep minion lifecycle/engine audit. Validate queued Power Treads preparation and actual Refresher item-policy fallback interaction in lobby.

Focused verification
- Warlock native/copied Fengari focused scenarios passed: self and human/immune cluster healing, Ice Blast and existing Word, tick damage/regen, visible Bonds links, ready-sibling combo progression, BKB channel interruption, legal range/radius prediction, protected channels/queues, Shard local farming and actual Refresher cooldown/mana/current-target gates.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.

Framework integration
- Native ConsiderUpheavalSafety and copied ConsiderStolenUpheavalSafety: actual bot channel and current active ability warlock_upheaval required before any other action; actual HP below 40% plus recent hero damage or attack projectile threat triggers cancellation. Alive, queue, stun/hex/nightmare/silence, Box/Doom/Force Staff exclusions retained. Root wires before ordinary channel gate; no invulnerability exception.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Warlock standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
