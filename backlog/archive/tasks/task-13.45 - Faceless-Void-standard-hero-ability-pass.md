---
id: TASK-13.45
title: 'Faceless Void: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_faceless_void.lua
  - tests/faceless_void_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_faceless_void.lua
  - bots/FunLib/rubick_hero/faceless_void.lua
  - tests/faceless_void_ability_spec.lua
  - bots/FunLib/faceless_void_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 85000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Faceless Void is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Update Chronosphere’s allied safety and attack-cycle damage, timely backtracking of recent damage, safe original-position Reverse, and observable combat reasons for Time Dilation. Keep copied abilities independent.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs faceless_void; https://dotacoach.gg/en/heroes/faceless-void and https://dotacoach.gg/en/heroes/counters/faceless-void (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Time Walk is a directional point movement spell that cannot be used while rooted. Its movement range is 650/700/750/800, plus the current 125-range talent. It backtracks two seconds of damage, or 2.5 seconds with the talent, moves at 3000 speed and costs 40 mana.
- Scepter applies Time Lock within 325 radius and grants Reverse. Copied Walk does not assume Time Lock is present. Reverse is a no-target, root-disabled spell available for 1.5 seconds after landing; it restores neither health nor Time Lock hits.
- Time Dilation is a no-target spell with 700 radius and 7/8/9/10 second duration. It has one base stack plus a stack per ability cooldown, deals magical damage and excludes debuff immunity. Stack count changes dynamically and duration pauses in Chronosphere. Shard grants fading movement and attack speed and stronger slows.
- Chronosphere has 500 point cast range, 500 catch radius plus the current 140-radius talent, and 3.75/4.25/4.75 second duration. It freezes allied heroes, exempts every Faceless Void and his controlled units, and reveals invisible enemies.
- Time Lock is a breakable magical attack proc. Backtrack and Distortion Field passives remain engine controlled.
- Read the full Torte guide, Strategy, Counter Strategy and Matchup cards. Cached pages identify the intended hero, and pinned Valve KV and localization were checked.

Implemented behavior
- Removed retired Time Zone recovery code, its old 7.37 workaround and chat noise. A hidden old spell is not a fallback ultimate.
- Observed health loss within the current backtrack window gives emergency Time Walk priority and bypasses the offensive Chronosphere mana reserve. Root and active Chronosphere guards remain.
- Healthy, unprotected early chase Walk is withheld. Scepter’s attack rationale requires a real, unbroken Time Lock on the actor. Destinations use the true movement range.
- Record the original cast position and Reverse expiry. Reverse is allowed only toward a safer, passable, baseward origin and cannot undo a successful escape.
- A ready Chronosphere catch precedes nonurgent Walk or Dilation. Allied hero traps are rejected; an enemy Faceless Void does not count as controlled.
- Chronosphere centers use actual cast range plus Lens or Supremacy. Solo damage uses duration divided by seconds per attack, rather than integer attack speed.
- Dilation uses its current base stack for useful chase, retreat and teamfight casts. Enemy cooldowns are not exposed by the supported API and do not justify idle casting. Live debuffs and immune targets are excluded.
- Native and copied spells share Void-specific decisions without assuming hidden spells or missing passives.

Rejected or stale source claims
- Time Zone is retired and hidden; its obsolete 7.37 recovery logic was removed.
- Torte says Dilation works only after cooldowns. Current localization gives it a base stack even when no enemy ability is on cooldown.
- The old Shard Reverse upgrade claim is excluded. Scepter currently grants Reverse; Shard improves Dilation.
- Current immunity descriptions exclude assuming that a copied Chronosphere controls an enemy Faceless Void.

Item follow-up observations for TASK-21
- TASK-21: BKB protects aggressive Walk and Chronosphere. Silence from Mask of Madness should follow chosen spells. Manta can dispel Dilation and slows; Refresher requires enough mana for both Chronospheres.

Enemy counterplay observations for TASK-24
- TASK-24: spread against Chronosphere’s actual radius, apply continuous damage beyond the backtrack window, pressure after Walk, and save or interrupt from outside the sphere. Every Faceless Void can move freely in any Chronosphere.

Lobby validation checklist
- Validate damage-window sampling under regeneration and health costs, including an emergency cast at low mana. The implementation observes health loss together with recent hero damage.
- Validate Reverse visibility, activation and its 1.5-second landing window. An interrupted Walk may change the real origin; Reverse still requires live availability.
- Validate copied Chronosphere actor exemptions, allied and enemy Void interactions, actual attack timing and moving-target bounds.
- Validate fading Shard Dilation stacks and the duration pause through Chronosphere.
- Enemy cooldown timers return zero in the supported API. Dilation relies on observable combat need and its base stack.

Focused verification
- The native and copied Faceless Void Fengari scenarios passed, all four files parsed as Lua 5.2, and the global Valve check passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Faceless Void standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
