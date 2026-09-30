---
id: TASK-4
title: Continue the D2PT 7.41f build migration from Disruptor onward
status: In Progress
assignee:
  - '@codex'
created_date: '2026-09-29 21:29'
updated_date: '2026-09-30 15:27'
labels:
  - builds
dependencies: []
documentation:
  - docs/D2PT_BUILD_UPDATES.md
priority: medium
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
BotLib builds, talents and skill orders were outdated. Heroes are being rebuilt alphabetically from dota2protracker 7.41f data, only for roles with enough matches, with matching position weights, neutral preferences and D2PT matchup lists. Abaddon through Death Prophet are done.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each migrated hero has a BotLib/Builds file, 7.41f annotations and weights in both TS and Lua
- [ ] #2 Roles without enough D2PT evidence have weight 0
- [ ] #3 node tests/run-builds.cjs passes after each hero
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
2026-09-30: Research Kez carry, Marci mid/offlane and optional supports, Mars offlane, Medusa carry, Mirana supports. Update BotLib, build metadata, neutral preferences and paired weight/matchup tables. Validate the five-hero batch and preserve unrelated edits.

2026-09-30 next batch: Review Meepo mid and optional carry, Monkey King carry/mid, Morphling carry, Muerta carry and Naga Siren carry. Collect coherent builds and normalized All-role matchups, verify ability/talent maps and recipes, update metadata and paired weights, and validate each hero while preserving prior changes.

2026-09-30: Review Necrophos pos3/2/1, Shadow Fiend pos1/2, Night Stalker pos3, Nyx pos4 and optional pos5/2, Ringmaster pos5/4, OD pos2, Ogre pos5/4/3, Omniknight pos5/3, Oracle pos5 and optional pos4, Pangolier pos2/3. Collect coherent role builds, neutral preferences and normalized All-role matchups; verify skills/talents and recipes, integrate paired weights and registration, validate each hero and the batch, and preserve unrelated work.

2026-09-30: Review Phantom Assassin/Phantom Lancer carry, Phoenix support/hard support/offlane and optional mid, Primal Beast offlane/mid, Puck mid, Pudge support/hard support/offlane/mid and carry, Pugna supports and optional mid, Queen of Pain mid, Clockwerk supports, and Razor offlane/carry and optional mid. Preserve the prior uncommitted batch; research coherent builds and normalized All-role matchups, verify current skills/talents and inventory progression, integrate paired weights/registration, and validate the expanded roster.

2026-09-30: Review Riki carry/mid, Sand King offlane/mid, Shadow Demon and Shadow Shaman supports, Timbersaw offlane and optional mid, Silencer supports, Wraith King offlane/carry, Skywrath supports and optional mid, Slardar offlane and optional mid, and Slark carry/mid and optional offlane. Rubick is explicitly deferred. Preserve both uncommitted batches; collect role/build/neutral observations and normalized All-role matchups, verify current skills/talents and six-slot recipes, integrate paired tables, and run the required validation.

2026-09-30: Review Snapfire mid/support/hard support and optional offlane, Sniper mid, Spectre carry, Spirit Breaker supports and optional offlane, Storm Spirit mid, Sven carry, Techies supports, Templar Assassin carry and optional mid, Terrorblade carry and Tidehunter offlane. Preserve the three uncommitted batches; collect coherent role builds, neutral/enchantment observations and normalized All-role matchups, verify skills/talents and six-slot recipes, integrate paired tables and validate. Review upstream PR #163 and apply a sound, scoped Tidehunter fish-denial fix with regression coverage.

2026-09-30: Review Tinker mid, Tiny carry/mid/support, Treant hard support and optional support, Troll carry, Tusk supports and optional mid, Undying hard support/offlane/support, Ursa carry, Venge hard support/carry and optional offlane/support, Venomancer supports and Viper mid/offlane. Preserve four uncommitted batches; collect coherent builds, current-tier neutral/enchantment samples and normalized All-role matchups, verify actual skills/talents and six-slot recipes, integrate paired tables/registration and run required checks.

