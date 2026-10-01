# mre_fields

Reusable Flutter **form field widgets** for MRE apps — bidirectional text, phone
with country code, and suggestion chips.

First consumer: [MRE CashBook](../ledger). Host apps own branding, copy, and
navigation; this package owns **input behaviour**.

## Contents

- [Status](#status)
- [Planned surface](#planned-surface)
- [Theming](#theming) — guide: [doc/theme.md](doc/theme.md)
- [Use from CashBook](#use-from-cashbook-path)
- [Development](#development)

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

Fields take colors, typography and input chrome from your own `ThemeData`.
Register `MREFieldsTheme` on the same theme to tune radius, padding,
breakpoints and texts:

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: hostScheme,
    inputDecorationTheme: hostInputs,
    extensions: const [
      MREFieldsTheme(
        fieldBorderRadius: 16,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        expandedContentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        strings: MREFieldsStrings(clearTooltip: 'Clear'),
      ),
    ],
  ),
  home: const HomePage(),
);
```

Precedence: widget parameter, then `MREFieldsTheme`, then the built-in default.
Without a registered extension, `MREFieldsTheme.defaults` applies.

Localization: pass your translated texts through `MREFieldsStrings`. The
package ships English defaults only.

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
