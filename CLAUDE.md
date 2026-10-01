# mre_fields

Reusable Flutter **form field widgets** for MRE apps. First consumer: MRE CashBook
(`ledger`). Second consumer may come later — design the public API as if it will.

This file is the source of truth for agents and humans. Cursor rules under
`.cursor/rules/` reinforce the parts that break most often. Skills under
`.cursor/skills/` are step-by-step workflows.

**Implementation plan (steps + per-step checklist):** [`ROADMAP.md`](./ROADMAP.md)

## What this package is

| In scope | Out of scope |
|---|---|
| `MRETextField` — BIDI direction, clear, select-on-focus, suggestion chips, optional image paste | CashBook `CustomFieldRegistry` / book field types |
| Text direction helpers — `String` / `Text` / widget extensions (usable without the field) | State-management packages (Riverpod, Bloc, …) |
| `MREPhoneField` — dial code + local number, parse/format/validate for all countries, include/exclude country lists | Contact picker, device contacts DB |
| Country dial-code picker UI (package-owned, no app routing) | `go_router`, app routes, `safePop` |
| `MREFieldsTheme` (`ThemeExtension`) for radii / paddings / defaults | Hard-coded CashBook `AppSizes` / `AppColorsExtension` |
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

When porting: copy behaviour and tests of behaviour, rename `App*` → `MRE*`,
replace theme reads with `MREFieldsTheme.of(context)` + `Theme.of(context)`,
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
      text_direction.dart          # pure detect fn + String/Text/widget extensions
    attachments/
      mre_image_paste_behavior.dart  # none / callback / attachment strip
      mre_attachment_strip.dart
      mre_image_viewer.dart
    phone/
      mre_phone_field.dart
      mre_country_code_picker.dart
      phone_number.dart
      countries.dart
```

- One barrel: `package:mre_fields/mre_fields.dart`.
- Nothing under `src/` is imported by apps directly (keep `src/` modular for future slim exports).
- Breaking public API → bump **major** (once past `1.0.0`) or document in
  `CHANGELOG.md` while still `0.x`.

### Naming (non-negotiable)

- Types (classes, enums, mixins, extensions, typedefs): **`MRE` all capitals** —
  `MRETextField`, `MREPhoneField`, `MREFieldsTheme`, `MREPhoneError`.
- Everything else: lowercase `mre` — package `mre_fields`, files
  `mre_text_field.dart`, non-type identifiers `mreFieldsPreviewTheme`.
- Never `Mre…`. Rule: `.cursor/rules/package-api.mdc`.

### Extensibility (non-negotiable)

Hosts must be able to **adopt**, **override**, or **use a piece** of this package:

1. **Theme with the host app** — colors/typography/`InputDecoration` from
   `Theme.of(context)`. Register `MREFieldsTheme` on the same `ThemeData` the
   app already builds (extensions). No brand colors inside the package. No
   mutable global `initialize`.
2. **Override per widget** — constructor params beat theme; theme beats defaults.
   Expose Material pass-through knobs even when our demos leave them null.
3. **Small units** — pure helpers, suggestion/clear/dial pieces, picker body, and
   full fields are separate. A host can take phone parse without `MREPhoneField`,
   or build their own field from exported pieces.
4. **No hard cross-feature deps** — `MRETextField` must not require phone/country
   code to compile or run.
5. **Responsive / adaptive** — layout from constraints (compact / expanded), not
   `Platform.isX`. Desktop gets dialogs/density; phone gets touch targets and
   sheets. Rule: `.cursor/rules/responsive-adaptive.mdc`.

Rule: `.cursor/rules/extensibility.mdc` (always apply). Also `theming.mdc`,
`package-api.mdc`.

### Theming (host ThemeData + extension)

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: hostScheme,           // package reads this
    inputDecorationTheme: hostInputs,  // package reads this
    extensions: const [
      MREFieldsTheme(
        // radii, contentPadding, suggestion gaps — field tokens only
      ),
    ],
  ),
  // …
);
```

