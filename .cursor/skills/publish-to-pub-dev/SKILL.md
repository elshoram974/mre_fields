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
