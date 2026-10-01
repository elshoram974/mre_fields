---
description: Third-party baseline clean-code rules (clean-principles, MIT). clean-code.mdc adapts them to Dart and wins on conflicts
globs: "*"
alwaysApply: true
---
<!-- Source: https://github.com/Khuirul-Huda/clean-principles (MIT), commit 846c4f0, rules/core-principles.md. Copied unmodified below the marker. -->

# Clean Principles — Core Rules

These rules are always active. They form the baseline coding standards for every task.

## Naming

- Use **intention-revealing names**: `elapsedDays` not `d`, `isUserActive` not `flag`
- Functions = **verb phrases** (`calculateTotal`, `sendEmail`)
- Classes = **noun phrases** (`UserAccount`, `OrderProcessor`)
- No abbreviations unless universally known (`url`, `id`, `api` are fine; `usrActFlg` is not)

## Functions & Methods

- **One responsibility** per function — if you need "and" to describe it, split it
- **≤ 3 parameters** — more means you need a parameter object
- **No flag arguments** — `process(true)` tells nothing; use two named functions
- Keep functions **small** — if it doesn't fit on screen, it probably does too much

## Code Quality

- **No magic numbers** — extract to named constants (`MAX_RETRIES = 3` not `3`)
- **No commented-out code** — delete it; git has history
- **Comments explain WHY**, not WHAT — the code is the what
- **No `null`/`None` returns** from functions that return collections — return empty collection
- **Catch specific exceptions** — never bare `except:` / `catch (Exception e)`

## Design

- **DRY**: Don't duplicate business logic — one source of truth per rule
- **YAGNI**: Don't build features nobody asked for yet
- **KISS**: Prefer the simple solution — complexity needs justification
- **SRP**: Each class/module has one reason to change

## Before Every Commit

Ask yourself:
1. Can I explain what each function does in one sentence?
2. Would a new team member understand this without asking me?
3. Is there any dead code, commented code, or `TODO` older than this PR?
