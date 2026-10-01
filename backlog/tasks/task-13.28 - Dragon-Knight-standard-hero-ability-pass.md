---
id: TASK-13.28
title: 'Dragon Knight: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:34'
updated_date: '2026-10-01 18:02'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_dragon_knight.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 68000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Dragon Knight is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Audit current Valve definitions/localization, Torte de Lini and all dotacoach Strategy/Counter/Matchup sections. Preserve build prefix. Correct legal Dragon Form spell reach, prioritize urgent Dragon Tail, predict Breathe Fire as an unreflectable point cone, use Fireball as persistent zoning, and improve safe Form objective/farm use. Add dedicated Rubick handling and meaningful behavior scenarios, then document stale advice, item/counter observations and lobby limits.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source audit (2026-10-01): pinned Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero KV and abilities_english localization reviewed; Torte de Lini fetch dragon_knight, guide 286904891 (7.41f), including all item tips; https://dotacoach.gg/en/heroes/dragon-knight Strategy and Counter Strategy; https://dotacoach.gg/en/heroes/counters/dragon-knight all gameplay/statistical synergy, good/bad matchups and core/counter items reviewed. No source prose copied.
Checklist implemented: urgent Tail before transform/nuke; human Tail 150 plus observed Dragon Form generic cast bonus 350 for every spell, actual Lens value and trained/unbroken Supremacy; both Counterspell modifiers and spell block/reflect guards for targeted Tail; forecast Tail projectile versus observed TP time; Breathe Fire uses unreflectable point casting, cast/flight prediction and expanding cone coverage; reduced enemy attack output for retreat/ally peel; protected/regen-aware lethal estimates; budgeted grouped farming and remote lane last hits. Fireball uses legal center plus footprint for controlled combat/group farm/objectives, never full-duration instant-kill claims. Form uses actual future reach, safe fights, supported friendly-wave tower pressure, objectives and higher-level splash camp clearing. Shared validator excludes buildings; objectives use the dedicated building validator. Native build/skill/talent/MinionThink prefix preserved byte-for-byte; dedicated Rubick handlers use supplied live ability handles.
Stale/unverified claims excluded: old Tail-specific transformed range and stale guide stun scaling; Form bonus attack damage is currently zero; obsolete dragon facets; generic claims armor protects against magical/pure damage; Firefly pure-damage matchup claim; Nullifier removing passive abilities. Current Dragon Blood is breakable and only physical armor mitigates ordinary physical damage. Source matchup tables inform observations, not draft edits.
Offline verification: exact marker Dragon Knight ability scenarios passed; six owned DK/Drow files/specs Lua 5.2 parse; Valve ability check 128 hero files / 32 copies / zero findings at this checkpoint; git diff --check clean; prefix equality confirmed. Parent owns dispatcher/full-suite/finalization.
Lobby checklist: human/Form/Lens/Supremacy Tail reach and real engine GetCastRange handling; single stolen Tail under observed Form with no linked Form handle (verified current KV fallback 350); short versus long enemy TP; point Fire into Counterspell/Linkens and ethereal targets; expanding cone wave coverage; Tail-to-Fireball zone dwell and upgraded radius; level-2+ Form farm and allied-wave tower activation; no spells during channel/queue; copied Scepter/Shard actual availability. Offline geometry is conservative and predicts visible movement only. Blink initiation, Armlet/Soul Ring/MoM/BKB sequencing and generic toggles remain TASK-21; draft and responses to enemy regen/break/armor remain separate. No lobby run or deep dive performed.

Final integrated verification: node tests/run-builds.cjs exited0 after all final reviews/corrections. Exact five hero markers passed;368 Lua files parse,128 native/32 Rubick Valve checks with zero findings,127 heroes/253 roles,133 specialized dispatches,68 Rubick native behavior cases and272 purchase lists. All five native build/skill/talent prefixes remain byte-identical with HEAD; git diff --check passed. Shared dispatcher registers all five dedicated handlers; narrow observed Drow Glacier, Earth Spirit Magnetize Stone and owned Elder Titan Spirit/minion hooks are covered. TASK21/24 source-derived observations recorded. No engine lobby launched; remaining capability boundaries are in each task checklist.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Dragon Knight: corrected Form spell reach, urgent Tail, predicted cone Fire, safe Fireball/Form farm and objectives; supplied copied handles and travel/regen protections. Native/copy specs, final integrated suite, pinned Valve validation, unchanged build prefixes and whitespace pass. Source audits and lobby limits recorded; ready for in-game test.
<!-- SECTION:FINAL_SUMMARY:END -->
