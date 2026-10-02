---
id: TASK-13.59
title: 'Luna: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_luna.lua
  - tests/luna_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_luna.lua
  - bots/FunLib/rubick_hero/luna.lua
  - tests/luna_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 99000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Luna is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Prioritize actual-range Beam interrupts.
- Proactively cast physical Orbit within actual hit reach and for farming.
- Evaluate Eclipse hero opportunities versus creep soak; Scepter remote centers.
- No copied passive assumptions and offline regression.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs luna; https://dotacoach.gg/en/heroes/luna and https://dotacoach.gg/en/heroes/counters/luna (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native consideration functions and SkillsComplement, Torte guide 129063701, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Lucent Beam range 800, damage 75/150/225/300 and 0.6-second stun; Lunar Orbit deals physical, immunity-piercing damage with movement radius 225 plus collision radius 200, reduction 8–20%, and current Shard movement bonuses of 10/20%; Eclipse radius 675, beams 6/9/12 and ordinary hit cap five. Scepter adds range 2500, 0/3/6 beams and 1/7/13 to the hit cap.
- Reviewed Grimstroke double Beam, allied lockdown and illusion synergy.

Implemented behavior
- Prioritize Lucent Beam channel interrupts before Orbit or Eclipse, use actual Lens and cast ranges, and correct queries that confused allied and enemy heroes.
- Use Orbit proactively against nearby disabled or immune enemies and farming clusters without requiring recent incoming damage.
- Use Eclipse when enough beams can affect real heroes, discounting creeps, illusions and invisible recipients. Treat allocation as an opportunity estimate.
- Support the current Scepter ground cast at a remote center.
- Require a real trained linked Lucent Beam for copied Eclipse damage and avoid assuming an absent passive.
- Remove the unreachable Moon Glaives consideration that referenced an undeclared ability.

Rejected or stale source claims
- Reject Nullifier passive-Break claims in the guides and Matchup page.
- Reject the suggestion that BKB prevents Beastmaster’s Roar; Roar pierces immunity.
- Treat ranged Empower cleave and claims of universal daytime dominance cautiously. Drafts were not changed.

Item follow-up observations for TASK-21
- TASK21: Cast spells before Mask of Madness silence, use BKB for sustained attacks and Eclipse, use Manta for lane pressure, project Scepter Eclipse from a safe position, and use Pike for range or escape.

Enemy counterplay observations for TASK-24
- TASK24: Stay outside the 675 Eclipse radius or dilute beams with creeps and illusions. Invisible targets are excluded. Pressure Luna’s farming and avoid clustered glaive bounces.

Lobby validation checklist
- Verify Orbit collision edges and damage reduction, current Scepter point targeting and remote placement, and Eclipse allocation. Random beams do not guarantee a kill.
- Copied Eclipse without an actual linked Beam is conservatively declined pending live confirmation.

Focused verification
- Fengari tests/luna_ability_spec.lua: Luna ability scenarios passed,5 scenario groups.
- No game launched; root integration checks pending.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Luna standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
