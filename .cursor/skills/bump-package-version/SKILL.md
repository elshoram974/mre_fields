---
name: bump-package-version
description: >-
  Bumps mre_fields pubspec version and updates CHANGELOG.md (Keep a Changelog).
  Use when releasing, publishing, or the user asks to cut a version.
---

# Bump package version

## Steps

1. Read current `version:` in `pubspec.yaml`.
2. Choose bump:
   - **patch** — fix / docs / non-API
   - **minor** — new field / theme token (0.x or 1.x compatible)
   - **major** — breaking public API (required at 1.x+; note clearly while 0.x)
3. Update `pubspec.yaml`.
4. Update `CHANGELOG.md`:
   - Move `[Unreleased]` notes under `## [x.y.z] - YYYY-MM-DD`
   - List Added / Changed / Fixed / Breaking
5. Ensure analyze + tests pass.
6. Do **not** publish to pub.dev unless the user explicitly asks.

## Commit message shape

```
chore(release): mre_fields x.y.z

- summary of what this version delivers

Co-Authored-By: Mohammed El Shora <riyadm2001@gmail.com>
```
