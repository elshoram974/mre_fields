---
name: add-example-app
description: >-
  Creates or updates the example/ Flutter app that demos MreTextField,
  MrePhoneField, theming overrides, and composable pieces. Use when the user
  asks for examples, example app, or a runnable demo.
---

# Example app (`example/`)

## Why

- Widget Previewer = quick cards in IDE.
- **`example/`** = real app you run on simulator/device (theme toggle, phone flow, overrides).

## Create (once)

```bash
cd /path/to/mre_fields
flutter create example --template=app --org net.mrecode
```

In `example/pubspec.yaml`:

```yaml
dependencies:
  mre_fields:
    path: ../
```

## What to show (minimum)

1. Host `ThemeData` + `MreFieldsTheme` (light/dark toggle).
2. `MreTextField` — empty, suggestions, Arabic BIDI.
3. Constructor overrides (custom padding / decoration) vs theme defaults.
4. When ready: `MrePhoneField` + country picker.
5. Optional screen: compose pieces only (suggestion bar / clear) without full field — proves extensibility.

## Rules

- Example strings can be English literals (package has no `.tr()`).
- Do not import CashBook.
- Keep example thin — no copy of package internals.
- After adding: note in README “Run the example” section.

## Run

```bash
cd example
flutter run
```
