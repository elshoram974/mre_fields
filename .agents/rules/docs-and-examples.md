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

## How the docs link together

- **Barrel library doc** (`lib/mre_fields.dart`): overview, quick start, one bullet per topic listing its public types with `[Type]` links.
- **Categories**: every public type carries `{@category Name}`; each category has a guide `doc/<name>.md` registered in `dartdoc_options.yaml` (`categoryOrder` keeps the order). Add the category and its guide in the same change that ships the feature.
- **Guides** (`doc/*.md`): task-oriented text. `[Type]` references do not resolve there, so use backticked names; the category page lists the linked members below the guide.
- **Examples are real code.** Every example lives in `doc/snippets/<topic>.dart` between `#region name` / `#endregion name`, is analyzed with the package, and is run by a widget test in `test/doc/`. Class dartdoc embeds it with `{@example /doc/snippets/<topic>.dart#name}`.
- `{@example}` is **not** expanded inside `doc/*.md` guides. Their code blocks are copies; `test/doc/<topic>_guide_sync_test.dart` fails when a copy differs from its snippet. Regenerate the blocks from the snippet file, never edit them by hand.
- Show the change a user would make (global theme, one value, dark mode, per widget, localization), not a description of it. One short sentence of text per example; no background talk.
- Do not document a parameter or widget that does not exist yet.
- **Class docs** end with `See also:` bullets linking related types, and point back to the guide topic when one exists.
- **README** has a Contents list, short snippets per feature, and links to `doc/` guides, `example/`, and (after the first release) the pub.dev API reference. Do not ship the API link before the package is published.
- **CHANGELOG** entries name the public symbols they touch, in backticks.
- `public_member_api_docs` is enabled: an undocumented public member fails `flutter analyze`.
- Gate: `dart doc .` must finish with 0 warnings.

## What pub.dev shows

- **Example tab**: the first existing file of `example/example.md`, `example[/lib]/main.dart`, … `example/README.md`. `example/example.md` wins, so write it: a walkthrough with a short sentence and a tested snippet per feature. A bare `main.dart` shows three useless lines.
- **README tab**: the README with images. Images need absolute URLs (`https://raw.githubusercontent.com/<owner>/<repo>/main/…`).
- **API reference**: the barrel's library doc is the landing page; keep it a short map with links to the guides.
- **Scores tab**: run `dart pub global run pana --no-warning .` before every release; the target is 160/160.
- README and `example/example.md` use `<!-- snippet: topic/region -->` markers. `tool/sync_doc_snippets.dart` fills them and `doc_guides_sync_test.dart` fails on drift.

## README (package root)

Sections, in order: title with badges and the demo GIF · one-paragraph pitch · why use it (4–5 bullets) · install · quick start (numbered, three steps) · "what you can do" table (need → API → guide) · customization · platform support table · short FAQ · documentation links · contributing · license. Short sentences, no process talk, every snippet synced from `doc/snippets`.

Keep contributor/agent tooling notes out of the README; they live in `CLAUDE.md`, `AGENTS.md`, `.cursor/`.

## Example app (`example/`)

One page per feature group, each showing **default** and **customized** usage: text direction, suggestions, phone (all countries / include / exclude), image paste (none / callback / attachments), theming + dark, compact vs expanded window. Plain English strings. Must run with `flutter run` on mobile, desktop and web.

## CHANGELOG

Keep a Changelog. User-facing wording: what changed for someone upgrading, not how it was built.

## Pre-publish gate

`flutter pub publish --dry-run` must show only the intended files — confirm `.pubignore` keeps `.cursor/`, `.claude/`, `.agents/`, `AGENTS.md`, `CLAUDE.md`, `ROADMAP.md` out of the archive.
