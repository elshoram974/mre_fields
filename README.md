# mre_fields

Reusable Flutter **form field widgets** for MRE apps — bidirectional text, phone
with country code, and suggestion chips.

First consumer: [MRE CashBook](../ledger). Host apps own branding, copy, and
navigation; this package owns **input behaviour**.

## Status

Early (`0.x`). Public API may change; see `CHANGELOG.md`.

**What to build next:** see [`ROADMAP.md`](./ROADMAP.md) (steps 1→8 with a plan for each).

Open this folder as the Cursor workspace so agents load `CLAUDE.md` / rules automatically.

### Try widgets
- **Preview:** Flutter Widget Preview panel, or `flutter widget-preview start`
- **Example app:** (after it exists) `cd example && flutter run` — skill `add-example-app`
- **Publish:** skill `publish-to-pub-dev` → `flutter pub publish --dry-run` then publish

## Planned surface

| Widget / type | Role |
|---|---|
| `MRETextField` | Text field with live BIDI, clear, select-on-focus, suggestions |
| `MREPhoneField` | Dial code + local number |
| `MRECountryCodePicker` | Searchable dial-code sheet |
| `MREFieldsTheme` | `ThemeExtension` for radii / paddings / shared tokens |

## Theming

Plug into the **host** theme — we take their colors; they add field tokens:

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: hostScheme,
    inputDecorationTheme: hostInputs,
    extensions: const [
      MREFieldsTheme(
        // fieldBorderRadius, contentPadding, …
      ),
    ],
  ),
  home: /* … */,
);
```

Per-widget constructor params override the extension. Pieces (helpers, bars,
pickers) can be used without taking the full field widgets — see
`.cursor/rules/extensibility.mdc`.

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
