---
id: TASK-13.79
title: 'Puck: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:10'
updated_date: '2026-10-02 16:17'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_puck.lua
  - tests/puck_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_puck.lua
  - bots/FunLib/rubick_hero/puck.lua
  - tests/puck_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 119000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Puck is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Observed own Orb escape instead of fixed queued sequence; Phase before damage, safe Rift landing, legal Coil control and independent stolen spells.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs puck; https://dotacoach.gg/en/heroes/puck and https://dotacoach.gg/en/heroes/counters/puck (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read TDL128855291 and complete Strategy, Counter Strategy and Matchup at https://dotacoach.gg/en/heroes/puck and https://dotacoach.gg/en/heroes/counters/puck.
- Valve Orb: vector/alt cast, 1950 maximum travel, 750 speed, 225 radius and 70–280 initial magical damage (+35 talent). Current curved Orb and small periodic damage are not treated as guaranteed additional hits.
- Rift: 350 movement and 400 radius, both +350 talent; 60–240 magical damage, 2–3.5 seconds silence. Phase: 1–3.25 seconds channel, Shard attack has +20 damage and zero old range bonus.
- Jaunt disables under roots. Coil: 750 cast range, 375 area, 175–325 initial damage, 0.5 second initial stun, 600 break radius and 5–6 seconds leash; Scepter attack rate 90%, no current immunity upgrade.

Implemented behavior
- Orb uses flight prediction and actual maximum travel, reliable initial damage with regeneration, ranged last hits and local farm groups.
- Phase Shift gets first opportunity for incoming control/attacks; removes blind delayed Orb/Phase/Jaunt queue.
- Jaunt requires projectile caster equal to bot and source ability equal to its own Orb handle, safe landing and meaningful escape distance or supported approach.
- Rift clamps to real movement and area, avoids dangerous landing and uses self-centered cast under mobility constraints.
- Coil interrupts channels and catches real predicted targets at a legal center, without hypothetical break damage or repeated current leashes.
- Precise native ConsiderPhaseJaunt and copied ConsiderStolenPhaseJaunt require observed Phase modifier, channel and matching active ability; root/leash, queue and unrelated locks remain enforced.

Rejected or stale source claims
- Rejected old Shard range, Scepter Coil immunity and fixed Phase/Jaunt timing assumptions.
- Rejected Matchup claims that Soulbind extends Coil, Bane targets invulnerable Phase, and Nyx still has old Mana Burn.

Item follow-up observations for TASK-21
- TASK21: Blink escape after Phase damage cooldown, Witch Blade/Parasma physical follow-up, Shard Phase attack and Scepter Coil attacks, Eul dispel versus silence; no guaranteed proc damage or item build changes.

Enemy counterplay observations for TASK-24
- TASK24: instant disable/silence before Phase, spread out versus Coil, stand and fight when safely leashed, magic resistance and current debuff immunity, punish rune and side-lane exposure.

Lobby validation checklist
- The bot API supplies one point for current vector/curved Orb. Direction/curvature and exact own projectile handle identity need engine validation.
- Phase-to-Jaunt channel exit, rooted Rift self-cast, legal Rift landing and Coil attack upgrades require live checks.

Focused verification
- Fengari tests/puck_ability_spec.lua passed. Native, copied module and spec parse as Lua 5.2.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 shared movement safety follow-up: pinned English localization explicitly names modifier_puck_coiled (Dream Coiled). Replaced inherited modifier_puck_dream_coil checks with the actual debuff name in this previously passed hero. This is a narrow API/mechanics correction; preference assignments remain intact. The final Queen of Pain → Zeus integrated suite covers these files; lobby movement validation remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Puck standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
