---
id: TASK-13.84
title: 'Tusk: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:13'
updated_date: '2026-10-02 16:24'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_tusk.lua
  - tests/tusk_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_tusk.lua
  - bots/FunLib/rubick_hero/tusk.lua
  - tests/tusk_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 124000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tusk is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Predict Ice Shards with actual projectile travel, use real casts and useful lane opportunities.
- Add root-safe Snowball saves and escape targets, observed ally pickup and launch decisions, and independent copied behavior.
- Prepare useful Tag Team attacks, use reliable Walrus Punch physical damage, and update Drinking Buddies to current Shard movement and armor mechanics.
- Document current Walrus Kick vector limitations without inventing unsupported cast APIs.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs tusk; https://dotacoach.gg/en/heroes/tusk and https://dotacoach.gg/en/heroes/counters/tusk (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native SkillsComplement and every Consider function. Fetched and read TDL guide 129069615, full Dotacoach Strategy and Counter Strategy, and every Matchup gameplay and item card.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Ice Shards range 1400, width 200, speed 1200, cast point 0.1, magical damage 75/150/225/300 and current Shard no longer improving Shards.
- Snowball range 1150, three-second gather windup, grab radius 325, nonpiercing magical damage and root restriction. Ally pickup is a right-click command; a pickup command is not treated as proof of successful collection.
- Tag Team radius 350, six-second duration and nonpiercing per-attack bonus physical damage. Useful attacks and enough mana for a ready Punch justify preparation.
- Walrus Punch is a piercing true-strike attack with bonus damage 60/90/120 and crit 200/250/300%. Guaranteed kill estimates conservatively use the critical attack component without random procs or unverified bonus ordering. Attack range, attackability and disarm checks apply.
- Current Drinking Buddies is Shard-granted, range 1000, shared pull above minimum distance 250, armor 7 and movement speed 25% for six seconds. Roots and Snowball prevent casting; alt-cast is obsolete.
- Current Walrus Kick KV is UNIT_TARGET plus VECTOR_TARGETING, while localization describes nearest-unit directional selection. The bot API has no verified vector endpoint command. Existing disabled Kick remains an explicit engine constraint, not a completed deep behavior pass.
- Observed Snowball modifier and linked Launch availability gate the continuation. Engine verification of exact runtime modifier timing remains a lobby check.

Implemented behavior
- Removed the extra two seconds from Shards prediction and used actual Lens and unbroken Supremacy range. Moving targets can receive a barrier point beyond their predicted position; reliable damage and ranged last hits use real travel time.
- Fixed unreachable retreat creep selection by choosing a reachable enemy creep closer to escape. Added urgent self-projectile protection, nearby wounded or disabled ally saves, safe endpoints and root/leash/Rupture guards.
- Added a narrow Snowball continuation that issues pickup for an eligible nearby human or bot ally, throttles only the request, and checks the actual friendly Snowball modifier before considering that ally collected. Save and escape intentions preserve the protective gather window.
- Prioritized immediate Punch interrupts and saves, prepared Tag Team only for useful attacks and affordable follow-up, and added reliable physical Punch kills without Lens padding.
- Drinking Buddies now rejects harmful shared-pull destinations and immobile allies, supports escape or ally extraction, and applies useful close-range armor/movement buffs.
- Added six independently copied handlers including Launch, with unsupported-name preservation and nil/null/hidden/deactivated sibling safety.
- Follow-up human ally parity: protective decisions use actual recent damage and observed pursuit without requiring a bot retreat mode. Drinking Buddies also accepts an actual allied attack target or pickup threat.
- Final optional-handle audit excludes null Lens inventory handles; a null-Lens range negative passes in the focused spec.
- Dream Coil movement guards now use the pinned localized modifier_puck_coiled name.

Rejected or stale source claims
- Rejected Frozen Sigil loading advice, obsolete Shard Shards upgrades, old Drinking Buddies damage/alternate cast, old Arcane Boots disassembly and Halberd persisting through immunity.
- Did not encode speculative Walrus Kick vector direction or arbitrary manual vector APIs.

Item follow-up observations for TASK-21
- TASK-21: Review Blink positioning and ally saves, Scepter directional Kick support once engine control is verified, current Shard pull, armor reduction for physical Punch, BKB after commitment, and defensive Glimmer/Force/Lotus decisions. Builds and generic item policy are unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: Roots and leash deny Snowball or Buddies, displacement escapes Shards, mobility changes Snowball endpoints, armor and ethereal defenses reduce Punch, and clustered Snowball pickups risk area counter-initiation.

Lobby validation checklist
- Validate own Snowball runtime modifiers, pickup Action_AttackUnit behavior and request throttling, linked Launch activation, and Shards/Tag Team use during gather or movement.
- Validate current Walrus Kick cast shape, supported direction controls and Punch bonus-damage ordering before a deeper pass.
- No game or deep weak-hero validation was performed.

Focused verification
- Fengari tests/tusk_ability_spec.lua passed: range, travel/regeneration, immunity, ranged last hits, retreat-creep selection, root/endpoint safety, human ally pickup, observed collection, request throttling, Punch attack range and disarm, affordable Tag Team, Buddies safety, unknown dispatch and optional hidden/null/deactivated linked handles.
- Focused specification rerun after human ally parity follow-up passed.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.
- Native and copied actual Coiled movement negatives pass; Ursa rooted stationary damage remains available under Coil, while Tusk Snowball/Buddies and Viper Nosedive movement decline.

Framework integration
- Native X.ConsiderSnowballContinuation and copied X.ConsiderStolenSnowballContinuation. Require actual own Snowball modifier, preserve alive/stun/hex/nightmare/silence/casting/queue/Box/Doom/Force guards; any using/channel state must have active tusk_snowball. May bypass only actual Snowball invulnerability. Actions are eligible ally pickup, Ice Shards, Tag Team or active Launch.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Tusk standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
