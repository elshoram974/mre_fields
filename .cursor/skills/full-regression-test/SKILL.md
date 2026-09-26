---
name: full-regression-test
description: >-
  Runs the full mre_fields regression gate (pub get, analyze, test, optional
  widget preview). Use before declaring a field feature done, before a version
  bump, or when the user asks to run full tests / regression.
---

# Full regression test

## Gate (required)

```bash
flutter pub get
flutter analyze
flutter test
```

Exit non-zero → fix before claiming done. New analyzer infos/warnings are regressions.

## When UI changed

Also exercise sizes / RTL / text scale (see `.cursor/rules/test-field-sizes.mdc`) and open previews:

```bash
flutter widget-preview start
```

Or IDE: **Flutter Widget Preview** panel.

## Report back

- Analyze clean? (yes / list new issues)
- Tests: N passed / failures
- Previews checked? (which)
- Sizes covered? (phone / tablet / RTL / textScale)
- Flutter SDK: output of `flutter --version` (first line) if relevant

## Do not

- Skip because “only docs”
- Format the entire package tree
- Add or use FVM in this repo
