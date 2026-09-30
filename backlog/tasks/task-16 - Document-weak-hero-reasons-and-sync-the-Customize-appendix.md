---
id: TASK-16
title: Document weak-hero reasons and sync the Customize appendix
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-30 13:59'
labels:
  - draft
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/hero_selection.lua
  - bots/Customize/general.lua
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
priority: low
ordinal: 16000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
WeakHeroes in hero_selection.lua limits bot-execution-quality risks, but nothing records why each hero is on it or what gets it off. The appendix in Customize/general.lua has drifted: it lists KotL, Winter Wyvern, Phoenix, Pudge, Muerta and Elder Titan (removed from the live list) and misses Rubick, Brewmaster and Puck (added in 2025).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every WeakHeroes entry has a one-line reason and a criterion for leaving the list
- [ ] #2 The appendix points to the live list instead of duplicating it
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five (doc-1, section 8) rated Earthshaker low because it never mastered Fissure's geometry. Skills needing precise geometry are a natural criterion for the weak-hero list.
<!-- SECTION:NOTES:END -->
