---
id: TASK-13.93
title: 'Spirit Breaker: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:36'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_spirit_breaker.lua
  - tests/spirit_breaker_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_spirit_breaker.lua
  - bots/FunLib/rubick_hero/spirit_breaker.lua
  - tests/spirit_breaker_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 133000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Spirit Breaker is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair Charge routing and safe support, serialize Bulldoze preparation, verify current ally-targeted Planar Pocket, and share native/copied decisions with precise observed Charge callbacks.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte Spirit Breaker guide 128972272 fetched via direct public Steam Workshop API fallback because the CLI index omits it; https://dotacoach.gg/en/heroes/spirit-breaker and https://dotacoach.gg/en/heroes/counters/spirit-breaker (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native ability pass, the recovered full Torte guide 128972272, complete Dotacoach Strategy/Counter Strategy and all Matchup gameplay, synergy and advanced item cards. Verified mechanics against pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f and localization.
- Charge is global, roots disable it, targets cannot be debuff immune, windup is 1.5 seconds, movement bonus is 275/325/375/425 and bash radius is 300. Missing copied Greater Bash does not remove the actual target stun.
- Bulldoze is an immediate no-target spell with 60 mana, eight-second movement and status resistance. Nether Strike range is 700, cast point one second, bonus damage 350 and it supports debuff-immune targets. A trained linked Bash supplies 40% movement-speed magical damage and interrupt; localization explicitly preserves guaranteed Bash during Break.
- Current Planar Pocket targets a hero at range 700, breaks beyond 900, lasts six seconds and grants the caster 40% magic resistance while redirecting unit-targeted spells aimed at that selected hero. Lens and unbroken Supremacy add only their actual cast range values.

Implemented behavior
- Charge chooses safe global support from actual human or bot ally attacks, interrupt arrival windows and line opportunities. It rejects unsafe destinations and uses the actual farthest lane creep for multi-creep Bash instead of returning an unrelated neutral slot.
- Retreat Charge selects visible enemy or neutral creeps that improve escape distance. A narrow owned Charge callback can stop the charge after substantial verified progress into safety.
- Native Bulldoze preparation and Charge are separate ticks with enough combined mana. Observed own Charge permits a single direct Bulldoze action while retaining all other forbidden states; normal actions remain locked during actual Charge or its cast phase.
- Nether Strike uses exact range, magical damage and regeneration-aware arrival. It retains base damage with absent copied Bash and requires linked Bash before promising a channel interrupt.
- Planar Pocket now casts on a real threatened ally or self, including human allies, at exact range and within its break distance. It avoids illusions, invulnerability, repeated live modifiers and a fragile redirect caster.
- Unknown copied spells return nil before owner gates or linked lookups; recognized handlers return action booleans. Runtime nil, null, hidden, deactivated and passive handles retain the real generic gate.

Rejected or stale source claims
- The indexed Torte fetch omits Spirit Breaker; root recovered the current primary Workshop guide through its public API. No repository index or builds were changed.
- Old guide Empowering Haste, Vanguard Retaliate and Charge-speed Shard advice conflicts with current mechanics. Current Shard grants targeted Planar Pocket.
- A Matchup card describes Grimstroke as providing Ion Shell. That attribution is stale and was not implemented.

Item follow-up observations for TASK-21
- TASK-21: Shadow Blade/Silver Edge can conceal Charge, movement items improve actual Bash scaling, BKB protects commitment and Scepter improves Bash collisions. Current Shard supplies targeted spell redirection. Preserve purchase policy; do not assume old Scepter grants Charge immunity piercing.

Enemy counterplay observations for TASK-24
- TASK-24: roots, silences, spell block, reflected spells and poor arrival numbers restrict commitment. Use actual ally setup and line opportunities; avoid Carapace and Blade Mail. Planar Pocket can protect the selected ally from unit-targeted spells but does not provide a general team aura.

Lobby validation checklist
- No game was launched. Verify the actual Charge modifier source and Bulldoze use during movement, the bounded escape cancellation, and queue-to-charge behavior.
- Verify global arrival windup and target immunity, guaranteed Bash under Break, missing copied Bash, actual unit-target redirection and Planar Pocket break distance. Incoming projectile detection is an opportunity signal and does not promise interception of an already launched spell.

Focused verification
- Focused native/copied Spirit Breaker scenarios passed under Fengari.
- Valve ability check passed at 128 native heroes and 93 copied modules with zero findings; owned diff whitespace is clean.
- Scenarios cover global human ally support, safe line targets, lane farm target, escape target selection, serialized preparation, owned Charge source and every forbidden-state boundary, phase lock, actual teleport time, exact ranges/Lens, immune Nether Strike, regeneration, missing Bash, Pocket target/range/break/modifier/health guards, unavailable handles and nil-first unknown dispatch.
- Shared callback integration and full suite are root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Framework integration
- UseChargeSupport: before the shared Rubick occupied-state gate; action only during verified own Charge modifier.
- IsCharging: read-only lock in both shared Rubick occupied-state gates.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Spirit Breaker standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
