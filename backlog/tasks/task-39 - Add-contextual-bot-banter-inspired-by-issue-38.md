---
id: TASK-39
title: Add contextual bot banter inspired by issue 38
status: In Progress
assignee:
  - '@codex'
created_date: '2026-10-02 16:30'
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
- [ ] #1 Bots react to fresh kills, streaks, deaths, escapes and team momentum with context-appropriate original lines.
- [ ] #2 Banter respects enablement and intensity settings, current locale, cooldowns and repetition limits.
- [ ] #3 Deterministic tests cover event detection, suppression, localization fallback and runtime integration; document settings and in-game checks.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add an isolated event detector and rate-limited runtime adapter for observable match events. 2. Add original English, Chinese, Russian and Japanese phrase pools using existing locale preferences. 3. Replace legacy spontaneous taunts, preserve replies and validate language commands. 4. Run focused Lua behavior/integration tests and record in-game validation needs.
<!-- SECTION:PLAN:END -->
