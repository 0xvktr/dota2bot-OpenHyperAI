# D2PT build updates

Use Dota2ProTracker's most-played coherent build for each supported hero-position pair.
Record the patch, retrieval date, source URL, role samples, and build samples in the hero's
data file under `bots/BotLib/Builds/`; keep this document general rather than creating a
report for every hero. Role overview and build windows can differ: record them separately.

## Positions and drafting

Normally update roles with at least 50 matches and 5% of the hero's role sample. Review
borderline roles rather than trusting a tiny sample's win rate. For a migrated hero, give
skipped positions zero weight; explicit player picks can use a documented fallback build.
Leave unmigrated heroes available while the roster is updated incrementally.

Weights are selection priorities, not win predictions. Every migrated role uses one formula:

    weight = round(30 + rating * min(1, sqrt(matches / 2000))), capped at 100

`rating` is D2PT's role rating (0-100) from the hero page's role tabs, and `matches` is that role's
count in the same overview window; record both in the hero's `Builds/` data file. D2PT's rating
combines performance and draft priority, but a high win rate on a few hundred games can still rate
as well as a hero played ten times as often, and D2PT itself gives no tier to small role samples.
The square-root confidence factor keeps full weight for 2000+ matches and discounts smaller samples
(for example Chen pos 5, 379 matches, rating 43 -> 49; Crystal Maiden pos 5, 3983 matches, rating
48 -> 78). The 30 is a freshness baseline for having an updated build. Skipped roles are 0. Put the
same numbers in the TypeScript and generated Lua tables; `tests/build_validator.lua` checks both
the formula and the sync.

How much the weights matter in drafting: a weight of 50+ always enters the position's candidate
pool (lower weights enter with probability (weight - 5) / 46), and scoring adds
`weight / 20` to the matchup score, so weights differentiate most through pool entry and large gaps.
Unmigrated heroes keep their original hand-tuned weights on a different scale until migrated.
Do not confuse within-hero role share with global pick rate.

Draft scoring adds a positive role bonus so higher weights help even with negative or
zero matchup scores, and uses the assigned position after player-slot shuffling.
`WeakHeroes` is a separate bot-execution-quality restriction, not a D2PT meta rating.
Refreshing a build does not establish that its casting/positioning limitations are fixed.
Keep that flag until gameplay validation supports removing it. With the default cap of
one, the first flagged hero is eligible without a score penalty; further flagged picks
are blocked. If the cap is raised, the configured penalty also affects later picks.

## Items, abilities, and talents

Use explicit starting items and preserve the selected build's progression. Prefer robust
pick samples over the highest win rate from a handful of games. Follow observed early
skill orders and talent preferences; complete later levels legally when the source only
shows the first ten. Preserve custom overrides and annotate migrated builds with the patch.

Core progression comes first. Add natural upgrades and a sensible late-game continuation,
including Shard and Blessing where appropriate. Label these policy choices in code rather
than implying every continuation is D2PT core. Do not append every situational item or
randomly choose mutually exclusive builds. Avoid replacing useful team items merely to
upgrade boots. Use the existing game recipe API and check purchase/sell compatibility.

## Neutrals

Store per-role neutral and enchantment pick percentages in the hero's data-only build file.
Register it in `hero_build_preferences.lua`; never load hero casting code in the server VM.
Buff selects from its allowed pool and FretBots from its offered candidates. Missing data
or unavailable preferences retain each mode's fallback. Existing active-use restrictions
still apply. Buff has no position allocator, so it uses the documented primary role when
no explicit role is available; FretBots uses its server-side role assignment.

Exclude lower-tier items and enchantments retained in later inventories from higher-tier
rewards. Keep sparse T5 pick observations as weak evidence; never rank them by win rate.
For migrated roles, select the most-picked available item from a reviewed suitability
profile, break equal pick rates by that profile's order, and use the same order when no
observed candidate is available. Profiles cover attack builds, support builds, and
durable casters, with passive effects or supported item actives. Their ordering is bot
policy, not additional D2PT data. The same policy applies to enchantments. Abaddon's
pos 4 has no T5 observations and therefore uses its support profile directly.
Entirely unreviewed offers retain the consumer's legacy fallback as a last resort.
Other tiers, skipped roles, and unmigrated heroes retain their existing behavior.
A hero migration does not refresh the entire global neutral pool or its legacy generator.

## Matchup data refresh

The draft keeps two inputs. Dotabuff supplies numeric enemy matchup scores in
`bots/FretBots/matchups_data.lua`. The 2026-09-28 refresh covers 127 heroes and
16,002 directed pairings using the existing **last 12 months** window, not just 7.41f.
Values are Dotabuff's **disadvantage** percentages: positive is bad for the row hero.
The draft negates them before its existing square-root dampening. Largo was added
to the generator's name table so the current roster is complete.

Run `npm run matchups` to scrape again. If the automated browser is blocked, a
verified browser can export the visible sortable tables as JSON keyed by hero URL
slug, with rows `{name, href, disadvantage}`. Then run
`npm run matchups -- --snapshot path/to/export.json`. Alternatively use `npm run build:node` followed by
`node dist/post-process/matchups.js --snapshot path/to/export.json`.
The generator validates the full roster, all opponents and numeric values before
atomically replacing the Lua file. An incomplete scrape leaves the previous file intact.

