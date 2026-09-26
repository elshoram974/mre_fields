---
name: add-widget-test
description: >-
  Writes flutter_test widget tests for MreTextField, MrePhoneField, and related
  pickers. Use when adding or changing field widgets, BIDI behaviour,
  suggestions, or phone parsing UI.
---

# Widget tests for mre_fields

## Layout

Mirror `lib/src/`:

- `lib/src/text/mre_text_field.dart` → `test/src/text/mre_text_field_test.dart`

## Harness

Wrap with enough theme to resolve `MreFieldsTheme` and Material:

```dart
Widget wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: const [MreFieldsTheme()],
    ),
    home: Scaffold(body: child),
  );
}
```

## What to assert

| Widget | Cases |
|---|---|
| `MreTextField` | types Arabic → RTL alignment; clear button; suggestions appear on focus; `textDirection` override sticks |
| `MrePhoneField` | dial + local; parse pasted `+20…`; trunk zero stripped after dial |
| Country picker | search filters; selecting a dial calls `onChanged` |

## Commands

```bash
flutter test
flutter test test/src/text/mre_text_field_test.dart
```

Prefer `find.byType` / keys you add for the inner `TextFormField` over brittle text-only finds when labels are host-provided.
