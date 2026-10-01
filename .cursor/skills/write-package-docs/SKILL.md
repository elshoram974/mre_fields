---
name: write-package-docs
description: >-
  Writes the public documentation for mre_fields: dartdoc, README feature
  sections with runnable snippets, example app pages, and a clean pub.dev
  archive. Use when documenting a feature, preparing a release, or the user asks
  for docs/examples.
---

# Package documentation pass

Read `.cursor/rules/docs-and-examples.mdc`. Companion skills: `dart-write-documentation`, `dartdoc-conventions`, `dart-use-doc-examples`, `add-example-app`.

## Steps

1. List the public symbols from `lib/mre_fields.dart`; each needs `///` with summary, behaviour, and a compiling snippet.
2. Update README sections for any feature touched. Every snippet must be copy-paste runnable and appear in `example/` too (same code, one source of truth).
3. Add or update the example page for the feature: default usage and a customized variant side by side.
4. Platform notes: record what works where (paste image, keyboard images, desktop shortcuts).
5. Neutral wording check:
   ```bash
   rg -n -i "claude|cursor|agent|copilot|llm|prompt engineer" README.md CHANGELOG.md lib example --glob '!*.lock'
   ```
   Matches must be only legitimate product meaning, never tooling notes.
6. Archive check: `flutter pub publish --dry-run` — confirm `.pubignore` excludes `.cursor/`, `.claude/`, `.agents/`, `AGENTS.md`, `CLAUDE.md`, `ROADMAP.md`.
7. `dart doc` runs clean (no unresolved references).