2026-09-30 final roster batch: Review Visage offlane/mid, Void Spirit mid and optional offlane, Warlock hard support, Weaver support/carry and optional offlane/hard support, Windranger all five roles, Winter Wyvern supports and optional offlane, Io hard support/mid/carry/support, Witch Doctor supports, and Zeus support/hard support/mid. Remote checked and already synced. Collect coherent role builds and normalized All-role matchups, verify real ability/talent maps and recipes, integrate paired weights/neutral metadata, and validate each hero while preserving other work.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-09-30: Completed Kez pos1, Marci pos2/3, Mars pos3, Medusa pos1 and Mirana pos4/5. Recorded observed D2PT build and role samples, reviewed neutral/enchantment preferences, guarded level-10 skill swaps and practical item continuations. Updated paired weight and normalized All-role matchup tables; moved Kez into alphabetic position. Reviewed and deferred Marci supports. node tests/run-builds.cjs, node tests/matchups_spec.cjs and git diff --check passed. Lobby purchase/active/talent validation remains outstanding. Preserved unrelated working-tree edits; broader migration remains In Progress.

2026-09-30: Completed Meepo pos1/2, Monkey King pos1/2, Morphling pos1, Muerta pos1 and Naga Siren pos1. Added D2PT role/build samples, source windows, neutral/enchantment observations and paired weights/matchups. Weights: Meepo 45/67; Monkey King 53/49; Morphling 61; Muerta 55; Naga Siren 57. Corrected Meepo skill queue to spend four ultimate points at 3/10/17/24 without duplicate talents; extended generic validation and real ability layouts for Monkey King/Morphling. Build suite passed after each hero; source skill/talent audit passed for seven roles; matchup suite and diff whitespace check passed. Preserved prior/unrelated edits and closed background research tab. Lobby purchase/active/talent checks remain outstanding; broader migration stays In Progress.

2026-09-30: Completed Necrophos pos1/2/3, Shadow Fiend pos1/2, Night Stalker pos3, Nyx pos2/4/5, Ringmaster pos4/5, Outworld Destroyer pos2, Ogre pos3/4/5, Omniknight pos3/5, Oracle pos4/5 and Pangolier pos2/3 (10 heroes, 21 roles). Optional Nyx mid/hard support and Oracle support had complete eligible samples. Added observed build/source windows, neutral/enchantment preferences, paired weights and normalized All-role matchups; kept skipped roles at zero with forced-pick fallbacks. Updated current Shadow Fiend, Night Stalker, Ogre and Omniknight ability handling and reviewed recipes/six-slot continuations. Build suite passed at 75 heroes / 140 roles; matchup checks passed under Node 24; git diff --check passed. Background research tabs closed. Lobby purchase/active/talent checks remain outstanding; broader migration stays In Progress. Batch changes remain uncommitted.

2026-09-30: Completed Phantom Assassin pos1, Phantom Lancer pos1, Phoenix pos2/3/4/5, Primal Beast pos2/3, Puck pos2, Pudge pos1/2/3/4/5, Pugna pos2/4/5, Queen of Pain pos2, Clockwerk pos4/5 and Razor pos1/2/3 (10 heroes, 23 roles). Optional Phoenix/Pugna/Razor mid samples were eligible and complete; Pudge carry retained as a reviewed user-requested exception at 205 matches / 1.5% share. Added role/build samples, current-tier neutral/enchantment preferences, paired weights and normalized All-role matchups; documented forced-pick fallbacks. Verified source first-ten skills and popular talents, default/custom legality, current recipes and six-slot continuations. Corrected PA learnable Immaterial layout/dagger damage, PL stale range bonus, Puck fractional Phase timing, Pugna duplicated talent damage and Razor field radius. Build suite passed at 85 heroes / 163 roles; matchup checks passed under Node 24; git diff --check passed. Preserved the prior uncommitted batch and unrelated shared entries; research tab closed. Lobby purchases/actives/talent effects remain to test; task stays In Progress and changes remain uncommitted.

2026-09-30: Completed Riki pos1/2, Sand King pos2/3, Shadow Demon pos4/5, Shadow Shaman pos4/5, Timbersaw pos2/3, Silencer pos4/5, Wraith King pos1/3, Skywrath Mage pos2/4/5, Slardar pos2/3 and Slark pos1/2/3 (10 heroes, 22 roles). Optional mid roles and Slark offlane had eligible, coherent samples; Slark offlane retained at weight 46 with a Mage Slayer/Scepter progression. Rubick remains explicitly deferred. Added observed role/build windows, reviewed neutral/enchantment preferences, paired weights and normalized All-role matchups; kept skipped roles at zero with forced-pick fallbacks. Verified current ability/talent names, guarded custom builds, recipes and six-slot continuations; fixed Riki/Sand King/Skywrath engine fields, Shadow Demon friendly Cleanse/immune Purge and Shadow Shaman duplicate talent damage. Build suite passed at 95 heroes / 185 roles; matchup checks passed under Node 24; git diff --check passed. Preserved both prior uncommitted batches and unrelated shared entries, and closed the research tab. Lobby purchases/actives/talent effects remain to test; task stays In Progress and changes remain uncommitted.

