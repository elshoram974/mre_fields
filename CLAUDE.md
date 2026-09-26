# mre_fields

Reusable Flutter **form field widgets** for MRE apps. First consumer: MRE CashBook
(`ledger`). Second consumer may come later — design the public API as if it will.

This file is the source of truth for agents and humans. Cursor rules under
`.cursor/rules/` reinforce the parts that break most often. Skills under
`.cursor/skills/` are step-by-step workflows.

## What this package is

| In scope | Out of scope |
|---|---|
| `MreTextField` — BIDI direction, clear, select-on-focus, suggestion chips | CashBook `CustomFieldRegistry` / book field types |
| `MrePhoneField` — dial code + local number, parse/format helpers | Contact picker, device contacts DB |
| Country dial-code picker UI (package-owned, no app routing) | `go_router`, app routes, `safePop` |
| `MreFieldsTheme` (`ThemeExtension`) for radii / paddings / defaults | Hard-coded CashBook `AppSizes` / `AppColorsExtension` |
| Pure validators / formatters the fields need | `.tr()` localization — host app passes already-translated strings |
| Widget + unit tests for public behaviour | Glass iOS chrome, adaptive overlays from CashBook |

Host apps own branding, copy, and navigation. This package owns **input behaviour**.

## Reference implementation (port source)

Do **not** invent the field from scratch. Port behaviour from CashBook, then
strip app coupling:

| Ledger path | Becomes in `mre_fields` |
|---|---|
| `lib/core/widgets/app_text_field.dart` | `lib/src/text/mre_text_field.dart` |
| `lib/core/utils/extensions/string_extension.dart` → `uiTextDirection` / `textDirection` / `safeDisplayText` | `lib/src/text/text_direction.dart` (BIDI only — **not** `pdfReshaped`) |
| `lib/core/utils/helpers/safe_text_controller.dart` | `lib/src/text/safe_text_controller.dart` (if still needed) |
| `lib/core/utils/helpers/phone_number_helper.dart` | `lib/src/phone/phone_number.dart` |
| `lib/core/constants/countries.dart` (+ dial data) | `lib/src/phone/countries.dart` |
| `lib/core/widgets/app_country_code_picker.dart` | `lib/src/phone/mre_country_code_picker.dart` — rewrite sheet without `AdaptiveOverlays` / `.tr()` / `AppGlassSurface` |

Ledger path (absolute, for agents working from another workspace):

`/Users/mohammedelshora/Desktop/Shora/projects/mrecode/ledger/`

When porting: copy behaviour and tests of behaviour, rename `App*` → `Mre*`,
replace theme reads with `MreFieldsTheme.of(context)` + `Theme.of(context)`,
delete every import into CashBook (`app_sizes`, `context.colors`, `.tr()`,
`go_router`, blocs, prefs).

## Public API shape

```text
lib/
  mre_fields.dart          # barrel — export only the public surface
  src/
    theme/
      mre_fields_theme.dart
    text/
      mre_text_field.dart
      text_direction.dart
    phone/
      mre_phone_field.dart
      mre_country_code_picker.dart
      phone_number.dart
      countries.dart
```

- One barrel: `package:mre_fields/mre_fields.dart`.
- Nothing under `src/` is imported by apps directly.
- Breaking public API → bump **major** (once past `1.0.0`) or document in
  `CHANGELOG.md` while still `0.x`.