`typescript/bots/FunLib/aba_matchups.ts` and its generated Lua retain simple binary
synergy/counter lists. Entries for Abaddon, Underlord, Alchemist, Ancient Apparition,
Anti-Mage, Arc Warden, Axe, Bane and Batrider were refreshed from D2PT on 2026-09-28 (site patch 7.41f).
Unmarked heroes retain their older lists and can be refreshed as their builds are updated.
Source pages are `https://dota2protracker.com/hero/<hero>?section=matchups`.

D2PT requires a source role: hard support for Abaddon/AA/Bane, offlane for Underlord/Axe,
carry for Alchemist/Anti-Mage, and mid for Arc Warden/Batrider. Select **All** opponent/ally
roles and enable **Normalized** for both tables. Collapse the displayed role rows
by hero using a match-count-weighted mean of their normalized values; this is an
approximation from rounded UI values, not an independently calculated all-role
statistic. Rows hidden by D2PT's minimum-match filter are not included. Retain up
to eight positive pairings with at least 100 displayed matches in total. Do not
pad short lists. Per-entry comments record sample counts and normalized percentage
points; runtime lists impose no role restrictions. The source-role bias remains a
limitation for this intentionally minimal refresh, especially for multi-role Abaddon.

A `counter` entry means an enemy the named hero performs well against. Enemy
counter relationships are no longer used to penalize allied picks. The existing
+1.5 synergy bonus remains; the refreshed binary enemy lists are not added on top
of Dotabuff's numeric score. A later review can unify sources, refine sample
weighting and distinguish bot execution quality from human matchup statistics.

## Validation

Run `node tests/run-builds.cjs` (needs the git-ignored `.test-tools/`: luaparse and
fengari-node-cli). Migrating a hero adds **no test code**: `tests/build_validator.lua`
discovers every `bots/BotLib/Builds/<hero>.lua` and checks, for each role:

- **Roles and weights:** every role has `matches`/`winRate`; skipped roles have weight 0;
  migrated roles record their D2PT `rating` and a weight that follows the formula above and
  equals `aba_hero_pos_weights` (TS and generated Lua are compared for all heroes); fewer than 20 matches fails, and a migrated role below 50 matches
  or 5% of the hero is flagged for review. Skipped roles that would be eligible are listed as
  notes, not failures. `defaultRole` is migrated, and the hero source mentions the patch.
- **Items:** every buy/sell item is a known item name; no duplicate purchases apart from
  consumables; an upgrade never precedes its base (Blink, Orchid, Basher, Mekansm, ...;
  see `UPGRADES` in the validator). Sell lists are (new item, old item) pairs. A starting
  component (Branches, Circlet, Gauntlets, Slippers, Mantle, Magic Stick) with no consumer in
  the same list (derived from Valve's recipes) is reported as a note, not a failure: they give
  early attributes and `inventory_upkeep.lua` sells them at a shop after minute 8. Wards are
  a failure on pos 1-3 because only supports ever place them (`mode_ward_generic`).
- **Skills and talents:** loaded with generic names (`A1`..`A6`, `T1`..`T8`). Basics are
  leveled 4 times, the ultimate 3, each talent once, talents go tier 1-4; and the
  level-up queue is simulated so that no talent or premature ability blocks a learnable
  ability. A user-supplied ability build must keep the standard layout.
- **Neutrals:** items exist in the tier they are listed under, pick rates are valid, the
  hero is registered in `hero_build_preferences.lua`, and `Select()` returns the most-picked
  (or, at T5, most-picked reviewed) item regardless of offer order.

`tests/hero_harness.lua` loads hero files offline; a new hero that needs extra engine
stubs at load time should get them there. The other suites cover behavior rather than
data: `neutral_consumers_spec.lua` (both distributors delegate to the preferences),
`alchemist_scepter_spec.lua`, `axe_culling_blade_spec.lua`, plus draft scoring and gift
purchase checks inline in the runner. The suite cannot verify that a build matches D2PT
or that a talent name maps to the intended slot; that still relies on reviewing the
source page. Engine recipes, actual purchases, and item actives require a Dota lobby test.

Run `node tests/matchups_spec.cjs` for matchup roster/sign checks, TypeScript/Lua
list parity, and rejection of incomplete refreshes without overwriting shipped data.

Hero-specific mechanics may need an explicit extension beyond the statistical build.
Alchemist's default carry build enables global Scepter gifts after his personal queue
finishes and core items are present. Queue one gift at a time, reserve buyback gold,
prefer positions 2 then 3 without Scepter, and wait for confirmed consumption before
buying another. Equip the physical Scepter in the donor Alchemist's main inventory
only outside danger; the recipient receives a permanent buff without an item slot.
Bots target the ally's unit handle with `Action_UseAbilityOnEntity`, without a
distance check or movement order. Global targeting still needs engine verification.
Custom builds
do not automatically enable this spending. D2PT's Scepter purchase rate does not identify
gift recipients; this is a bot policy, not an inferred support/jungle build.
