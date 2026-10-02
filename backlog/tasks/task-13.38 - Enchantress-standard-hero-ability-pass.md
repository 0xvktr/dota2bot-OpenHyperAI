---
id: TASK-13.38
title: 'Enchantress: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 08:59'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_enchantress.lua
  - tests/enchantress_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_enchantress.lua
  - bots/FunLib/rubick_hero/enchantress.lua
  - tests/enchantress_ability_spec.lua
  - bots/FunLib/enchantress_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 78000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Enchantress is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair Little Friends current base root and undefined target logic; timely nearby combat healing, genuine Impetus attack/mana decisions and safe Shard Sproink; retain useful Enchant neutral control and defensive dispels.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs enchantress; https://dotacoach.gg/en/heroes/enchantress and https://dotacoach.gg/en/heroes/counters/enchantress (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Impetus is a pure attack orb that excludes debuff immunity. It uses the actor’s attack reach and 5/10/15/20% of distance, capped at 1750, rather than spell range.
- Enchant targets an enemy unit at 500/600/700/800 range and applies a basic dispel. The neutral level cap is 4/5/6/6; the owned creep cap is one, or two with Scepter.
- Nature’s Attendants has a 275 aura, nine wisps and a 7/9/11/13 second healing duration. Full-health targets do not justify a cast.
- Shard Sproink is a no-target backward 500-unit hop costing 60 mana. It attacks the two furthest targets within attack reach plus 100; copied Sproink does not assume Impetus is present.
- Scepter Little Friends targets an enemy at 750 range with a 1200 creep radius. Its nondispellable root lasts at least two seconds, plus 0.5 seconds per creep, capped at five seconds, and excludes debuff immunity.
- Untouchable is a breakable passive attack slow; Rabble-Rouser’s damage aura remains engine controlled.
- Read the full Torte guide, Strategy, Counter Strategy, gameplay synergies and Matchup item cards, then checked pinned Valve KV and localization.

Implemented behavior
- Shared hero-specific decisions in enchantress_abilities.lua serve native and copied spells.
- Fix Little Friends undefined variables; base root interrupts and controls even with no creeps; actual cast reach, immunity/block/reflection and existing-disable gates.
- Heal threatened allies or self during combat, before offensive toggles; avoid live-wisp refresh and Ice Blast.
- Impetus toggles based on actual attack target, actor reach, immunity/ethereal/disarm and current mana, including turning off when not fully castable; heal mana retained when trading hurt.
- Sproink uses actual backward facing/500 distance and passable safe destination; offense requires known Impetus and separation; dodge remains useful without linked spells.
- Enchant basic dispels relevant buffs and peels retreating allies; keeps healthy owned creeps at current cap, replaces expiring ones and rejects overlevel/ancient neutrals.

Rejected or stale source claims
- Torte Scepter item card still attributes Sproink to Scepter; pinned data grants it by Shard.
- Dotacoach matchup calls Impetus magic; pinned damage is pure.
- Claims Chen Penitence removes Untouchable/Ursa damage bypasses attack-speed reduction are not mechanics flags; excluded.
- Obsolete facets and Overprotective values zero; not implemented.

Item follow-up observations for TASK-21
- TASK-21: Pike separation plus temporary unrestricted attacks makes Impetus useful; Drums/Bearing benefits controlled army; current Solar Crest is ally support, not guide enemy punishment.

Enemy counterplay observations for TASK-24
- TASK-24: block camps/steal summon opportunities; dispellable buffs vulnerable to Enchant; move toward Enchantress after Impetus launches; spells and Break against Untouchable; Ice Blast blocks healing.

Lobby validation checklist
- Check actual Little Friends root scaling/creep orders and immunity/block interactions.
- Check Enchant player ownership and modifier timers when replacing expiring creep; neutral abilities remain generic minion controller.
- Check Sproink furthest-target selection, facing and terrain; no guarantee specific hero receives either shot amongst many creeps.
- Check mana reserve and Pike attack modifier interaction.

Focused verification
- The native and copied Enchantress Fengari scenarios passed, and all four files parsed as Lua 5.2. Scenarios cover range, immunity, channels, missing linked spells, terrain, creep caps and healing priority.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Enchantress standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
