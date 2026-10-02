---
id: TASK-13.3
title: 'Abaddon: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 13:29'
updated_date: '2026-10-01 14:53'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_abaddon.lua
  - bots/FunLib/rubick_hero/abaddon.lua
  - 'https://dotacoach.gg/en/heroes/abaddon'
  - 'https://dotacoach.gg/en/heroes/counters/abaddon'
  - tests/abaddon_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 42000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Abaddon is part of the next standard hero batch after Dazzle. Review current spell decisions and combos against guide strategy and current Valve mechanics, including the dedicated Rubick copy, to address weak or incorrect ability use.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against Valve definitions and localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and Matchup advice; findings and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the hero and applicable Rubick copy, with meaningful offline behavior scenarios
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and task is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify Coil, Shield, Curse and Borrowed Time against pinned Valve KV/localization plus Torte and both dotacoach pages.
2. Add manual Borrowed Time before the disabled-caster gate, prioritize strong dispels and meaningful healing, and correct Coil self-cost, enemy immunity and stale Shard logic in hero/Rubick.
3. Add regression scenarios for saves, range, immunity, self preservation and manual ultimate; run dedicated spec and Valve check. Record source findings and lobby cases, then await shared integration validation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist: pinned Valve hero KV cf0d37a and matching abilities_english localization reviewed; Torte Steam guide 159698040 (7.41e), https://dotacoach.gg/en/heroes/abaddon Strategy/Counter Strategy and https://dotacoach.gg/en/heroes/counters/abaddon all gameplay, item and synergy sections reviewed. Current Coil is magical, costs 40% of damage/heal, heals immune allies; Shield excludes immune allies and Shard returns 75% absorbed damage. Borrowed Time is manually usable while disabled, not silenced; Scepter ally triggers use Coil range.
Implemented manual Borrowed Time for break/disabled saves and Scepter ally protection, safe meaningful ally-first Coil healing, corrected range/immunity/magical damage and removed stale Shard assumptions. Shield dispels precede ordinary barriers, may replace an existing Shield, respects range/immunity, and may coexist with Solar Crest. Mirrored basic-spell fixes in Rubick, localized leaked desire variables.
Stale claims: Torte still mentions Coil attack-proc Shard, Curse stack silence, old cooldown-reduction talent and Greed-era item details. Dotacoach Matchup still mentions deprecated Mephitic Shroud facet; current Shard reflects damage while ordinary Shield still bursts. Removed legacy Chronosphere/Black Hole/Duel branches as dispel saves: those effects are not strong-dispellable, though ordinary damage protection may still help a recently damaged ally.
Validation: dedicated Abaddon ability scenarios passed, covering native and stolen casts, ally healing before kills, magic immunity, cast-range bonus, self-cost reserve, existing Shield replacement, Solar Crest coexistence, no false Chronosphere dispel, manual ultimate break/stun/silence and Scepter range/heal prevention. Valve ability check passed (128 heroes, 21 copies, 0 allowlisted findings). Awaiting shared integration suite.
Lobby checklist: Coil while BKB ally is active; heal-vs-offense urgency and cost safety; Shield removal of stun/root/silence plus existing Shield replacement; manual Borrowed Time under break/stun/hex and blocked by silence; healthy Scepter Abaddon supporting burst damage at the Coil range edge; Shield/Coil behavior in Borrowed Time and vs Ice Blast.

Additional review: Shield removes verified Poison Touch, Track, Corrosive Haze and Vessel debuffs even when the ally is not currently disabled; persistent Doom/Smoke Screen/Static Storm silences are excluded as dispel-only reasons. Coil self-cost protection assumes only Borrowed Time, since an existing Shield may be nearly depleted. Both dedicated specs and Valve check pass after these follow-ups.

Final review adds native +35 Coil talent damage/healing and corresponding percentage self-cost, with kill/safety regression; stolen Coil skips the foreign talent. Refraction absorption remains excluded from guaranteed kill estimates. Both dedicated specs, specialized Rubick dispatch spec (84 casts), owned Lua syntax and Valve check pass; parent integration is pending.

Cast-range review: GetProperCastRange adds an unconditional 200 movement allowance, so these handlers now use actual ability cast range plus the known active Aether Lens bonus instead. Stolen copies also include trained, unbroken Arcane Supremacy cast_range, verified against pinned Rubick KV (60/120/180/240). Dedicated tests now assert no out-of-range walking cast, Aether reach, passive range and loss under break. Native/stolen specs, specialized Rubick handler spec and Valve check pass after this correction.

Reviewed Matchup synergy setups: Shield strong dispels and Coil sustain help Axe/Centaur/Legion initiations; protection supports aggressive Alchemist/Ember/Storm play. These informed save targeting; draft matchup tables were not edited.

Final integration review: added explicit current modifier_antimage_counterspell rejection to offensive Coil/Flux/Concoction target selection where applicable, because the older shared advanced-target helper only checks the legacy spell_shield name. Alchemist rejects the current shell even during the deadline Linkens-consumption exception. Native and stolen behavior scenarios cover these guards; the shared helper was not changed.

Final batch verification passed on the integrated state: node tests/run-builds.cjs (exit0 and all success markers), including all five new specs, Dazzle regression, Lua syntax for327 files,127 heroes/253 migrated roles,84 specialized Rubick dispatches,58 Rubick hero cases,272 purchase lists and all remaining shared scenarios. The suite includes node tests/valve_ability_check.cjs:128 hero files,21 Rubick copies,0 allowlisted findings at cf0d37a. git diff --check passed. Build/talent/skill-order data and Alchemist gifting were preserved. Offline acceptance is complete; lobby checklist remains outstanding and no live game was run.

Second batch API review replaced unsupported server-only PassivesDisabled with shared bot-compatible J.HasBreakModifier for manual Borrowed Time and Rubick passive cast range. Existing tests now use verified Silver Edge victim modifier and retain break/disabled-caster coverage; known conditional Break upgrades remain an in-game follow-up.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated manual Borrowed Time, safe ally-first Coil healing/self-cost and Shield dispels in native Abaddon, with applicable stolen-spell fixes. Current Counterspell guards and meaningful native/Rubick scenarios pass the full shared build/Valve suite. Ready for the recorded lobby checklist.
<!-- SECTION:FINAL_SUMMARY:END -->
