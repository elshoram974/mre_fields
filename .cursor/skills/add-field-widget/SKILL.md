---
name: add-field-widget
description: >-
  Adds a new public field widget to mre_fields (layout under lib/src, theme
  tokens, barrel export, tests, changelog). Use when creating MrePhoneField,
  extending MreTextField, or adding another Mre* form field.
---

# Add a field widget

## Checklist

1. Confirm it belongs here (input behaviour) — not CashBook domain UI.
2. Place under `lib/src/<area>/mre_<name>_field.dart` (or picker/helper sibling).
3. Prefix public type with `Mre`.
4. Prefer composition: `MrePhoneField` builds on `MreTextField` rather than forking.
5. Theme knobs shared by ≥2 call sites → `MreFieldsTheme`; one-off → constructor param.
6. All user-visible strings are parameters (no `.tr()`).
7. Export from `lib/mre_fields.dart`.
8. Dartdoc on the public class: one-line summary + short usage sample.
9. Tests under `test/` mirroring `lib/src/`.
10. `CHANGELOG.md` + version bump if releasing.
11. `flutter analyze` + `flutter test`.

## Minimal usage sample (put in dartdoc)

```dart
MreTextField(
  controller: controller,
  hintText: 'Name', // host already translated
  showClearButton: true,
)
```

## After the first consumer (CashBook)

Document the path dependency snippet in README if not already present. Do not
auto-edit the ledger repo unless the user asks.
