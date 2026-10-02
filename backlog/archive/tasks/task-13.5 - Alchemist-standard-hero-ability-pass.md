---
id: TASK-13.5
title: 'Alchemist: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 13:29'
updated_date: '2026-10-01 14:53'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_alchemist.lua
  - bots/FunLib/rubick_hero/alchemist.lua
  - 'https://dotacoach.gg/en/heroes/alchemist'
  - 'https://dotacoach.gg/en/heroes/counters/alchemist'
  - tests/alchemist_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 44000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Alchemist is part of the next standard hero batch after Dazzle. Review current spell decisions and combos against guide strategy and current Valve mechanics, including the dedicated Rubick copy, to address weak or incorrect ability use.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against Valve definitions and localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and Matchup advice; findings and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the hero and applicable Rubick copy, with meaningful offline behavior scenarios
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and task is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Cross-check every spell and cast order against pinned Valve/localization, both Torte role guides and dotacoach Strategy/Counter Strategy/all Matchup gameplay sections.
2. Repair Acid aggression branch, Concoction charging/throw timing and safe-target filtering, prioritize urgent throws, and improve basic-dispel Potion/Rage use and farming Rage. Mirror applicable changes in Rubick without modifying gifts/builds.
3. Add native/stolen behavior specs, run dedicated spec and Valve check, record sources/stale advice and lobby cases; await shared integration validation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Sources reviewed: pinned Valve alchemist hero KV at cf0d37a plus matching abilities_english localization; Torte guides 129111538 (offlane) and 356791078 (carry), both 7.41f, abilities and item tips; https://dotacoach.gg/en/heroes/alchemist Strategy/Counter Strategy and https://dotacoach.gg/en/heroes/counters/alchemist all gameplay synergy, good/bad opponents, core/counter item sections. Verified physical Acid/Concoction, 5s maximum brew and base spell 5.5s self-explosion, basic dispels on Rage/Potion, Potion cast on immune allies and self. Valve Throw KV contains a different 7s explosion value; use the base spell timer for self-explosion and reserve 0.3s beyond cast point.
Implemented: fixed dead Acid aggression branch (undefined enemy count), offensive placement and cast-range bonuses; Concoction startup avoids duplicate brewing and blocked/reflecting targets; Throw uses scaled damage and actual brew elapsed time, interrupts promptly, releases earlier for retreat/leaving range and at a safe full-charge deadline, checks every target instead of blindly throwing at the first enemy after 2s. A deadline throw may consume Linkens to avoid self-stunning, but avoids Lotus/Counterspell reflection. Throw precedes Rage transformation. Stolen Throw can recover elapsed brew from the engine modifier when the module did not see the start.
Potion recognizes basic-dispellable roots/DoTs/silences rather than claiming it removes stuns/hexes, includes self and immune allies, avoids redundant active buffs and blocked heal-only casts, prioritizes urgent dispels before ordinary Acid/brew. Rage cleanses damaging debuffs/known roots, protects a wounded bot, farms worthwhile multi-creep camps and no longer stops using its attack steroid at late Roshan/Tormentor times. Native and Rubick logic mirrored; Rubick desire variables localized. Builds and Scepter gifting unchanged.
Stale claims: Torte carry still describes leveling Greed and obsolete HP talent; old gift spell-amplification and Octarine spell-lifesteal/item descriptions are not used as mechanics. Dotacoach matchup discusses removed DK/AA facets and calls Alchemist exclusively physical despite Radiance being a common magic-damage source. Chemical Rage is a basic dispel, not a cure for strong-dispel-only disables or Ice Blast. Synergy/item/counterplay findings supplied to parent for TASK-21/TASK-24 routing.
Validation: native and stolen Alchemist ability scenarios passed: Acid aggression/range bonus, duplicate brew prevention, retaining charge past 2s, scaled kill damage, channel interrupt, escape/retreat release, full-charge deadline, invalid first enemy filtering, Linkens emergency vs reflection, Throw before Rage, Potion before Acid for ally dispels, immune/self Potion and no false stun save, meaningful farming Rage, blocked healing and inherited stolen Throw clock. Valve check passes (128 heroes, 21 copies, 0 allowlisted findings). Shared suite pending parent integration.
Lobby cases: observe maximum charge and self-explosion safety with cast-point latency, Concoction->Blink->Throw and retreat release, channel interrupt before max brew, spell-block vs reflected targeted throw, inherited Rubick linked spell, Acid pursuit placement/farming resource use, Vessel/Poison/root basic dispels with Rage and Potion, BKB-ally/self Potion, Rage sustain against AA/Doom and late Roshan. Engine brew modifier timing and safety margin require lobby confirmation.

Final review adds native +400 Concoction damage talent to brew-scaled estimates, retaining base damage for Rubick; shield/Refraction absorption blocks false early kill throws. Dedicated native/stolen specs and specialized Rubick dispatch spec (84 casts) pass. Shared Rubick harness was narrowly extended for GetModifierTime, legitimate Coil self-cost field reads and realistic enemy-vs-ally/unit-list stubs; production APIs remain mandatory. Owned Lua syntax and Valve check pass; parent integration is pending.

Cast-range review: GetProperCastRange adds an unconditional 200 movement allowance, so these handlers now use actual ability cast range plus the known active Aether Lens bonus instead. Stolen copies also include trained, unbroken Arcane Supremacy cast_range, verified against pinned Rubick KV (60/120/180/240). Dedicated tests now assert no out-of-range walking cast, Aether reach, passive range and loss under break. Native/stolen specs, specialized Rubick handler spec and Valve check pass after this correction.

Reviewed Matchup synergy setups: Oracle/Abaddon sustain and cleanses protect brewing; Ogre attack speed complements Rage's low base attack time; Keeper mana support and Vacuum/RP-style grouping help sustained fighting and AoE Throw. Draft tables and generic item behavior remain outside this pass.

Final integration review: added explicit current modifier_antimage_counterspell rejection to offensive Coil/Flux/Concoction target selection where applicable, because the older shared advanced-target helper only checks the legacy spell_shield name. Alchemist rejects the current shell even during the deadline Linkens-consumption exception. Native and stolen behavior scenarios cover these guards; the shared helper was not changed.

Final batch verification passed on the integrated state: node tests/run-builds.cjs (exit0 and all success markers), including all five new specs, Dazzle regression, Lua syntax for327 files,127 heroes/253 migrated roles,84 specialized Rubick dispatches,58 Rubick hero cases,272 purchase lists and all remaining shared scenarios. The suite includes node tests/valve_ability_check.cjs:128 hero files,21 Rubick copies,0 allowlisted findings at cf0d37a. git diff --check passed. Build/talent/skill-order data and Alchemist gifting were preserved. Offline acceptance is complete; lobby checklist remains outstanding and no live game was run.

Second batch API review replaced unsupported server-only PassivesDisabled in Rubick cast-range calculation with shared bot-compatible J.HasBreakModifier. Existing passive-range regression now uses verified Silver Edge victim modifier; no Concoction behavior/build change.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed Acid aggression and brew-scaled Concoction timing/targeting; prioritized urgent Throw/Potion and improved basic dispels/Rage. Mirrored applicable stolen spells, including inherited Throw and current Counterspell rejection. Native/Rubick specs and full build/Valve suite pass. Gifting/builds unchanged; timer/upgrade lobby checks remain.
<!-- SECTION:FINAL_SUMMARY:END -->
