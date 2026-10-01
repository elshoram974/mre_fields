---
name: add-widget-preview
description: >-
  Adds Flutter Widget Previewer (@Preview) cards for MRETextField, MREPhoneField,
  and related UI. Use when the user asks for previews, widget preview, or visual
  sandbox for field widgets.
---

# Add widget previews (mre_fields)

Requires Flutter **3.38+** on PATH (no FVM in this repo).

## Rules

- Import `package:flutter/widget_previews.dart`.
- Targets: top-level functions / static methods / public constructors with **no required args** returning `Widget` or `WidgetBuilder`.
- Put shared harness in `lib/src/previews/preview_harness.dart` (theme + `MREFieldsTheme`).
- Put field previews next to the widget or under `lib/src/previews/` (e.g. `mre_text_field_previews.dart`).
- No `dart:io` / native plugins in preview code paths.
- Pass **literal English** strings in previews (package has no `.tr()`).
- Multiple configs: several `@Preview`s or a small `MultiPreview` subclass (light/dark, LTR/RTL).

## Checklist

- [ ] Harness wraps `MaterialApp`/`Theme` with `MREFieldsTheme`
- [ ] Preview for empty + filled text field
- [ ] Preview with Arabic text (RTL BIDI)
- [ ] Preview phone field (once it exists)
- [ ] Light + dark (brightness) where useful
- [ ] Open with `flutter widget-preview start` or IDE panel

## Launch

```bash
flutter widget-preview start
```

IDE (Flutter 3.38+): open **Flutter Widget Preview**; optionally filter by selected file.

## Do not

- Preview CashBook screens here
- Depend on ledger packages inside preview files
- Use unconstrained widgets without a `size:` on `@Preview` when they would expand infinitely
- Introduce FVM
