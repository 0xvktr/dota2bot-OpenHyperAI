---
id: TASK-13.83
title: 'Snapfire: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:13'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_snapfire.lua
  - tests/snapfire_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_snapfire.lua
  - bots/FunLib/rubick_hero/snapfire.lua
  - tests/snapfire_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 123000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Snapfire is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair Gobble and Spit state, validate Cookie landing geometry and support saves, improve close-range damage and hit-count attacks, and start Kisses from a safe position with a predictable first impact. Mirror supported casts for Rubick and test native and copied decisions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs snapfire; https://dotacoach.gg/en/heroes/snapfire and https://dotacoach.gg/en/heroes/counters/snapfire (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native SkillsComplement and all six Consider functions, the full Torte guide 1921553241, and all Dotacoach Strategy, Counter Strategy, synergy, matchup, core item, and counter item cards.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f and localization verify Scatterblast damage 100/160/220/280, speed 3000, range 800, point-blank threshold 450 and bonus 25%; runtime long-range flag reverses the bonus for the deprecated Full Bore definition.
- Cookie uses actual range 650, jump 425, radius 300, jump duration 0.484, projectile speed 1200, self delay 0.3, impact damage 60/130/200/270, and Shard healing 175. Channeling targets are forbidden by the localized target error.
- Shredder grants 160/240/320/400 attack range and five attacks, using fixed damage plus attack damage. Kisses has range 3000, minimum 600, impact radius 275, impact damage 170/250/330, speed 1300 and travel clamped to 0.8–2 seconds; its 5.5-second barrage is a modifier, not a KV channel.
- Scepter Gobble range is 150 and belly limit is three seconds. Spit has its own range 3000, speed 1400, travel 0.1–2 seconds, radius 400, stun 1.2 and no minimum range. Spit does not need a present Kisses handle for its supported cast.
- Spell ranges use actual Lens 225, trained cast range talent value, and trained unbroken Rubick Supremacy 240. Scatterblast conservatively uses its verified projectile length and does not infer increased travel from a cast-range item.

Implemented behavior
- Moved ability decisions into the dedicated Snapfire module while preserving native build, skill, talent, item, role and minion initialization.
- Fixed the ally Gobble assignment that replaced the ability handle and the misspelled swallowed-creep marker. Record swallowed kind separately; release saved allies toward a safe escape point and spit creeps at a legal predicted target. Prioritize Spit and rescue opportunities.
- Cookie now tests the facing-based landing point, passability, tower danger, Chronosphere and Black Hole, exact ally cast range, roots, channeling and illusions. Hero allies use the same rescue and Shard heal policy regardless of player control.
- Scatterblast aims at the pursuer during retreat, accounts for projectile arrival and regeneration in kill checks, applies the runtime near/far damage bonus, and secures ranged creeps.
- Shredder activates for an actual attack target in the increased attack range, including hit-count wards and structures, and respects disarm, attack immunity and Glyph.
- Kisses can follow long-range disables or grouped enemies, or finish a target with one impact. Nearby active enemies prevent an unsafe stationary start. Ordinary native and copied spells preserve an active barrage.
- Copied spells return nil for unknown names before gates and linked lookups; missing, null, hidden, deactivated and untrained active handles retain their real readiness checks.
- Displacement rejects the actual Dream Coil modifier and Rupture on the unit that would move, including human ally Cookie and Toss recipients.

Rejected or stale source claims
- The Dotacoach Counter Strategy card still claims a 30% close-range Scatterblast bonus; pinned Valve and the current ability card agree on 25%.
- Torte commentary about Shredder suppressing attack speed is not implemented: the verified current definition applies armor reduction.
- Old native Spit used Kisses range and could never match its creep marker, while an ally save corrupted GobbleUp. Those references are removed.

Item follow-up observations for TASK-21
- TASK-21 follow-up: Force Staff and Blink provide positioning and rescue access; Shard adds Cookie healing and landing damage, Scepter adds swallow and release, and Refresher can provide another Kisses barrage. Greaves, Pipe, Locket, Glimmer and Lotus depend on team needs; this pass preserves builds and shared item policy.

Enemy counterplay observations for TASK-24
- TASK-24 follow-up: Sharp movement can evade Cookie landings and the first Kiss. Respect magic immunity, reflection, Carapace, magic resistance and physical attack immunity. Enemy gap closers threaten a stationary barrage; allied Ravage, Chronosphere, Arena, roots and other observed disables improve first-impact reliability. No enemy cooldown API is used.

Lobby validation checklist
- No game was launched. Verify Cookie facing at projectile arrival for moving human allies, safe cliff and treeline jumps, charged Cookie behavior, Shard heal and impact, ally Gobble consent behavior, three-second belly timeout, and queued Gobble-to-Spit transitions.
- Verify Scatterblast physical travel with Lens and the cast range talent. The code deliberately does not infer a longer cone from item range; runtime facet values are supported.
- Verify Kisses first-glob prediction and safe positioning. Follow-up glob steering is not automated because attack orders could interrupt the barrage; preserving the actual modifier remains explicit. Check actual Spit activation after Gobble and whether linked Kisses absence changes engine-side damage.

Focused verification
- node .test-tools/node_modules/fengari-node-cli/src/lua-cli.js tests/snapfire_ability_spec.lua: passed.
- node tests/valve_ability_check.cjs: passed (128 native heroes, 84 copies, zero findings).
- Focused positive and negative scenarios cover point-blank and reversed damage, regeneration, retreat aiming, projectile length, ranged creep secure, Cookie self/ally geometry and exact range, terrain danger, root and channel rejection, Shard healing, attack range and ward opportunities, disarm and immunity, long-range Kisses, danger and reflection, Scepter Gobble ranges, nil/null Spit, hidden/deactivated releases, separate state and no-Kisses Spit, queues, occupied state and active barrage.
- Full build suite and shared integration remain root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Snapfire standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
