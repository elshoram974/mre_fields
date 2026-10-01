---
description: Extensibility — host theme colors, overridable widgets, small composable pieces, pass-through params
globs: "lib/**/*.dart"
alwaysApply: true
---
# Extensibility first (ALWAYS)

Every public piece must be usable **as-is**, **overridden**, or **taken apart**. Hosts are not forced into our full stack.

## 1. Theme follows the host app

- Colors / typography / `InputDecoration` come from **`Theme.of(context)`** (`colorScheme`, `textTheme`, `inputDecorationTheme`). The package does not ship a brand palette.
- Hosts register **`MREFieldsTheme`** on their existing `ThemeData.extensions` (same place as the rest of their theme) — radii, paddings, and field-only tokens. That is the “init with my theme” path; **not** a mutable global `MREFields.initialize(...)`.
- Optional: document `MREFieldsTheme.fromTheme(ThemeData)` / factory that derives defaults from `colorScheme` if useful — still registered via `extensions`.
- Never hard-code CashBook (or any app) colors.

## 2. Every widget is overridable at the call site

Precedence (highest wins):

1. Explicit widget constructor parameter
2. `MREFieldsTheme.of(context)`
3. Material `Theme` / package const default

If a host might need a knob (decoration builder, prefix/suffix, style, border, fill, cursor color, `inputFormatters`, `autofillHints`, `textCapitalization`, …) and Material already has it, **expose the param** even when our demos leave it null. Prefer pass-through to the underlying `TextFormField` over hiding it.

## 3. Small functions and widgets — use a piece, not the whole kit

| Layer | Examples | Host can |
|---|---|---|
| Pure helpers | `uiTextDirection`, `safeDisplayText`, phone parse | import/use alone |
| Small widgets | clear button, suggestion strip, dial chip | compose their own field |
| Sheets / pickers | country list body | embed without our modal |
| Full fields | `MRETextField`, `MREPhoneField` | drop-in |

- Split god-widgets: private `_Foo` for layout pieces; **export** the pieces hosts may reuse (`MREFieldClearButton`, `MRESuggestionBar`, …) when they are meaningful alone.
- Prefer composition (`MREPhoneField` uses `MRETextField` + dial) over copy-paste forks.
- Do not require importing phone code to use text helpers (keep files separate; barrel may export all, but `src/` stays decoupled).

## 4. Barrel vs pieces

- Default barrel: `package:mre_fields/mre_fields.dart` exports the public surface.
- Keep implementation in focused `src/` files so a future slim export (e.g. `mre_fields/text.dart`) is possible without a rewrite.
- Do not force a single mega-widget that only works if the host opts into every feature flag.

## 5. When adding anything new — checklist

- [ ] Reads host `Theme` for colors?
- [ ] Has constructor overrides for any non-trivial look/behaviour?
- [ ] Params we don’t use in demos still passed through where Material allows?
- [ ] Logic extractable as a pure function or tiny widget?
- [ ] Host can skip this feature without breaking unrelated widgets?
- [ ] Documented in dartdoc with a one-line “override with …” hint when non-obvious?

## Do not

- Bake app branding into defaults beyond neutral Material.
- Hide useful `TextFormField` / `InputDecoration` knobs “to keep the API small.”
- Use static mutable config instead of `ThemeExtension`.
- Make phone/country a hard dependency of `MRETextField`.
