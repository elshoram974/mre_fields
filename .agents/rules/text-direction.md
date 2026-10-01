---
description: Text direction (BIDI) — detection helper, String/Text/widget extensions, live field behaviour
globs: "lib/src/text/**/*.dart,test/src/text/**/*.dart"
alwaysApply: true
---
# Text direction

One detection function powers everything: field, `Text` helper, plain `String`.

## Layers (each usable alone)

| Layer | Public name (proposed) | Notes |
|---|---|---|
| Pure function | `detectTextDirection(String, {TextDirection fallback})` | No Flutter widgets. First strong character wins (UAX #9 P2/P3), early exit, scan cap (e.g. 64 chars). |
| String extension | `String.textDirection`, `String.isRtl`, `String.autoTextAlign` | Thin wrappers over the function. |
| Text helper | `Text.autoDirection(...)` / `MREAutoText(...)` | Sets `textDirection` + `textAlign` from content unless the caller passes them. |
| Widget extension | `Widget.withTextDirection(String sample)` | Wraps in `Directionality` only when direction differs from ambient. |
| Field | `MRETextField` | Live direction while typing; locks only when `textDirection` param is set. |

## Behaviour rules

- Empty / only neutral characters (digits, spaces, punctuation) → **fallback to ambient `Directionality`**, not LTR.
- User-supplied `textDirection` / `textAlign` always wins over detection.
- Alignment follows direction with `TextAlign.start` semantics where possible; do not hard-code `left`/`right` (breaks mirrored layouts).
- Fields that are inherently LTR (email, URL, password while obscured, numbers) lock `TextDirection.ltr` via a param/preset, not scattered `if`s.
- Mixed content (Arabic sentence with an English word) follows the **first strong** character; hosts can override.
- Do not mutate the text (no reshaping, no inserted control characters) — display helpers like `safeDisplayText` are separate, opt-in functions.

## Performance

- Cache nothing global. The field keeps one `ValueNotifier<TextDirection>`; set it only when the value changes.
- Never call detection inside `build` for a `TextField` — listen to the controller.

## Tests (pure, no pump needed)

Empty, Arabic, English, Hebrew, Persian/Urdu, digits-only, `"123 مرحبا"`, `"hello مرحبا"`, emoji-first, leading space, very long string (assert it stays under a few ms), unpaired surrogate.
