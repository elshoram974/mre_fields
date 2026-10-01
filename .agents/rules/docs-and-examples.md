---
description: Public docs — dartdoc, README, runnable examples covering every feature, neutral product tone
globs: "lib/**/*.dart,README.md,example/**,CHANGELOG.md"
alwaysApply: true
---
# Documentation & examples

pub.dev readers see only what ships in the package. Write for a Flutter developer evaluating the package.

## Dartdoc

- Every public symbol has `///` docs: one-sentence summary, then behaviour, then a short sample. Follow `dart-write-documentation` and `dartdoc-conventions` skills.
- Use `{@tool snippet}` / fenced `dart` blocks that compile. Prefer `dart-use-doc-examples` for sourcing them.
- State precedence where it matters: parameter → `MREFieldsTheme` → Material default.
- No internal process talk in dartdoc, README, CHANGELOG or example code (no tool names, no agent/workflow notes, no TODO addressed to a tool).

## README (package root)

Sections, in order: what it is · install · 30-second quick start · feature list with one runnable snippet each (BIDI field, clear/suggestions, phone + country include/exclude, image paste behaviours, text direction extensions, theming) · customization (theme extension, overrides, using single pieces) · platform notes (paste support matrix) · FAQ · contributing.

Keep contributor/agent tooling notes out of the README; they live in `CLAUDE.md`, `AGENTS.md`, `.cursor/`.

## Example app (`example/`)

One page per feature group, each showing **default** and **customized** usage: text direction, suggestions, phone (all countries / include / exclude), image paste (none / callback / attachments), theming + dark, compact vs expanded window. Plain English strings. Must run with `flutter run` on mobile, desktop and web.

## CHANGELOG

Keep a Changelog. User-facing wording: what changed for someone upgrading, not how it was built.

## Pre-publish gate

`flutter pub publish --dry-run` must show only the intended files — confirm `.pubignore` keeps `.cursor/`, `.claude/`, `.agents/`, `AGENTS.md`, `CLAUDE.md`, `ROADMAP.md` out of the archive.
