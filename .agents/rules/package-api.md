---
description: Public API, naming, barrel exports, SemVer, and composable pass-through params
globs: "lib/**/*.dart"
alwaysApply: false
---
# Package API

See also **extensibility.mdc** (always on).

## Naming

- Public types: `Mre` prefix — `MreTextField`, `MrePhoneField`, `MreFieldsTheme`, `MreCountryCodePicker`.
- Reusable pieces: also `Mre*` (`MreSuggestionBar`, …) — not anonymous private-only if hosts need them.
- Private implementation: leading `_` under `lib/src/`.
- Files: `mre_text_field.dart`, not `app_text_field.dart`.

## Barrel

- Apps import `package:mre_fields/mre_fields.dart` by default.
- Keep `src/` modular (text / phone / theme) so slim entrypoints can be added later without splitting behaviour.
- Export every intentional public type in the same change that adds it.
- Do not export test fakes or CashBook shims.

## Constructor / theme precedence

1. Explicit widget parameter (if non-null)
2. `MreFieldsTheme.of(context)`
3. Material `Theme` / sensible const default

Pass through Material knobs hosts may need even if our demos omit them. Document non-obvious params with short dartdoc (why + how to override).

## Breaking changes

While `0.x`: allowed, must land in `CHANGELOG.md` under "Breaking".
At `1.x+`: major bump for removed/renamed public API.

## Do not add to the public surface

Contact pickers, book custom-field registry, PDF helpers, glass chrome, app routing, localization engines — those stay in the host app.
