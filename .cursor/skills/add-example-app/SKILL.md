---
name: add-example-app
description: >-
  Creates or updates the example/ Flutter app that demos MRETextField,
  MREPhoneField, theming overrides, and composable pieces. Use when the user
  asks for examples, example app, or a runnable demo.
---

# Example app (`example/`)

## Why

- Widget Previewer = quick cards in IDE.
- **`example/`** = real app you run on simulator/device (theme toggle, phone flow, overrides).

## What exists

`example/` is a Flutter app for every platform (`flutter create example --org net.mrecode --project-name mre_fields_example`), depending on the package by `path: ../`.

```text
example/lib/
  main.dart, app.dart          # registers MREFieldsTheme on light and dark, like a host app
  example_settings.dart        # theme mode, language, radius (ChangeNotifier)
  pages/home_page.dart         # one card per feature
  sections/                    # direction, field, image paste, theme sections
  demos/                       # clean pages for the GIFs (?demo=text, ?demo=paste)
example/test/example_test.dart # smoke tests
```

## Add a feature to the example

1. Add `sections/<feature>_section.dart` (a `SectionCard` with default and customized usage) and list it in `home_page.dart`.
2. Plain English literals; no ARB. A language toggle already swaps `MREFieldsStrings`.
3. If the feature deserves a GIF, add a demo page (skill `record-demo-gifs`).
4. `cd example && flutter analyze && flutter test`.

## Rules

- Example code follows the same clean-code and structure rules as `lib/`.
- Every platform must build (`flutter build web|apk|ios|macos|linux|windows`); CI does all of them.
- Do not import CashBook or anything outside `package:mre_fields/mre_fields.dart`.

## Run

```bash
cd example
flutter run
```
