---
id: TASK-39
title: Add contextual bot banter inspired by issue 38
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 16:30'
updated_date: '2026-10-02 16:58'
labels: []
dependencies: []
references:
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/38'
type: feature
ordinal: 165000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Issue 38 asks for more personality through match-aware trash talk. Extend existing offline chat with original localized reactions to observable match events, retaining language and trash-talk preferences.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Bots react to fresh kills, streaks, deaths, escapes and team momentum with context-appropriate original lines.
- [x] #2 Banter respects enablement and intensity settings, current locale, cooldowns and repetition limits.
- [x] #3 Deterministic tests cover event detection, suppression, localization fallback and runtime integration; document settings and in-game checks.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add an isolated event detector and rate-limited runtime adapter for observable match events. 2. Add original English, Chinese, Russian and Japanese phrase pools using existing locale preferences. 3. Replace legacy spontaneous taunts, preserve replies and validate language commands. 4. Run focused Lua behavior/integration tests and record in-game validation needs.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented 200 original lines across en/zh/ru/ja and ten event categories, factual scoreboard/encounter detection, one reaction per observation, chance gates and bot/team/event cooldowns. Preserved master mute and intensity controls. Hardened standalone language commands during draft and match; cn aliases zh. Fixed reply-speaker indexing for mixed rosters and canonical Meepo clone exclusion while dead. Existing unrelated hero changes were preserved. Verification: node tests/run-builds.cjs passed (587 Lua syntax files, all registered regression suites); new banter suite passed 215 assertions and reply-member scenarios passed. TSTL compilation to a temporary output directory passed with four existing advanced_item_strategy truthiness warnings. git diff --check passed. No game installation, live match or daily-driver channel was touched. Remaining: local Dota lobby validation of callback delivery, shared hero-handle state and subjective banter pacing; checklist in docs/BOT_BANTER.md.

User requested level 2 as the shipped default and commit/push. Updated Customize/general.lua and the settings documentation; reran the banter suite (215 assertions), reply-member scenarios and git diff --check successfully.

Integrated newer origin/main High Five, farm eligibility and item cleanup changes before publication. The merged full regression runner passed, including 593 Lua syntax files, 215 banter assertions, reply-member scenarios and all registered suites. In-game validation remains pending.

Review pass (English only): banter.lua now names the victim or killer when exactly one enemy score moved with the bot's, and adds revenge, shutdown, repeat-kill (dominating) and team-wipe events; observation starts in pre-game so a pre-horn first blood counts; allied bots skip the last eight lines used; human-involved kills are voiced at 65%. English pools rewritten (10-16 lines each, {victim}/{killer} lines, the classic '?' restored). zh/ru/ja unchanged and reuse their kill/team_fight pools for the new events. Removed the unused legacy English taunt pools from localization.lua; the zh/ru/ja copies are still there and unused. node tests/run-builds.cjs passes (banter spec 363 assertions). Needs lobby check: named lines, IsHeroAlive during reincarnation, pacing.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added offline, localized contextual bot banter inspired by issue 38, with original quips, spam/repetition protection, safe language commands and reliable speaker/clone handling. All automated regression checks passed, including 215 new banter assertions. Ready for in-game validation using docs/BOT_BANTER.md.
<!-- SECTION:FINAL_SUMMARY:END -->
