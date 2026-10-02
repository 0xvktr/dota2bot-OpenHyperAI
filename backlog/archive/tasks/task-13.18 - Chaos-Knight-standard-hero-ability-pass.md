---
id: TASK-13.18
title: 'Chaos Knight: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 16:04'
updated_date: '2026-10-01 18:12'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_chaos_knight.lua
  - bots/FunLib/rubick_hero/chaos_knight.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 58000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Chaos Knight is in the next standard-pass batch after Bloodseeker/Bounty Hunter/Bristleback/Broodmother/Centaur. Review current ability decisions and combos against guide strategy and authoritative mechanics, including applicable Rubick handling. Existing D2PT builds and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve/localization with TDL and complete dotacoach strategy/matchups; audit random Bolt damage, Rift immunity and Phantasm dispel/illusion support. 2. Fix legal targeted casts, interrupt/kill priority, Rift into Bolt order and Phantasm farm/defensive use with combo mana in native and copy; preserve builds and generic minions. 3. Add native/copy regressions and source exclusions/lobby checklist, then hand root shared checks/finalization.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01):
- [x] Pinned Valve hero KV and English abilities localization at cf0d37a32c8df338a7832fd32a282747969e9a5f: https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_chaos_knight.txt . Bolt minimum/maximum damage and inversely related stun rolls, projectile speed900, Rift root restriction/armor reduction/immunity talent, Phantasm basic dispel/invulnerability and current upgrades audited.
- [x] TDL Workshop128918471,7.41f through tools/tdl/fetch.cjs. Adopted longer-range Rift initiation, Bolt once in range, Phantasm before committing illusions, defensive dispel and farm use; retained Armlet before Phantasm. Contradictory item-tip sequence is subordinate to urgent control and illusion setup.
- [x] dotacoach Strategy and Counter Strategy: https://dotacoach.gg/en/heroes/chaos-knight . Reviewed lane burst, ancient farming with Phantasm, fragile illusion damage window, basic-dispel counterplay and Phantasm/Blink/Rift initiation.
- [x] Full Matchup: https://dotacoach.gg/en/heroes/counters/chaos-knight . Reviewed every synergy/core/opponent/counter-item block: allied control, heals and armor reduction support illusion burst; grouped illusions invite area damage/control and physical defenses. Armlet stats before illusion creation, Blink into Bolt, Manta/Rift gathering, Bloodthorn follow-through and team auras remain item-policy candidates.

Stale exclusions: Public Shard cast-range bonus conflicts with pinned KV (+0) and current localization; current Shard supplies a six-second Bolt illusion with reduced damage. Reins of Chaos facet/innate discussions predate current Fundamental Forging and Scepter bonus-illusion upgrade. TDL cooldown-reduction talent and Octarine cast-range claims are stale. Random maximum/average Bolt rolls cannot guarantee a kill. No claim that Phantasm removes every disable or guarantees projectile evasion regardless of its0.4-second cast point. Existing generic illusion control remains unchanged.

Implemented native/copy: Legal Lens/Supremacy-aware cast reach; both self/ally Counterspell and advanced spell-block/reflection guards. Bolt uses minimum damage and cast-plus-projectile delay for reliable lethal decisions, permits close/disabled lethal targets and interrupts in actual reach. Native urgent Bolt precedes Phantasm; otherwise Phantasm prepares burst with follow-up Bolt/Rift mana reserved, Rift initiates beyond Bolt reach, Bolt locks targets once within reach. Rift follows allied control, uses actual immunity value/learned current talent, refuses while rooted, supplies objective target entities and limits ranged-creep movement casts to explicit safe farm/push/defend modes. Removed unsafe unvalidated creep escape assumptions. Phantasm gains root/dust/projectile defense, large ancient/group farm use and objective support; preserves all D2PT build, talent and skill prefixes.

Verification: tests/chaos_knight_ability_spec.lua passes exact marker Chaos Knight ability scenarios passed. Native/copy coverage: random-roll lethal and travel delay, channel/range/reflection, Rift immunity/root/controlled target, objective entity regression, Phantasm dispel/projectile reaction/ancient farm/nearby-fight suppression and combo mana, native interrupt/setup/Rift/Bolt order. Valve checker passed128 hero files/22 copies with zero allowances at this intermediate point; root owns final shared suite/status/AC. Diff check clean.

Lobby: minimum/maximum Bolt rolls and projectile escape; Phantasm0.4 cast vs incoming projectile arrival and actual basic-dispel effects; Scepter global ally illusions plus bonus chance, Shard Bolt illusion current reach; Armlet->Phantasm->Rift/Bolt with mana boundary; native talent and copied immunity behavior, actual Lens/Supremacy bonus accounting; safe ancient farming and objective Rift. No game launched. Item/counterplay candidates: Blink->Bolt->Rift, Armlet before snapshots, BKB/Orchid/Bloodthorn follow-through; illusion AoE clearing, physical defenses and reflection/dispel response. Generic items/minions/draft not edited.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 after all review repairs; exact markers confirmed for all five new hero specs, 348 Lua files parsed, Valve check 128 native heroes / 22 Rubick copies / 0 allowlisted findings, 127 hero role tables, 90 specialized dispatches, 61 Rubick behavior cases and 272 purchase lists. git diff --check passed. HEAD comparison confirms this hero build/skill/talent prefix unchanged. No lobby launched; standard pass handed off as Needs In-Game Test, with capability limits above. Item/counterplay findings appended to TASK21/24.

Commit/push integration (2026-10-01): remote main advanced through6616fcb item policy and3c1501b early lane-defense. Rebase preserves both remote commits and all20 hero passes. BB Hairball/ordinary Quill retain selected ability handles for item/Treads policy. CK retains remote Clear/action lock and useful low-mana Chaos Bolt consideration, validated restoration in urgent/ordinary branches, and ability-aware normal Bolt/Rift/Phantasm prep; urgent Bolt retains immediate priority, and failed restoration allows other spells. Faithful CK tests cover enabling Mango, changed target, post-restoration reconsideration, no-item Rift fallback and queued lock. Independent merged review passed. Combined node tests/run-builds.cjs and node tests/run-objectives.cjs both exited0;375 Lua files,128 native/32 copy Valve checks with zero findings,133 copied dispatches,68 Rubick cases and272 purchase lists, plus remote item-policy and lane-defense/objective regressions. No game launched.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Chaos Knight native and Rubick decisions now use conservative random Bolt kills, real reach, protected/reflected target guards, useful Rift and prioritized Phantasm preparation/dispel. Builds preserved. Focused scenarios, final shared suite and Valve check passed; pending lobby mechanics and source exclusions recorded.
<!-- SECTION:FINAL_SUMMARY:END -->
