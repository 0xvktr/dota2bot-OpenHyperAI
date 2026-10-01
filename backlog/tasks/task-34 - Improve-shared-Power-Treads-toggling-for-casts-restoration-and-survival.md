---
id: TASK-34
title: 'Improve shared Power Treads toggling for casts, restoration and survival'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-09-30 20:57'
updated_date: '2026-10-01 08:33'
labels:
  - items
dependencies: []
references:
  - 'https://liquipedia.net/dota2/Power_Treads'
  - 'https://dotacoach.gg/en/items/power-treads'
  - 'https://zquixotix.wordpress.com/2017/07/11/tread-swapping/'
documentation:
  - docs/POWER_TREADS.md
priority: medium
ordinal: 38000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Power Treads switching preserves health and mana percentages. INT before fixed mana expenditure reduces effective spell/item costs; AGI during safe fixed restoration improves the restored percentage; STR before incoming damage improves survival. Primary attribute suits ordinary attacks; universal heroes can prefer AGI for attack speed. INT is not always best for passive percentage regeneration and STR is not always best for attacking.

Research recovered from the Codex chat Research Power Treads toggling (2026-09-30): +10 selected attribute; approximately +220 maximum HP on STR, +120 maximum mana on INT, +10 attack speed and 1.67 armor on AGI. Example: 300/600 mana -> INT 360/720 -> spend 100 -> return 216.7/600, versus 200/600 without switching. Fixed restoration benefits in reverse. Confirm runtime behavior in a lobby: existing scripts compensate for GetPowerTreadsStat using a different order from hero attribute enums.

Prioritize existing shared cast helpers and item execution, safe self restoration (Wand/Stick, Bottle, Mango, Lotus, Salve, Clarity, Tango), survival and defaults. Protect channels and cast phases, retain the cast setting until queued actions complete and mana is spent, bypass optimization for urgent escapes/saves, and preserve offensive stats for illusion creation. Exclude attack-by-attack micro and speculative passive regen optimization from this first pass.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Existing shared hero cast helpers prepare INT before queued casts and recover an appropriate default after the cast completes.
- [x] #2 Supported self restoration items and ongoing restoration use AGI when safe; ordinary mana-costing items and TP can prepare INT before use.
- [x] #3 Danger takes precedence over restoration and defaults, and urgent actions proceed without extra switching.
- [x] #4 Tread switching does not clear active channels or cast phases, overwrite queued casts, or oscillate between item and ability logic.
- [x] #5 Illusion creation uses an offensive attribute rather than automatic INT preparation; universal heroes have a valid default.
- [x] #6 Offline regressions cover toggle order, casting and restoration execution, threats, action locks and exceptional heroes; lobby checks are documented.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Centralize the existing Treads stat mapping and queued switching in a shared module, keeping compatibility with existing hero cast helpers. 2. Add safe item preparation and prioritize threats over ongoing restoration and offensive defaults, with action and timing locks. 3. Prepare offensive stats for explicit illusion casts and keep urgent defensive casts immediate. 4. Add offline behavioral tests using the real shared helpers and item executor; run the existing regression suite and document lobby verification.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented shared raw-stat conversion, queued INT preparation, safe AGI self restoration, threat-first survival and offensive defaults, including universal AGI and Medusa INT. Existing two-argument hero helper calls remain supported; explicit illusion and emergency-save calls pass their ability. Emergency saves skip both Treads and Soul Ring preparation. Idle Treads decisions now run after other items, so inventory slot order cannot delay a Wand or defensive item.

Verification: node tests/power_treads_spec.cjs passed using real shared helper, item executor and item decision-loop code with simulated percentage-preserving resource accounting; covers all nine transitions, actual queue execution, mana savings, restoration targets, pending actions/channels, TP gating, urgency, Soul Ring, illusions and exceptional heroes. node tests/run-builds.cjs and node tests/run-objectives.cjs passed, as did git diff --check. Acceptance criteria checked against offline evidence. Engine API values, cast scheduling and live illusion snapshots still require lobby verification; see docs/POWER_TREADS.md. Direct hero casts outside the existing shared helper are not automatically intercepted.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Recovered the prior research into TASK-34 and implemented shared Power Treads preparation, restoration, survival and illusion policies. Offline behavioral and project regressions pass. Ready for the documented lobby checks; live engine scheduling and stat mapping remain unverified.
<!-- SECTION:FINAL_SUMMARY:END -->
