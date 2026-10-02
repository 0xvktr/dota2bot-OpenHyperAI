---
id: TASK-13.115
title: 'Silencer: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:30'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_silencer.lua
  - tests/silencer_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_silencer.lua
  - bots/FunLib/rubick_hero/silencer.lua
  - tests/silencer_ability_spec.lua
  - bots/FunLib/silencer_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 155000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Silencer is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Correct real global opportunities, current attack and delayed spell damage, range and runtime cast shape; preserve native economy behavior and add copied decisions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs silencer; https://dotacoach.gg/en/heroes/silencer and https://dotacoach.gg/en/heroes/counters/silencer (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the complete native decisions, Torte guide 129072324, canonical Silencer Dotacoach Strategy, Counter Strategy and all Matchup synergy, gameplay and advanced item cards. Ran fetch CLI and verified hero page identity.
- Pinned KV/localization: Curse 850 range,350 radius,0.3 cast point,80 initial impact and 40 DPS over 6 seconds; duration pauses during silence. Last Word 900 range,0.3 cast point,240 base plus 2.5 times positive intellect difference,4 second trigger delay and live 250 AoE talent; channeling spells trigger after the channel finishes.
- Glaives bonus is magical 80 percent of intellect, alongside a physical attack, with no current fourth-hit silence. Shard gives one 450-range bounce; random secondary targeting is not guaranteed damage. Global is a 0.3 second no-target global silence that pierces debuff immunity and remains dispellable; Scepter applies Curse through its own engine effect. Current innate Suffer In Silence and deprecated facets are not presumed for copied spells.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Global examines visible known enemies across the actual map, interrupts real non-teleport channels even under debuff immunity, avoids already silenced enemies and protects observed Black Hole, Death Ward and Freezing Field channels. Remote human allies receive the same rescue consideration with actual enemy ability activity; physical attacks alone cannot justify silence.
- Curse uses actual cast bonuses, bounded area placement and only the initial application damage for immediate lethal decisions. It avoids an existing Curse and preserves native creep clearing and ranged last hits.
- Last Word uses positive intellect difference with the actual multiplier and the full delayed trigger for regeneration. Unit targeting remains unless the live ability behavior actually includes point casting; live radius bounds predicted point placement. It does not treat Last Word as an immediate channel interrupt.
- Glaives uses actual attack range without Lens or Supremacy extension and a mixed physical/magical attack estimate with real attack delay. Disarm, physical protection, magic immunity and resistance constrain use; native last hits and objectives remain.
- Normal native item preparation and generic actor/spell gates remain. Copied dispatch rejects unknown names before actor lookup and returns true only for a single issued action.

Rejected or stale source claims
- Excluded old pure Glaives damage, fourth-hit silence, absolute intellect difference, instant full Curse/Word damage, obsolete 1.25 Curse multiplier, assumed point shape based on caster talents, deprecated silence immunity facets and claims silence prevents attacks or Supernova egg attacks.

Item follow-up observations for TASK-21
- TASK-21: actual Lens and unbroken Supremacy affect Curse/Word casting, never physical attack reach. Existing Refresher/Scepter and mana items remain unchanged; engine Scepter Curse is not manually duplicated, and copied missing Curse is not fabricated.

Enemy counterplay observations for TASK-24
- TASK-24: Global pierces debuff immunity but dispels and already-silenced state change its value. Physical attacks continue during silence. Glaives bonus remains magical and Last Word can trigger only after an enemy channel ends. Enemy cooldowns are not queried.

Lobby validation checklist
- Verify actual global channel interruptions, remote human ally observations, point-shape AoE talent behavior, delayed Word trigger, Curse silence-paused duration and Glaives attack projectile timing. Copied innate, Shard bounce and Scepter application are engine effects, not fabricated sibling assumptions.

Focused verification
65 meaningful native/copied scenarios passed under Fengari. Four files parsed as Lua 5.2; owned diff whitespace checks passed. Scenarios include remote immune channels, TP exclusion, remote human rescue, physical-only rejection, cast bonuses and Break, bounded point casts, delayed regeneration, INT direction, disarm, mixed resistance, queues/channels, native farm and unknown dispatch.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Silencer standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
