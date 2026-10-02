---
id: TASK-13.29
title: 'Drow Ranger: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:34'
updated_date: '2026-10-01 18:02'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_drow_ranger.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 69000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Drow Ranger is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Audit pinned Valve/localization, Torte de Lini and full dotacoach Strategy/Counter/Matchup. Preserve build prefix. Use actual actor attack reach for Frost Arrows and Multishot, prioritize legal Gust peel/channel interruption, model physical cone coverage and safe channel commitment, and implement verified NO_TARGET Glacier with only observed Multishot channel exception. Add dedicated Rubick handling and faithful behavior scenarios, recording source exclusions, item/counter observations and lobby limitations.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source audit (2026-10-01): pinned Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero KV and English localization reviewed; Torte de Lini fetch drow_ranger, guide 128743885 (7.41f), all item tips; https://dotacoach.gg/en/heroes/drow-ranger Strategy/Counter Strategy and current abilities; https://dotacoach.gg/en/heroes/counters/drow-ranger entire synergy, good/bad matchup and core/counter-item sections reviewed. No third-party prose copied.
Checklist implemented: Gust immediate peel/ordinary-channel interruption precedes channel commitments, with legal live spell range and cast/travel prediction; TP is not scored as a Gust interrupt. Glacier is NO_TARGET with useful attack/vision/siege contexts instead of idle ally spam; an immediate defensive UseGlacierDuringMultishot helper is allowed only during an observed active Multishot channel, rejecting TP/unknown active ability, queued/casting/disabled/dead states and unavailable Glacier. Pinned localization explicitly permits this exception even without an IGNORE_CHANNEL KV flag. Ordinary channels are preserved.
Frost Arrows uses manual ATTACK-orb class, actor actual attack range and disarm/physical/debuff-immunity eligibility; preserves ready Gust mana and includes bonus physical damage for last hits. Healthy basic farm avoids orb spam unless current Scepter stacking offers value. No Lens/Supremacy or unit-spell reflect/block rules are applied to attack reach. Multishot uses actor attack range times live multiplier plus 475 base, physical immunity-aware eligibility and forward cone coverage; safe channel positioning, grouped camp/wave clearing and attack-range upgrades. No building damage or guaranteed all-arrows lethal claims. Native D2PT build/skill/talent/MinionThink prefix is byte-identical; dedicated Rubick handles supplied active casts.
Stale/unverified advice excluded: old global active attack-speed Trueshot/Precision descriptions and unrelated cooldown talents; Multishot damaging towers, Marksmanship armor-ignoring tower proc claims; Glacier immunity to Rolling Thunder, generic untargetability or invisibility; Glacier preventing nearby enemies disabling Marksmanship (current 7.41b explicitly permits suppression), bonus Multishot arrows and hill True Strike. Hypothermia is current Scepter despite old shard-prefixed value names. Close-range all-arrows advice is balanced against channel exposure. Terrain vision may hinder targeted initiation but does not grant universal targeting protection.
Offline verification: exact marker Drow Ranger ability scenarios passed; six owned DK/Drow files/specs Lua 5.2 parse; Valve check 128 heroes / 32 copies / zero findings at checkpoint; git diff --check clean; build prefix comparison passed. Parent owns shared wiring/full-suite/finalization.
Lobby checklist: native/Rubick manual orb legal actor range, creep aggro and last-hit travel; actual Frost immunity and Scepter stacks; attack-range-to-Multishot cone/range including Glacier, no Lens/Supremacy reach; ordinary Gust channels versus enemy TP and immunity; unseen enemies revealed after a successfully aimed Gust (no blind casts); immediate Glacier during observed Multishot versus TP/other channels, knockback/terrain geometry, high-ground damage and Marksmanship suppression; supported friendly-wave tower siege; copied Shard/Scepter activation. Hero-local MoM activation/combo logic was removed from the ability pass; safe MoM/Gust/Multishot and Pike unlimited-range attacks, Gust-to-TP, BKB/Manta/Satanic timing belong in TASK-21. Counterplay/draft ideas remain separate. Movement during Multishot and damage across every wave are not simulated; no lobby or deep dive performed.

Final integrated verification: node tests/run-builds.cjs exited0 after all final reviews/corrections. Exact five hero markers passed;368 Lua files parse,128 native/32 Rubick Valve checks with zero findings,127 heroes/253 roles,133 specialized dispatches,68 Rubick native behavior cases and272 purchase lists. All five native build/skill/talent prefixes remain byte-identical with HEAD; git diff --check passed. Shared dispatcher registers all five dedicated handlers; narrow observed Drow Glacier, Earth Spirit Magnetize Stone and owned Elder Titan Spirit/minion hooks are covered. TASK21/24 source-derived observations recorded. No engine lobby launched; remaining capability boundaries are in each task checklist.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Drow Ranger: corrected manual orb/Multishot attack reach, physical cone targets, Gust peel and safe Glacier with observed Multishot-only channel exception. Native/copy specs, final integrated suite, pinned Valve validation, unchanged build prefixes and whitespace pass. Source audits and lobby limits recorded; ready for in-game test.
<!-- SECTION:FINAL_SUMMARY:END -->
