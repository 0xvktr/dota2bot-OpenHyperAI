---
id: doc-2
title: Hero improvement playbook
type: guide
created_date: '2026-09-30 13:58'
updated_date: '2026-10-01 12:49'
tags:
  - hero
  - process
---
# Hero improvement playbook

How we improve heroes' in-game play (ability use, combos, counterplay) beyond their D2PT builds. Builds, talents and skill orders are covered separately by `docs/D2PT_BUILD_UPDATES.md`.

## Three levels of work

1. **Roster-wide sweep (once, then after every patch).** A script checks every `bots/BotLib/hero_*.lua` against Valve's ability data: ability names, talent names and the value keys read with `GetSpecialValueInt`/`GetSpecialValueFloat`. A wrong key silently returns 0 and a wrong talent name silently never trains, so these bugs never show up as errors. Findings are fixed in batches. Commands: `node tests/valve/refresh.cjs` (after a patch) and `node tests/valve_ability_check.cjs` (also part of `node tests/run-builds.cjs`); intentional exceptions go in `tests/valve/allowlist.json` with a reason (TASK-23).
2. **Standard hero pass (every hero, roughly 30-60 minutes).**
   - Build a checklist from Valve's ability data, the hero's Torte de Lini ability tips and dotacoach's Strategy section.
   - Compare it with the cast order in `SkillsComplement()` and each `ConsiderX()`.
   - Fix the gaps, add an offline spec (`tests/hero_harness.lua` pattern), then move the task to *Needs In-Game Test*.
   - Ideas that describe how to play **against** the hero go to the counterplay task, not the hero file.
3. **Deep dive (heroes on the `WeakHeroes` list only).** Adds videos, Liquipedia mechanics and a fixed-roster test game. The goal is a recorded decision on whether the hero leaves the weak list.

## Sources

| Source | Cost | Best for | Trust |
|---|---|---|---|
| Valve ability data (d2vpkr `scripts/npc/heroes/npc_dota_hero_<name>.txt`, `resource/localization/abilities_english.txt`) | Very low, scriptable | Names, cast behaviour, values, formulas | Authoritative |
| Torte de Lini guides (`node tools/tdl/fetch.cjs <hero>`, fetched from the Steam Workshop) | Low, works on any machine | Combos and when to use each spell; item usage tips | Good; see the notes below |
| dotacoach (`/en/heroes/<slug>` and `/en/heroes/counters/<slug>`) | Low, pages are server-rendered | Strategy, counter strategy, synergy setups, counter items | Needs checking; some text is stale |
| D2PT | Low | Builds, roles, matchups | Good for builds |
| Liquipedia | Medium; blocks automated fetching | Edge-case mechanics | Good; paste by hand |
| Videos | High | Deep dives on weak heroes | Values often outdated |

## Torte de Lini guides

`node tools/tdl/fetch.cjs <hero>` prints a hero's ability tips and item tips (internal hero name, e.g. `ancient_apparition`). It downloads the guide from the Steam Workshop through Steam's public API, so it needs no Dota install and no key; `tools/tdl/guides.json` maps heroes to Workshop guide IDs (136 guides, 126 heroes as of 2026-10-01). Downloads are cached in the git-ignored `tools/tdl/cache/`; `--refresh` re-downloads, `--all` caches everything.

How to read them:

- **Ability tips lean toward the laning stage.** They say little about mid- and late-game fights; use dotacoach and Valve's data for those.
- **Some heroes have two guides** (different positions, or magic vs physical builds). They differ mainly in items. The script merges them and labels a tip with its guide only where the guides disagree.
- **Ignore the item builds.** Builds, talents and skill orders come from D2PT (`docs/D2PT_BUILD_UPDATES.md`). The useful parts are the per-ability tips and the per-item usage tips; the item tips feed the item-usage work (TASK-21).
- **Older-patch guides are kept on purpose.** A guide written for 7.41b-e still describes how the spell is used. Check anything numeric against Valve's data.
- **Spirit Breaker has no guide in the index.** Use dotacoach and Valve's data for that hero.

The index is rebuilt from a Dota install: open the missing hero's Torte de Lini guide in game once so Dota caches it, then run `node tools/tdl/build_index.cjs "<dota 2 beta>/game/dota/workshop/steampublic"`.

## Verification rule

Every claim from a guide, site or video is checked against Valve's ability data before it becomes code. Examples found so far:

- dotacoach still mentions AA's "facet"; facets are deprecated in the game files.
- dotacoach says Wind Waker dispels Ice Blast; Valve marks Ice Blast as not dispellable.
- The AA video used old Ice Blast radius and talent values.

## Copyright

Guide, site and video text is not ours. Turn it into logic and short comments in our own words; never paste it into the repo.

## Where findings go

- Spell use and combos: the hero's `SkillsComplement()` / `ConsiderX()`.
- Item actives: `bots/ability_item_usage_generic.lua`.
- How any bot should react to an enemy spell: the counterplay task.
- Synergy and counter picks: draft matchups (`FunLib/aba_matchups.lua`).

## Tracking in Backlog

- TASK-13 is the umbrella. Create a subtask per hero (`backlog task create -p TASK-13 ...`) only when work on that hero starts, so the board doesn't fill with idle tasks.
- Each hero subtask uses the standard pass as its acceptance criteria and ends in *Needs In-Game Test*.
- Heroes on the `WeakHeroes` list get the `weak-hero` label and the "Weak heroes playable" milestone.
- Run a hero's ability pass after its D2PT build migration has landed: both touch the same `hero_*.lua` file.