2026-09-30 batch 9 complete: Snapfire 2/3/4/5; Sniper 2; Spectre 1; Spirit Breaker 3/4/5; Storm Spirit 2; Sven 1; Techies 4/5; Templar Assassin 1/2; Terrorblade 1; Tidehunter 3 (10 heroes / 17 roles). Updated build metadata, registered neutral/enchantment preferences, both weight tables and All/Normalized primary-role matchups. Reviewed source skills, real talent slots and six-slot item progression; Techies4 keeps observed Hex before optional upgrades. Applied upstream PR #163 fish exclusion across six allied-creep deny/aggro paths, with regression coverage. Updated Mask of Madness disassembly to current Broadsword component, retaining the Satanic completion guard and regression coverage. Corrected observed ability dispatch/range details for Spectre, Sniper, Snapfire, Spirit Breaker, Storm Spirit and Sven, and removed Tide Gush duplicate talent damage. Full builds validation passed 105 heroes / 202 roles; matchup checks passed using bundled Node 24; git diff --check passed. Earlier 60 hero/build files preserved byte-for-byte, shared edits limited to current batch entries; WeakHeroes and global neutral pools unchanged. Background research tab closed. Changes remain uncommitted; purchases, actives, talents and fish behavior still need lobby verification. Rubick remains deferred; broader migration continues.

2026-09-30 batch 10 complete: Tinker 2; Tiny 1/2/4; Treant Protector 4/5; Troll Warlord 1; Tusk 4/5; Undying 3/4/5; Ursa 1; Vengeful Spirit 1/3/4/5; Venomancer 4/5; Viper 2/3 (10 heroes / 21 roles). Optional Treant4 and Venge3/4 have eligible complete builds; Tusk2 deferred at 155 matches / 3.2% share. Added coherent observed builds/source windows, actual skill/talent mapping, reviewed current-tier neutral/enchantment preferences and paired weights/normalized All-role matchups. Independent review passed all source first-ten skills/popular talent slots, recipe reuse/six-slot progression and 210 neutral/enchantment tier tables. Preserved Hydra Dragon Lance upgrade using existing real item IDs; corrected Crystalys/Drums IDs during review. Scoped mechanics corrections: Tiny Avalanche damage field; Troll explicit stance vs passive handling, melee axes specials and fractional Trance duration; Ursa fractional hop duration; Venomancer Snakebite unit-target dispatch and Gale total damage arithmetic. Targeted mechanics checks passed. Full build suite passed 115 heroes / 223 roles after the final Troll correction; matchup checks passed with bundled Node 24; git diff --check passed. All 87 prior-batch files preserved byte-for-byte, including fish/Mask fixes and their tests; unrelated shared table entries unchanged. Background research tabs closed. Changes remain uncommitted. Lobby purchases, actives and talent effects remain to verify; Rubick remains deferred and the broader migration stays In Progress.

2026-09-30 final roster batch: Migrated Visage 2/3, Void Spirit 2/3, Warlock 5, Weaver 1/3/4/5, Windranger 1/2/3/4/5, Winter Wyvern 4/5, Io 1/2/4/5, Witch Doctor 4/5 and Zeus 2/4/5. Optional Void Spirit offlane and Weaver offlane/hard support meet sample thresholds; Winter Wyvern offlane remains skipped at 4.0%. D2PT shows a fifth Arctic Burn point at level 8; documented a legal Splinter Blast substitution. Io hard support preserves the observed attribute point at 10 and talents at 11/15, with legal custom queues; updated its TypeScript source and generated Lua. Registered nine data files with separate overview/build/skill/opening samples, paired formula weights and filtered current-tier neutral/enchantment observations. Reviewed T5 suitability and six-slot purchase/sell/recipe progression. Refreshed each primary-role matchup with All roles and Normalized enabled, weighted displayed rows and 100-match minimum. Source skills, reviewed talents and starting inventories audited for all 25 roles. Build suite passed after each hero and final review: 124 heroes, 248 migrated roles; matchup tests and diff check passed. TypeScriptToLua compiled without errors; four existing warnings remain in advanced_item_strategy.ts. Remote was already synchronized before starting; research tab closed. Rubick remains deferred, WeakHeroes and global neutral pools unchanged; purchases, actives and talent effects still need lobby validation.
<!-- SECTION:NOTES:END -->