Widget constructor params override the theme for that instance.

### Localization

Hosts translate; the package never does. No `.tr()`, no ARB files, no bundled
translation maps, no `flutter_localizations` dependency.

- All user-visible text sits in one immutable class, `MREFieldsStrings`
  (hints, empty states, picker title, validation messages, viewer labels).
  English defaults; hosts replace any field.
- Resolution: widget param → `MREFieldsTheme.strings` → English default.
- Validation returns an error **reason** (`MREPhoneError`); text comes from
  `MREFieldsStrings` or a host `errorTextBuilder`.
- Country names: host `countryNameBuilder` / map by ISO code, English fallback.

### Country picker

Own a simple modal/bottom sheet inside the package (Material). Do not depend on
CashBook `AdaptiveOverlays`. Host can wrap later if it wants glass.

## Code quality

- Clean, small public classes. No god-widgets: split private state helpers.
- No magic numbers in widgets — name them on `MREFieldsTheme` or as named consts
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
- Widget: `MRETextField` direction flip while typing, suggestions, clear,
  `MREPhoneField` dial + local.
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

Full rules: [`.cursorrules`](./.cursorrules) (root) and
`.cursor/rules/commit-messages.mdc`. Short version:

- Staged changes exist → message covers **only** staged changes. Nothing staged
  → message covers **all** pending changes (including untracked files).
- Conventional Commits: `type(scope): imperative summary` ≤ 72 chars, blank
  line, body that explains what and why per logical change with real symbol
  names from the diff, `BREAKING CHANGE:` when the public API breaks.
- Always end with the co-author trailer (skill `commit-with-coauthor`):

```
feat(text): add live BIDI detection to MRETextField

Direction now follows the typed content instead of the app locale ...

- port detection from ledger AppTextField, using first-strong-character ...
- drive alignment from detected direction unless textDirection is set

Co-Authored-By: Mohammed El Shora <riyadm2001@gmail.com>
```

## Consuming from CashBook later

Path dependency while iterating:

```yaml
# ledger/pubspec.yaml
dependencies:
  mre_fields:
    path: ../mre_fields
```

Then replace `AppTextField` call sites gradually with `MRETextField` (or a thin
CashBook wrapper that forwards `.tr()` hints). Do not move `CustomFieldRegistry`
into this package.

## How agents pick this up

Open **`mre_fields` as the Cursor workspace** (File → Open Folder). Then:

- `AGENTS.md` + `CLAUDE.md` are the entrypoint
- Always-on rules load (`project-standards`, `extensibility`, `flutter-version`, …)
- Skills apply when the task matches (port, preview, publish, example, …)
- Follow **`ROADMAP.md`** step order unless the user overrides

If the chat is still rooted on **CashBook (`ledger`)**, those package rules do **not** auto-apply — open `mre_fields` or `@` the files you need.

## Trying widgets (preview + example)

| Way | Command / UI | Best for |
|---|---|---|
| **Widget Preview** | IDE **Flutter Widget Preview** panel, or `flutter widget-preview start` | Fast look at `@Preview` cards under `lib/src/previews/` |
| **Example app** | `example/` via skill `add-example-app`, then `cd example && flutter run` | Real keyboard, theme toggle, phone flow |
| **Tests** | `flutter test` | Behaviour lock (BIDI, parse, sizes) |

Previews ship with the package sources; they are **not** exported from the public barrel. Example app is optional until Step 3+ but recommended before pub.dev.

## Publishing to pub.dev

Skill: `.cursor/skills/publish-to-pub-dev`.

Short path:

1. Fill `homepage` / `repository` in `pubspec.yaml`
2. `flutter analyze` + `flutter test` + `flutter pub publish --dry-run`
3. User confirms → `flutter pub publish`
4. Optionally switch CashBook from `path:` to `mre_fields: ^x.y.z`

Do not publish unprompted.

## Agent map

