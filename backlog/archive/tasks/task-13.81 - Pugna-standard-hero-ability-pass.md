---
id: TASK-13.81
title: 'Pugna: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:10'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_pugna.lua
  - tests/pugna_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_pugna.lua
  - bots/FunLib/rubick_hero/pugna.lua
  - tests/pugna_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 121000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pugna is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use predicted Nether Blast geometry, meaningful lane and structure opportunities, and urgent Decrepify saves.
- Place and protect owned Nether Wards, then use current Shard refraction opportunities.
- Restore ally Life Drain healing with a caster health budget and cancellation when healing becomes unsafe or unnecessary.
- Support casting during an observed Life Drain channel only through an actual trained, unbroken Oblivion Savant innate; mirror stolen actives independently.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs pugna; https://dotacoach.gg/en/heroes/pugna and https://dotacoach.gg/en/heroes/counters/pugna (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Fetched and read TDL guide 128899869, full dotacoach Strategy and Counter Strategy, plus the complete Matchup synergy, matchup gameplay and advanced item sections: https://dotacoach.gg/en/heroes/pugna and https://dotacoach.gg/en/heroes/counters/pugna.
- Verified Valve Nether Blast: cast range 600, cast point 0.2, delay 0.8, radius 400, magical damage 95/170/245/320, nonpiercing, and 65% structure damage.
- Verified Decrepify: range 550/600/650/700, no allied movement slow, allied healing amplification 10/15/20/25%, enemy magic vulnerability 20/30/40/50%, physical attack prevention, and Nether Ward targeting.
- Verified Nether Ward: radius 1400, actual cast range 175 or 375 with Shard, four hero attacks to destroy, and base damage plus spent-mana scaling. Passive healing and spell damage reduction values are currently zero.
- Verified Life Drain: cast range 700, cast point 0.2, tick rate 0.25, magical nonpiercing drain 150/250/350 per second, allied health transfer at the same rate, channel limit 10 seconds and break buffer 200. Current health-to-mana conversion is zero.
- Verified Scepter halves Life Drain cooldown and drains spell amplification; Shard permits owned Nether Ward refraction at 75% normal damage. No old Scepter range or zero-cooldown assumptions are used.
- Verified Oblivion Savant grants casting and item use during channels, plus tower-based spell amplification. Copied spells do not assume this native innate.
- Read every native consideration and the full SkillsComplement. Instant casts use actual Lens and unbroken Arcane Supremacy range. Owned wards require minion attribution or the documented modifier source ability/caster.

Implemented behavior
- Reworked Blast prediction and clamped point casts, ranged creep last hits, local creep packs and legal structure pressure with glyph/backdoor checks.
- Added physical-threat Decrepify saves for self and allies, plus owned Ward protection; offensive amplification avoids blocking nearby allied attackers.
- Replaced fixed rearward Ward assumptions with actual cast range, local coverage, location safety and existing owned Ward checks.
- Added missing ally healing, with HP budget, Ice Blast and visibility checks. Tracked ally channels stop when caster HP is low, the ally is healed, or healing becomes invalid.
- Added conservative one-tick Drain kill estimates and actual owned-ward Shard opportunities, including foreign Ward rejection.
- Added ConsiderLifeDrainContinuation and ConsiderStolenLifeDrainContinuation. They require the actual Drain channel and active ability, preserve other action locks, and allow Q/W/E only when the caster truly has a trained unbroken Oblivion Savant.
- Added four independent copied ability handlers and fixed Ward minion state attribution on the native bot.

Rejected or stale source claims
- Rejected source claims that Life Drain deals percentage-health damage, transfers mana at full health, or gains old Scepter range and zero cooldown.
- Rejected stale Nyx Mana Burn, Decrepify blocking magical Tinker burst, reducing Ghost Shroud healing, or draining through active Ball Lightning invulnerability.
- Rejected outdated Arcane Boots disassembly and unverified item stat claims; item builds are unchanged.

Item follow-up observations for TASK-21
- TASK-21: Glimmer and BKB channel protection, Lens positioning, Blink and Force repositioning, Dagon after Decrepify, current Scepter spell amplification drain, Shard Ward refraction and cooldown items need a separate item pass. Native item policy remains shared and unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: Dodge delayed Blast, interrupt or leave Drain range, silence the caster, reflect or block unit-target spells, remove Decrepify with dispels, kill the Ward, and use magical resistance or debuff immunity. Track high-mobility physical initiators and healing reduction.

Lobby validation checklist
- Validate actual Q/W/E and item commands preserve Life Drain through Oblivion Savant, and whether Break disables that channel permission.
- Validate ward modifier source attribution, the current Shard Ward refraction radius under cast-range bonuses, and ward replacement behavior.
- Validate allied health transfer, Decrepify healing amplification, stop timing and emergency physical-save tradeoffs.
- No game or deep-dive validation was performed.

Focused verification
- Fengari tests/pugna_ability_spec.lua passed: delayed range/clamping, regen, immunity, last hits, protected structures, physical saves, allied attack preservation, Ward ownership, HP-budgeted healing, channel cancellation, innate-only casting, unknown dispatch and absent sibling spells.
- Native, copied module and focused spec passed Lua 5.2 parsing.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Pugna standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
