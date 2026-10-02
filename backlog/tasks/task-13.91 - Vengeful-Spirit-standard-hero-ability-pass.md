---
id: TASK-13.91
title: 'Vengeful Spirit: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:34'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_vengefulspirit.lua
  - tests/vengefulspirit_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_vengefulspirit.lua
  - bots/FunLib/rubick_hero/vengefulspirit.lua
  - tests/vengefulspirit_ability_spec.lua
  - bots/FunLib/minion_lib/vengeful_spirit.lua
parent_task_id: TASK-13
priority: medium
ordinal: 131000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vengeful Spirit is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use true spell ranges, projectile arrival damage and useful secondary threat selection.
- Aim Wave along actual travel paths and support physical attacks, local farming and objectives.
- Use piercing Swap for safe interruption, repositioning and human or bot rescue.
- Mirror copied actives and repair actual controlled Scepter illusion decisions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs vengefulspirit; https://dotacoach.gg/en/heroes/vengeful-spirit and https://dotacoach.gg/en/heroes/counters/vengeful-spirit (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read entire native controller and every consideration, TDL guide 129062086, complete Dotacoach Strategy, Counter Strategy and Matchup synergy, gameplay and advanced item cards.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Missile range 650 plus talent 100, cast point 0.3, speed 1350, magical nonpiercing damage 100/180/260/340. Shard bounces once within 75% of current range; secondary scoring values potential coverage without claiming a guaranteed bounce kill.
- Wave travels at 2000 with width 325, range 1400 and cast point 0.3. Its magical damage is 60/80/100/120, armor reduction 3/4/5/6 and attack reduction 10/15/20/25 for eight seconds.
- Swap pierces debuff immunity, uses range 850/975/1100 and cast point 0.4, interrupts both targets, deals 150/300/450 magical damage plus talent and grants a barrier equal to its damage to caster and allied target. Old percent damage reduction is zero.
- Current Scepter strong illusion can cast spells, has full outgoing/incoming damage, no item use and no cooldown reset on activation. Innate Retribution and Aura are not fabricated in copied decisions.

Implemented behavior
- Missile now uses actual Lens and unbroken Supremacy range, predicted arrival and regeneration, legal channel interrupts and retreating human or bot ally peel. Teamfight target scoring includes potential Shard secondary hero coverage.
- Wave uses predicted line segments instead of circular pack centers, rejects targets running beyond the actual path, and casts for lethal hits, meaningful debuffs, local creep lines and attacking objectives.
- Swap rescues trapped or endangered allies only from a safer origin and within true range; healthy allied channels are preserved. Enemy channel interruption works through debuff immunity and rejects unsafe landing, spell block, reflection and held victims. Existing damage taken no longer arbitrarily disqualifies a target.
- Three independent copied spells preserve unknown dispatch and absent, null, hidden or inactive siblings.
- Scepter illusion controller resolves real spell names instead of dereferencing absent slots, verifies actual owned named illusion and queue state, preserves its real cooldowns, mirrors useful spell decisions and keeps existing attack fallback.
- Protective ally peel now uses actual recent damage and observed pursuit without requiring a bot-only retreat mode; native and copied idle-mode human ally positives and no-threat negatives pass.
- API audit replaces undocumented HasShard calls with actual modifier_item_aghanims_shard state; current shard positive and negative fixtures pass.

Rejected or stale source claims
- Rejected Scepter cooldown reset advice, old Swap damage reduction, assumed invisible detection from Wave vision, claims that illusions or Beastmaster summons ignore armor, and passive damage attributed to copied spells.

Item follow-up observations for TASK-21
- TASK-21: Review Lens actual range, Shard secondary targeting, safe Blink/Swap origins, allied Force/Glimmer support and current Scepter illusion lifecycle. No item builds or generic policies changed.

Enemy counterplay observations for TASK-24
- TASK-24: Respect piercing Swap and barrier rescue, reveal and pressure the fragile caster, use applicable spell block/reflection and projectile disjoint against Missile, and account for the controlled Scepter illusion after killing Venge.

Lobby validation checklist
- Validate engine bounce priority and full current cast range, Wave endpoint width, Swap barrier metadata and interruptions, and Scepter owned illusion handle/control behavior with human allies.
- No game or deep weak-hero lifecycle validation was performed.

Focused verification
- Fengari tests/vengefulspirit_ability_spec.lua passed: exact ranges and Lens/Break/Supremacy, regeneration, missile immunity/reflect, line geometry and moving targets, local pack kills, human ally rescue, channel preservation, piercing interrupts, hazard rejection, copied unknown/absent handles and actual owned illusion cooldown/queue/range regressions.
- All four changed Lua files passed Lua 5.2 parsing.
- Focused specification rerun after human ally parity follow-up passed.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Vengeful Spirit standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
