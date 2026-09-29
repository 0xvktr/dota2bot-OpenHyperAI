---
id: TASK-12
title: Study the OpenAI Five paper for macro lessons
status: Done
assignee:
  - '@claude'
created_date: '2026-09-29 21:29'
updated_date: '2026-09-29 22:15'
labels:
  - macro
dependencies: []
references:
  - 'https://arxiv.org/abs/1912.06680'
priority: low
type: spike
ordinal: 12000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
OpenAI Five (Dota 2 with Large Scale Deep Reinforcement Learning, 2019) reached pro level through the same Lua bot API. Its findings on play style, farm allocation, grouping, rotations and objective values could inform the farming and macro tasks.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Findings applicable to these scripts are written into a backlog doc with the tasks they affect
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Read the paper (arXiv 1912.06680): main text plus the appendices on reward shaping, scripted/restricted parts, hero pool and observed behaviour.
2. Check the claims in this task's description against the text and correct them.
3. Map each applicable finding to existing tasks (TASK-5/6/8 farming and laning, TASK-9/10 macro, TASK-11 teamfight, TASK-20 mid rotations, TASK-21 items) or new tasks.
4. Write the findings doc and update or create tasks.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Verified: doc-1 has 9 sections, each mapping findings to tasks (TASK-1, 4, 5, 6, 8, 10, 11, 16, 20, 21.1, 22). Each affected task links doc-1 and has a note with the finding. Corrected this task's description: the paper does not describe aggressive buybacks (buyback control was added mid-training alongside a patch upgrade, so its effect is confounded).
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Read arXiv 1912.06680 (main text and the appendices on scripted actions, reward weights, randomisation, timing, hero pool). Wrote backlog doc-1 with eight findings, each mapped to tasks; added notes to TASK-5, 6, 8, 10, 11, 16, 20 and 21.1; created TASK-22 (adapt team play to the game state). Verified by checking the doc's task references and each task's doc link and note.
<!-- SECTION:FINAL_SUMMARY:END -->
