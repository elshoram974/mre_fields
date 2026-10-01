---
description: MREFieldsTheme + host Material Theme — colors from the app, tokens from extension, params override
globs: "lib/**/*.dart"
alwaysApply: true
---
# Theming

See also **extensibility.mdc** (always on).

## Rules

- **Colors / type / input chrome:** `Theme.of(context)` — `colorScheme`, `textTheme`, `inputDecorationTheme`. Host “inits” by using their normal `ThemeData`; we inherit it.
- **Field tokens (radius, padding, gaps):** `MREFieldsTheme` as `ThemeExtension`, registered next to the host theme:
  ```dart
  theme: ThemeData(
    colorScheme: hostScheme,
    inputDecorationTheme: hostInputs,
    extensions: [
      MREFieldsTheme(
        fieldBorderRadius: 12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ],
  ),
  ```
- Widget constructor params **override** `MREFieldsTheme` for that instance.
- Sensible const defaults when the extension is missing (previews / quick demos).
- **Do not** add mutable `MREFields.initialize(...)`.
- **Do not** import CashBook `AppSizes` / `AppColorsExtension` / `context.colors`.

## Optional helpers

- A factory like `MREFieldsTheme.defaults` or `MREFieldsTheme.fromColorScheme` is fine if it only derives package tokens — never replaces the host `ThemeData`.

## Optional tokens

Add a theme field when ≥2 widgets share the knob, or when hosts will theme it globally. One-off → constructor param (still prefer exposing it).