| Need | Open |
|---|---|
| Always-on standards | `.cursor/rules/project-standards.mdc` |
| Extensibility | `.cursor/rules/extensibility.mdc` |
| Responsive / adaptive | `.cursor/rules/responsive-adaptive.mdc` |
| Public API | `.cursor/rules/package-api.mdc` |
| Theming | `.cursor/rules/theming.mdc` |
| Port from ledger | `.cursor/skills/port-field-from-ledger` |
| Add field | `.cursor/skills/add-field-widget` |
| Previews | `.cursor/skills/add-widget-preview` |
| Example app | `.cursor/skills/add-example-app` |
| Full tests | `.cursor/skills/full-regression-test` |
| Version bump | `.cursor/skills/bump-package-version` |
| Publish pub.dev | `.cursor/skills/publish-to-pub-dev` |
| Commit trailer | `.cursor/skills/commit-with-coauthor` |
| Performance | `.cursor/rules/performance.mdc` |
| Text direction | `.cursor/rules/text-direction.mdc`, skill `add-text-direction-extensions` |
| Image paste | `.cursor/rules/image-paste.mdc`, skill `add-image-paste` |
| Phone / countries | `.cursor/rules/phone-countries.mdc`, skill `add-phone-validation` |
| Public docs / examples | `.cursor/rules/docs-and-examples.mdc`, skill `write-package-docs` |
| Third-party skills | `.cursor/skills/THIRD_PARTY.md` |
| Roadmap | [`ROADMAP.md`](./ROADMAP.md) |

## Reply style

@.claude/reply-style.md

## Always-on rules (imported so every agent loads all of them)

@.cursor/rules/cleanup.mdc
@.cursor/rules/commit-messages.mdc
@.cursor/rules/docs-and-examples.mdc
@.cursor/rules/extensibility.mdc
@.cursor/rules/flutter-version.mdc
@.cursor/rules/full-regression.mdc
@.cursor/rules/image-paste.mdc
@.cursor/rules/package-api.mdc
@.cursor/rules/performance.mdc
@.cursor/rules/phone-countries.mdc
@.cursor/rules/port-from-ledger.mdc
@.cursor/rules/project-standards.mdc
@.cursor/rules/reply-style.mdc
@.cursor/rules/responsive-adaptive.mdc
@.cursor/rules/test-field-sizes.mdc
@.cursor/rules/text-direction.mdc
@.cursor/rules/theming.mdc

## Skills — check before starting any task

Skills live in `.cursor/skills/` (also visible to Claude Code through
`.claude/skills`). Load the matching skill **before** writing code or docs.
Third-party origin and pins: `.cursor/skills/THIRD_PARTY.md`.

| Task | Skills |
|---|---|
| New field / port from ledger | `add-field-widget`, `port-field-from-ledger`, `widget-composition`, `async-safety` |
| Text direction | `add-text-direction-extensions`, `i18n-rtl-l10n` |
| Image paste | `add-image-paste`, `accessibility-as-code` |
| Phone / countries | `add-phone-validation`, `forms-and-input`, `i18n-rtl-l10n` |
| Theme tokens | `design-system-structure` |
| Layout / sizes | `adaptive-layout`, `flutter-build-responsive-layout`, `flutter-fix-layout-issues` |
| Performance | `flutter-performance` |
| Tests | `add-widget-test`, `flutter-add-widget-test`, `dart-add-unit-test`, `testing-strategy`, `widget-golden-and-a11y-testing`, `full-regression-test` |
| Previews / example | `add-widget-preview`, `flutter-add-widget-preview`, `add-example-app` |
| Docs | `write-package-docs`, `dart-write-documentation`, `dartdoc-conventions`, `dart-use-doc-examples` |
| Code style / analysis | `lint-and-style-config`, `dart-run-static-analysis`, `dart3-idioms-and-coding-standards`, `dart-use-pattern-matching` |
| Structure / deps | `project-structure-and-packages`, `dependency-hygiene`, `dart-resolve-package-conflicts` |
| Release | `bump-package-version`, `publish-to-pub-dev`, `commit-with-coauthor` |
| Review | `caveman-review` |
