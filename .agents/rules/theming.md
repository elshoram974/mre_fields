---
description: MreFieldsTheme + Material Theme — no AppColors / AppSizes / global initialize
globs: "lib/**/*.dart"
alwaysApply: false
---
# Theming

## Rules

- Read sizes/radii/paddings from `MreFieldsTheme` (`ThemeExtension`).
- Read colors/typography from `Theme.of(context)` (`colorScheme`, `textTheme`, `inputDecorationTheme`).
- Widget params override theme for that instance.
- **Do not** add `MreFields.initialize(...)` mutable globals — hosts wire theme once on `MaterialApp`.
- **Do not** import CashBook `AppSizes`, `AppColorsExtension`, or `context.colors`.

## Host wiring (document in README / dartdoc)

```dart
theme: ThemeData(
  extensions: [
    MreFieldsTheme(
      fieldBorderRadius: 12,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  ],
),
```

## Optional tokens

Only add a theme field when a second call site needs the same knob. One-off → constructor param.
