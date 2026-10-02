---
id: TASK-13.95
title: 'Venomancer: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:44'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_venomancer.lua
  - tests/venomancer_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_venomancer.lua
  - bots/FunLib/rubick_hero/venomancer.lua
  - tests/venomancer_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 135000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Venomancer is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use travel-predicted Gale lines and conservative immediate damage.
- Use current point-only Plague Ward positions and real owned ward attacks.
- Value Snakebite retaliation and Noxious host/debuff spreads while preserving existing infections.
- Mirror four independent actives without missing passives or retired upgrades.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs venomancer; https://dotacoach.gg/en/heroes/venomancer and https://dotacoach.gg/en/heroes/counters/venomancer (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native controller, every consideration, TDL guide 129096483 and complete Dotacoach Strategy, Counter Strategy and Matchup synergy, gameplay and advanced item cards.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Gale has range 800, width 125, speed 1200, initial magical damage 25/50/75/100 and ticks every three seconds over 15 seconds. Current Shard adds 200 range, 300 speed and two wards per hero hit.
- Snakebite range 600, cast point 0.2, initial damage 40/70/100/130 plus current talent, and six-second damage over time. Attacks while infected repeat the initial damage. Future attacks and full duration are not promised in kill estimates.
- Plague Ward is point-only with can_target zero, range 850, five-second cooldown and 40-second duration. Ward HP is 150/250/350/450 and attack damage 16/24/32/40; Poison Sting inherits at half damage. No old attached ward stacks or legacy facets are used.
- Noxious range 900, cast point 0.15, speed 1200, host duration four seconds, impact 150/200/250, maximum-health DPS 2/3/4%, spread radius 700 plus talent and spread count two. Current Scepter lowers cooldown by 35, reduces infected magic resistance by 20 and allows later hero spreads full impact. Current localization carries caster debuffs and says spread durations are fixed.
- Dotacoach current patch card reports nonlethal initial Noxious damage; raw KV/localization do not expose that damage flag. The controller does not use Noxious initial or full duration as a guaranteed kill.

Implemented behavior
- Gale now chooses actual predicted line coverage, uses initial arrival damage with regeneration for certain kills, preserves existing infections and supports real local farming lines and attacking objectives.
- Snakebite reacts to immediate kills and actual nearby physical attackers, peels for human or bot allies and avoids unproductive duplicate debuffs.
- Noxious selects meaningful hosts by nearby spread opportunities, existing Gale/Snakebite and vulnerable recently damaged victims. It respects block, reflection, immunity and existing infection rather than obsolete latent poison or old area assumptions.
- All ward casts now use location actions. Useful forward, retreat, farming, building and boss positions stay inside real cast range, avoid hazardous terrain and inspect actual nearby owned wards to avoid crowding.
- Owned named Plague Wards use their actual attack range, visibility and queue state, prioritize useful Poison Sting distribution and preserve an existing attack target. Unknown units pass to the generic minion controller.
- Four copied spells preserve unrelated dispatch and actual optional handle states. Infection decisions use documented modifier source ability observation instead of invented modifier names.
- Protective ally peel now uses actual recent damage and observed pursuit without requiring a bot-only retreat mode; native and copied idle-mode human ally positives and no-threat negatives pass.

Rejected or stale source claims
- Rejected Poison Nova/Latent Toxicity upgrade instructions, old attached ward facets, full-duration guaranteed poison kills, poison effects revealing invisible heroes, supposed physical armor bypass by magical resistance and Corrosive Skin lifesteal assumptions.

Item follow-up observations for TASK-21
- TASK-21: Review caster debuff transfer with Vessel and appropriate active items, current Noxious Scepter and Gale Shard, Lens range, mana sustain and useful Force/Glimmer peel. No generic item policy or builds changed.

Enemy counterplay observations for TASK-24
- TASK-24: Watch dispels and their current host-spread consequence, magic resistance and debuff immunity, ward vision and bounty, illusions splitting targeting and safe disengagement before follow-up poison attacks.

Lobby validation checklist
- Validate current nonlethal impact flag, actual modifier source attribution for each primary/secondary infection and carried item debuffs, ward ownership/range and Gale Shard-created ward lifecycle.
- No game or deep weak-hero lifecycle validation was performed.

Focused verification
- Fengari tests/venomancer_ability_spec.lua passed: exact cast and travel bounds, immediate versus delayed damage, regeneration, immunity/reflection/block, line pack coverage, actual attack retaliation, existing infections, host selection, point-only placement, actual ward crowding, objective use, Lens/Supremacy/Break and copied unknown/absent/hidden handles.
- Owned ward tests cover actual attack range, visibility, queue, foreign owner and null handle negatives. All three changed Lua files passed Lua 5.2 parsing.
- Focused specification rerun after human ally parity follow-up passed.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.

Framework integration
- Native X.ConsiderPlagueWardMinion and copied X.ConsiderStolenPlagueWardMinion. Return false for unrelated/invalid/foreign units; return true for an owned actual named Plague Ward, including blocked/idle states, to suppress generic range-incorrect fallback. Only issue attack on eligible visible targets inside its actual attack range and with no active action or queued action.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Venomancer standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
