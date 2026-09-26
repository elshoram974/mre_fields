---
description: Public API, naming, barrel exports, and SemVer for mre_fields
globs: "lib/**/*.dart"
alwaysApply: false
---
# Package API

## Naming

- Public types: `Mre` prefix — `MreTextField`, `MrePhoneField`, `MreFieldsTheme`, `MreCountryCodePicker`.
- Private implementation: leading `_` under `lib/src/`.
- Files: `mre_text_field.dart`, not `app_text_field.dart`.

## Barrel

- Apps import only `package:mre_fields/mre_fields.dart`.
- Add every new public type to that barrel in the same change.
- Do not export private helpers, test fakes, or CashBook shims.

## Constructor / theme precedence

1. Explicit widget parameter (if non-null)
2. `MreFieldsTheme.of(context)`
3. Material `Theme` / sensible const default

Document non-obvious params with a short dartdoc (why, not what).

## Breaking changes

While `0.x`: allowed, must land in `CHANGELOG.md` under a clear "Breaking" bullet.
At `1.x+`: major bump for removed/renamed public API.

## Do not add to the public surface

Contact pickers, book custom-field registry, PDF helpers, glass chrome, app routing, localization engines.