### Theming (not global `initialize`)

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      MreFieldsTheme(
        // radii, contentPadding, suggestion chip style tokens…
      ),
    ],
  ),
  // …
);
```

Widget constructor params override the theme for that instance. Prefer
`ThemeExtension` over a mutable static `MreFields.initialize(...)`.

Colors: use `Theme.of(context).colorScheme` / `textTheme` / `InputDecorationTheme`.
Optional extra tokens go on `MreFieldsTheme` — never import CashBook colors.

### Localization

All user-visible strings are **parameters** (`hintText`, `labelText`,
`searchHint`, empty-state copy for the country sheet). The package never calls
`.tr()` and never ships translation maps.

### Country picker

Own a simple modal/bottom sheet inside the package (Material). Do not depend on
CashBook `AdaptiveOverlays`. Host can wrap later if it wants glass.

## Code quality

- Clean, small public classes. No god-widgets: split private state helpers.
- No magic numbers in widgets — name them on `MreFieldsTheme` or as named consts
  on the widget file.
- No `print`. Log nothing unless the host injects a logger (default: silent).
- No silent `catch (_) {}` on parse paths — return a clear empty / invalid result.
- `dart format` only on files you edited.
- Before done: `dart analyze` (or `flutter analyze`) — new infos/warnings are
  regressions.
- Report every deletion of working behaviour under **⚠️ Removed**
  (Replaced / Dropped / Dead) — same bar as CashBook.

## Flutter SDK

- **No FVM.** Use `flutter` / `dart` on PATH (stable).
- Widget Previewer needs 3.38+; developing on latest stable (e.g. 3.47.x) is fine.
- Rule: `.cursor/rules/flutter-version.mdc`.

## Tests & regression

Gate before done / release (skill: `full-regression-test`):

```bash
flutter pub get
flutter analyze
flutter test
```

- Unit: phone parse/format, BIDI helpers, validators.
- Widget: `MreTextField` direction flip while typing, suggestions, clear,
  `MrePhoneField` dial + local.
- Sizes / RTL / text scale / dark: `.cursor/rules/test-field-sizes.mdc`.
- Full gate notes: `.cursor/rules/full-regression.mdc`.
- Mirror `lib/` under `test/`.

## Widget Preview

- Flutter Widget Previewer (`@Preview` from `package:flutter/widget_previews.dart`).
- Shared harness: `lib/src/previews/preview_harness.dart`.
- Skill: `add-widget-preview`.
- Launch: `flutter widget-preview start` or IDE **Flutter Widget Preview** panel.
- Do not export preview files from the public barrel.

## Versioning & changelog

- SemVer. While `0.x`, breaking changes are allowed but **must** be listed in
  `CHANGELOG.md`.
- Every publishable change updates `CHANGELOG.md` (Keep a Changelog style).
- Bump `pubspec.yaml` `version` in the same commit as the API/behaviour change.

## Git commits

Conventional Commits:

```
feat(text): add live BIDI detection to MreTextField

- port detection from ledger AppTextField
- drive alignment from detected direction unless overridden

Co-Authored-By: Mohammed El Shora <riyadm2001@gmail.com>
```

Title ≤72 chars, imperative, blank line, bullets for what/why. Always end with
the co-author trailer (see `.cursor/skills/commit-with-coauthor`).

## Consuming from CashBook later

Path dependency while iterating:

```yaml
# ledger/pubspec.yaml
dependencies:
  mre_fields:
    path: ../mre_fields
```

Then replace `AppTextField` call sites gradually with `MreTextField` (or a thin
CashBook wrapper that forwards `.tr()` hints). Do not move `CustomFieldRegistry`
into this package.

## Agent map

| Need | Open |
|---|---|
| Always-on standards | `.cursor/rules/project-standards.mdc` |
| Public API / barrel / naming | `.cursor/rules/package-api.mdc` |
| Theme + no app colors | `.cursor/rules/theming.mdc` |
| What to copy from ledger | `.cursor/rules/port-from-ledger.mdc` |
| Port a widget step-by-step | `.cursor/skills/port-field-from-ledger` |
| Add a new field type | `.cursor/skills/add-field-widget` |
| Version bump + changelog | `.cursor/skills/bump-package-version` |
| Commit trailer | `.cursor/skills/commit-with-coauthor` |
| Full test gate | `.cursor/skills/full-regression-test` |
| Widget previews | `.cursor/skills/add-widget-preview` |
| Flutter SDK | `.cursor/rules/flutter-version.mdc` (no FVM) |
