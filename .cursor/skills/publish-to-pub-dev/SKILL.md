---
name: publish-to-pub-dev
description: >-
  Prepares and publishes mre_fields to pub.dev (version, changelog, dry-run,
  publish). Use when the user asks to publish, release to pub.dev, or upload
  the package.
---

# Publish mre_fields to pub.dev

## Before anything

1. Confirm the user **explicitly** asked to publish (do not publish unprompted).
2. Read current `version` in `pubspec.yaml` and `[Unreleased]` / latest in `CHANGELOG.md`.
3. Gate:
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   flutter pub publish --dry-run
   ```
4. Fix dry-run warnings (missing homepage/repository, README, license, etc.).

## pubspec fields for pub.dev

Ensure something like:

```yaml
name: mre_fields
description: >-
  Reusable Flutter form field widgets — bidirectional text, phone with country
  code, and suggestions.
version: x.y.z
homepage: https://github.com/<org>/mre_fields   # or real URL
repository: https://github.com/<org>/mre_fields
issue_tracker: https://github.com/<org>/mre_fields/issues
```

`LICENSE` must be present (already). README must describe features + usage.

## Non-code checklist (do before the first publish)

Account and ownership
- [ ] A Google account signed in at pub.dev; `dart pub publish` opens the browser login once.
- [ ] Package name free: `mre_fields` returned 404 on pub.dev on 2026-10-01 (re-check right before publishing).
- [ ] Optional but recommended: a **verified publisher** (a domain you own, verified through Google Search Console) so the package shows a verified badge and is not tied to one personal account. Create it at pub.dev → Publishers, then transfer the package.
- [ ] A first publish is permanent for that version: a version can be retracted within 7 days, never deleted. Run the dry-run and read the file list first.

Legal and repository
- [x] `LICENSE` is BSD-3-Clause, Copyright (c) 2026 Mohammed Riyad El Shora (done). Keep the year and holder in sync if either changes.
- [ ] Public GitHub repository; `pubspec.yaml` has `repository:` and `issue_tracker:` (homepage optional). `origin` currently points at github.com/elshoram974/mre_fields.
- [ ] Push a tag per release (`v0.1.0`). Optional: automated publishing from GitHub Actions (pub.dev package → Admin → Automated publishing, tag pattern `v{{version}}`), which removes the need for a local token.

Package metadata (`pubspec.yaml`)
- [ ] `description` 60–180 characters, plain wording (now 112).
- [ ] `topics:` up to 5 (for search), `screenshots:` (png/jpg/webp/gif, ≤ 4 MB each) with captions, `funding:` if wanted.
- [ ] Declare `platforms:` only if you must restrict; otherwise pub infers them from imports.
- [ ] First public version `0.1.0` (not `0.0.1`) once `MRETextField` ships; version and CHANGELOG entry match.

Content that earns score (pana, 160 points)
- [ ] README: what it is, install, quick start, one snippet per feature, screenshots with absolute URLs.
- [ ] CHANGELOG has an entry for the exact version being published.
- [ ] `example/` runs and is referenced in the README (pub.dev shows it on the Example tab).
- [ ] Dartdoc on 100% of public API (`public_member_api_docs` lint on); `dart doc` has no warnings.
- [ ] `dart analyze` clean; dependencies up to date (`flutter pub outdated`) and supported by the declared SDK range.
- [ ] Run the scorer locally: `dart pub global activate pana && pana .` — fix anything below full points.

Archive hygiene
- [ ] `.pubignore` keeps `.cursor/`, `.claude/`, `.agents/`, `AGENTS.md`, `CLAUDE.md`, `ROADMAP.md` out; confirm with `flutter pub publish --dry-run` (only `lib/`, `example/`, `test/`, README, CHANGELOG, LICENSE, pubspec, analysis options).
- [ ] No secrets, no large assets, no `.widget_preview/`, no build output.

## Version

Use skill `bump-package-version` if needed. SemVer; while `0.x` breaking is ok if listed under Breaking in CHANGELOG.

## Publish

```bash
flutter pub publish --dry-run   # must be clean
flutter pub publish             # only after user confirms
```

Login: `dart pub token` / browser flow as pub.dev prompts. Do not commit secrets.

## After publish

- Tag git: `vX.Y.Z` (if user wants).
- Point CashBook at the published version when they leave path dependency:
  ```yaml
  mre_fields: ^x.y.z
  ```

## Do not

- Publish from a dirty tree with unrelated WIP
- Skip dry-run
- Force publish with `--force` unless user asks and understands warnings
