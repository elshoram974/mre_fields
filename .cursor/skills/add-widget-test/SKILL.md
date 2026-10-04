---
name: add-widget-test
description: >-
  Writes flutter_test widget tests for MRETextField, MREPhoneField, and related
  pickers. Use when adding or changing field widgets, BIDI behaviour,
  suggestions, or phone parsing UI.
---

# Widget tests for mre_fields

## Layout

Mirror `lib/src/`:

- `lib/src/text/field/mre_text_field.dart` → `test/src/text/field/mre_text_field_test.dart`

## Harness

Wrap with enough theme to resolve `MREFieldsTheme` and Material:

```dart
Widget wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: const [MREFieldsTheme()],
    ),
    home: Scaffold(body: child),
  );
}
```

## What to assert

| Widget | Cases |
|---|---|
| `MRETextField` | types Arabic → RTL alignment; clear button; suggestions appear on focus; `textDirection` override sticks |
| `MREPhoneField` | dial + local; parse pasted `+20…`; trunk zero stripped after dial |
| Country picker | search filters; selecting a dial calls `onChanged` |

## Commands

```bash
flutter test
flutter test test/src/text/mre_text_field_test.dart
```

Prefer `find.byType` / keys you add for the inner `TextField` or public form state over brittle text-only finds when labels are host-provided.

Use ordinary fields for input behavior/performance tests and form variants for
validation/save/reset. Include Unicode-wide direction samples, not just two
languages, and verify readOnly/enabled on every secondary mutation control.
