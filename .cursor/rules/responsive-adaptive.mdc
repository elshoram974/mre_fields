---
description: Responsive + adaptive field layouts for phone, tablet, desktop (Windows/macOS) — constraints not Platform guesses
globs: "lib/**/*.dart,test/**/*.dart"
alwaysApply: true
---
# Responsive & adaptive fields (ALWAYS)

Form fields must look **intentional** on iPhone, Android, iPad, Windows, and macOS — not “stretched phone UI” on desktop, and not overflowing on narrow phones.

## Principle

**Branch on available width/constraints, not on `Platform.isIOS` / `Platform.isWindows` for layout.**

- Use `LayoutBuilder` when the field’s parent width matters (phone row inside a dialog, half-width column).
- Use `MediaQuery.sizeOf` / `MediaQuery.textScalerOf` for window-level density and text scale.
- Platform checks are OK only for **input behaviour** (e.g. desktop shortcuts, mouse cursor), never as the only way to pick a layout.

Default breakpoints (field-level; tune via `MREFieldsTheme` if needed):

| Name | Width | Typical |
|---|---|---|
| Compact | `< 600` | Phone, narrow window |
| Medium | `600 – 839` | Large phone / small tablet |
| Expanded | `≥ 840` | Tablet landscape, desktop |

## Density & touch

- **Touch-first hit targets** on compact (comfortable padding, clear/dial ≥ ~40–48 logical px).
- On expanded/desktop, allow **slightly denser** padding via theme token (`visualDensity` / `MREFieldsTheme` density) — still keep clear/dial clickable with mouse.
- Honour **`MediaQuery.textScalerOf`** — never assume text scale 1.0; labels and errors must not clip.

## Per-widget expectations

### `MRETextField`
- Full width of parent; no fixed pixel width that breaks desktop forms.
- Prefix/suffix/clear stay aligned at all scales; use `Expanded`/`Flexible` on the text, not the icons.
- Suggestion chips: wrap or horizontal scroll — **no overflow** at 1.3 text scale.
- Desktop: sensible `mouseCursor`, focus outline from theme; Tab moves focus naturally.

### `MREPhoneField`
- **Compact:** dial control + local number may stack or use a tight row with `Flexible` on local.
- **Expanded:** dial + local on one row; local takes remaining width.
- Paste/`+` parse must not cause a layout jump that overflows.

### Country picker / sheets
- Compact: modal bottom sheet (or full-height friendly sheet).
- Expanded / desktop: prefer **centered dialog** with max width (e.g. ~400–480) — not a phone sheet stuck to the bottom of a 27" monitor.
- List tiles: long names `maxLines` + ellipsis; search field pinned.

## Theme tokens (preferred over magic numbers)

Put shared spacing/radius/density on `MREFieldsTheme` so hosts can tune desktop vs mobile without forking widgets. Host `ThemeData.visualDensity` should be respected when reading padding.

## Previews & tests

- Preview cards: at least **compact + expanded** (and RTL or text scale) for each interactive field.
- Widget tests: pump compact (~390) and expanded (~1024) + textScale 1.3; see `test-field-sizes.mdc`.
- `RenderFlex overflowed` = fail.

## Do not

- `if (Platform.isWindows) return DesktopField()` as the layout strategy.
- Fixed height sheets taller than a short window (~300).
- Unbounded `Row` children for the growing text/local number.
- Ignore desktop focus / keyboard: fields must be usable with Tab and Enter where Material expects it.
