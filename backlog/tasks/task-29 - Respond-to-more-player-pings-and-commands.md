---
id: TASK-29
title: Respond to more player pings and commands
status: To Do
assignee: []
created_date: '2026-09-30 15:22'
labels:
  - macro
dependencies: []
references:
  - bots/FunLib/utils.lua
  - bots/FunLib/aba_push.lua
  - bots/FunLib/aba_defend.lua
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/42'
priority: low
ordinal: 33000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upstream feature request 42: humans playing with bots want to steer them with pings (push, defend, kill a hero, Roshan, Tormentor, ward, retreat, farm). Ping handling already exists for push, defend and assemble (utils IsPingedByAnyPlayer / GetHumanPing). A user also found that pinging near a support bot stops it taking last hits for a moment. Captain's Mode with a bot captain ignores lane commands (comment on issue 42).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Pings for kill-target, Roshan/Tormentor and retreat are acted on by nearby bots
- [ ] #2 Ping handling is documented in Customize/general.lua or the README
<!-- AC:END -->
