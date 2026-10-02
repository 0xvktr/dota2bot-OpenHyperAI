---
id: TASK-13.85
title: 'Undying: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:22'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_undying.lua
  - tests/undying_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_undying.lua
  - bots/FunLib/rubick_hero/undying.lua
  - tests/undying_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 125000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Undying is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Fix Soul Rip target and count errors, prioritize useful healing and Tombstone repair, and preserve human ally parity.
- Predict actual-range Decay and creep damage, place useful protected Tombstones and add current Shard bunker saves.
- Use Flesh Golem for real attack, sustain and escape opportunities; mirror copied abilities without innate assumptions.
- Support owned Tombstone minion grabs only through an actually usable unit ability.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs undying; https://dotacoach.gg/en/heroes/undying and https://dotacoach.gg/en/heroes/counters/undying (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native SkillsComplement and every consideration, fetched TDL guide 128742802, and read complete Dotacoach Strategy/Counter Strategy plus Matchup synergy, gameplay and advanced item cards.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Decay range 650, radius 325, cast point 0.3, base magical damage 20/60/100/140, Strength steal 4 or 8 with Scepter, and double creep damage. Strength steal occurs before damage, but reliable kill estimates do not guess a health conversion.
- Soul Rip range 750, collection radius 1300, maximum 10 units, damage/heal per unit 14/26/38/50, and Tombstone restoration 4/8/12/16. Collection excludes invisible, invulnerable, unseen and immune enemy units; allied immune zombies remain eligible.
- Soul Rip counts each eligible unit once, across both teams, creeps and neutrals, conservatively excluding caster and selected target from reliable damage/heal estimates. Exact engine self/target inclusion is a lobby follow-up.
- Tombstone range 500, zombie radius 1200, duration 30, and hero attacks to destroy 5/6/7/8. Shard permits an allied hero unit-target bunker, with two-second lockout and destruction stun penalty.
- Flesh Golem lasts 40 seconds, grants Strength 40/50/60%, movement speed 25, and attack-applied amplification/slow plus zombies. No passive resurrection or guaranteed zombie damage is assumed.
- Verified actual named minion ability undying_tombstone_unit_grab and conservative 350 bunker collection radius. Ownership uses the unit player ID; uncertain runtime owner metadata is documented for lobby verification.

Implemented behavior
- Replaced multiplicative and mutating Soul Rip counts with capped, deduplicated eligible unit counts. Enemy damage casts now target the enemy instead of Undying.
- Added urgent self/human/bot ally healing, Ice Blast checks, actual range and attacked allied Tombstone repairs, including the Tombstone building exception.
- Decay now predicts and clamps point casts within real range, favors useful hero clusters, and handles ranged last hits with the real double-creep multiplier.
- Added rearward Tombstone placement with coverage and hazard checks, existing-stone suppression, and current Shard saves when predicted nearby hero attack rates do not immediately destroy the bunker.
- Flesh Golem now supports single-target useful attacks, damaged retreat and supported objectives, with disarm and existing-form guards.
- Added four independent copied handlers and an owned Tombstone minion callback that uses the actual active grab handle and close eligible human or bot allies.
- Final optional-handle audit excludes null Lens inventory handles; a null-Lens range negative passes in the focused spec.

Rejected or stale source claims
- Rejected outdated reincarnation talent advice; current Ceaseless Dirge is a separate passive with 480-second cooldown and fountain respawn.
- Rejected claims that Soulbind duplicates a point-target Decay, that Cold Embrace forces enemy clustering, and blanket immunity denying all zombie pressure.
- No speculative full zombie damage, Strength conversion or immediate safe bunker survival is promised.

Item follow-up observations for TASK-21
- TASK-21: Review mana sustain for repeated Decay, Scepter Strength stealing, Locket/Greaves Soul Rip healing, Shard bunker saves, Blink positioning, team auras and defensive Glimmer/Lotus. No item build or generic policy changes.

Enemy counterplay observations for TASK-24
- TASK-24: Focus Tombstone with attack speed and range, kite Flesh Golem and zombies, track low resources, use anti-healing against Rip sustain and avoid clustered Decay exposure. Bunker destruction can punish the saved hero.

Lobby validation checklist
- Validate Soul Rip caster/target count inclusion, immune allied zombie eligibility and Tombstone restoration in hit-point units.
- Validate actual Shard allied cast shape, bunker lockout/destruction behavior and the conservative attack-rate estimate.
- Validate owned Tombstone player ID, active grab availability and conservative collection radius for human allies.
- No game or deep weak-hero validation was performed.

Focused verification
- Fengari tests/undying_ability_spec.lua passed: additive count and cap, correct enemy target, actual range, allied/immune healing, Ice Blast, visibility, Tombstone building repair, Decay clamping and creep multiplier, bunker range/safety, Flesh Golem state, copied unknown preservation, absent sibling and owned minion/hidden/null/queue guards.
- Native, copied handler and spec passed Lua 5.2 parsing.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.

Framework integration
- No hero pre-gate hook required. Copied X.ConsiderStolenTombstoneMinion(unit) can be forwarded from Rubick minion handling. Requires an alive visible allied Tombstone owned by caster player ID, no invulnerability/silence/stun/hex/channel/using/casting/queued actions, and a real usable undying_tombstone_unit_grab; casts only on an eligible close ally. Native MinionThink uses the same guarded decision.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Undying standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
