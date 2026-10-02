---
id: TASK-13.104
title: 'Shadow Demon: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:04'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_shadow_demon.lua
  - tests/shadow_demon_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_shadow_demon.lua
  - bots/FunLib/rubick_hero/shadow_demon.lua
  - tests/shadow_demon_ability_spec.lua
  - bots/FunLib/shadow_demon_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 144000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Shadow Demon is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Prioritize ally saves, verify live upgrade handles, correct current Poison damage and source ownership, and share safe native/copied decisions with observed pending impact checks.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs shadow_demon; https://dotacoach.gg/en/heroes/shadow-demon and https://dotacoach.gg/en/heroes/counters/shadow-demon (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the complete Torte guide 128937771, Dotacoach Strategy and Counter Strategy, and all Matchup synergy, gameplay and advanced item cards; checked the intended Shadow Demon page and ran the guide fetch CLI.
- Pinned Valve KV and English localization checked: Disruption 675 range and 2.75 second duration, excludes magic-immune allies; Disseminate 925 range, 675 radius, six seconds and 40 percent shared damage. No old health removal or reflected lifesteal credited.
- Shadow Poison 1500 point range, 0.25 cast point, 1200 projectile speed, 200 width and ten-second stack duration. Base stack and impact damage reach 60, exponential multiplication stops after five stacks and subsequent stacks add 60.
- Demonic Purge is 800 range, 0.3 cast point and five seconds before up to 600 damage; continuous dispel and slow pierce debuff immunity. Scepter supplies break and two charges. Cleanse is the actual Shard sibling, with five seconds of basic dispel and 450 delayed healing; it is not stun immunity.
- Poison, Purge and Cleanse have documented Disruption targeting allowances. Code requires the actual Disruption modifier and an actual ability source named Disruption before accepting a banished unit, preserving normal gates for unrelated invulnerability.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Disruption saves endangered allies before offensive interruption, uses real instant range including actual Lens and unbroken Supremacy, rejects immune allies and duplicate banishes, and preserves ordinary healthy channels or teleports. Human allies and actual Spirit Bear units participate. Existing Tormentor low-health protection is retained.
- Cleanse reacts to useful silence or root and endangered healing opportunities rather than treating stuns or hex as basic dispellable. It checks the actual current live upgrade handle and any still-active modifier applied by that exact Cleanse source, avoiding invented modifier names.
- Disseminate considers actually attacked friendly frontline carriers with nearby enemies, with human parity, and current enemy clusters; existing effects avoid waste.
- Poison always predicts actual cast plus flight time and bounds the point cast. Release now computes correct exponential stack damage and subsequent linear extra stacks, verifies modifier ownership against the real Poison sibling, handles missing/hidden siblings, and removes the artificial 3000 range limit.
- A Poison command records intent only. A pending impact suppresses nonlethal five-stack releases only after an actual source cooldown confirms the cast, while the target still intersects the recorded flight line and its impact time has not passed. Lethal or imminent-expiry releases take priority. Native Release runs before another Poison.
- Purge uses real delayed damage and regeneration, casts through enemy debuff immunity, avoids wasting a charge on its own current effect and honors unit-spell protection. Native lane, wave and objective Poison policies remain.
- The copied handler recognizes six supported abilities before any bot/gate lookup and returns canonical nil/false/true results. No passives or upgrade siblings are fabricated.

Rejected or stale source claims
- Excluded old Soul Catcher behavior, the overcounted Poison base-times-stack-times-multiplier formula, assumed three Purge charges, generic Cleanse immunity to disables, and obsolete item disassembly recipes.

Item follow-up observations for TASK-21
- TASK-21 observations: actual Lens range improves save coverage and existing Shard activates the real Cleanse sibling; actual Scepter runtime provides two Purge charges and break. Existing purchases and generic item behavior are unchanged.

Enemy counterplay observations for TASK-24
- TASK-24 observations: reflect and spell block constrain enemy unit spells; Disruption does not accept immune allies, while Purge and Cleanse have different immunity rules. Poison damage belongs to the original caster and relies on accurate stack buildup. Enemy detection, positioning and dispels affect practical support play; no generic counter rules changed.

Lobby validation checklist
- Needs in-game tests of Disruption target visibility and GetModifierSourceAbility during banishment, friendly Spirit Bear eligibility, Cleanse current effect source, dispel interactions and its delayed healing.
- Verify real Poison flight timing, canceled casts, simultaneous caster stacks and pending source cooldown, Purge end damage, Scepter charge behavior and source identity after stolen-slot replacement. No queued cast is considered a successful effect.

Focused verification
36 meaningful native/copied scenarios passed under Fengari; all four files parsed as Lua 5.2 and owned-file diff whitespace checks passed. Coverage includes human saves, immunity and upgrade guards, own versus foreign effects, current stack damage, global release, canceled pending intent, exact prediction boundaries, regeneration and preserved native wave behavior.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Shadow Demon standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
