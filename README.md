# mre_fields

Reusable Flutter **form field widgets** for MRE apps — bidirectional text, phone
with country code, and suggestion chips.

First consumer: [MRE CashBook](../ledger). Host apps own branding, copy, and
navigation; this package owns **input behaviour**.

## Status

Early (`0.x`). Public API may change; see `CHANGELOG.md`.

## Planned surface

| Widget / type | Role |
|---|---|
| `MreTextField` | Text field with live BIDI, clear, select-on-focus, suggestions |
| `MrePhoneField` | Dial code + local number |
| `MreCountryCodePicker` | Searchable dial-code sheet |
| `MreFieldsTheme` | `ThemeExtension` for radii / paddings / shared tokens |

## Theming

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      MreFieldsTheme(
        // fieldBorderRadius, contentPadding, …
      ),
    ],
  ),
  home: /* … */,
);
```

Colors and typography come from Material `Theme`. Pass already-translated
strings into `hintText` / `labelText` — the package does not ship `.tr()`.

## Use from CashBook (path)

```yaml
# ledger/pubspec.yaml
dependencies:
  mre_fields:
    path: ../mre_fields
```

## Agents / contributors

- **Source of truth:** [`CLAUDE.md`](./CLAUDE.md)
- **Cursor rules:** `.cursor/rules/`
- **Skills:** `.cursor/skills/` (port from ledger, add field, tests, release, co-author commits)

## Development

No FVM — use the Flutter SDK on your PATH (stable, 3.38+):

```bash
flutter pub get
flutter analyze
flutter test
flutter widget-preview start   # IDE: Flutter Widget Preview panel
```

Regression expectations: `.cursor/rules/full-regression.mdc` and `test-field-sizes.mdc`.
