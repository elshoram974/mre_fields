---
name: add-text-direction-extensions
description: >-
  Builds or extends the text-direction (BIDI) layer of mre_fields: the pure
  detection function, String extensions, Text/widget helpers, and live direction
  in MRETextField. Use when asked for auto direction on Text, RTL/LTR detection,
  or direction extensions.
---

# Text direction layer

Read `.cursor/rules/text-direction.mdc` and `.cursor/rules/performance.mdc` first.

## Steps

1. **Pure function** in `lib/src/text/direction/text_direction.dart`:
   `TextDirection detectTextDirection(String text, {TextDirection fallback = TextDirection.ltr})`.
   Decode full Unicode code points, classify with the pinned Bidi_Class data, skip weak/neutral characters and isolated content, return at the first strong character, and stop at the documented scan cap. Do not call `Bidi.detectRtlDirectionality` on the whole string. Use `mre_bidi_data.dart`, regenerated from Unicode 17.0.0 with `tool/generate_bidi_data.py`; keep its license. Do not introduce script allowlists or heuristic ranges.
2. **String extension** (`textDirection`, `isRtl`, `autoTextAlign`) — each a one-liner over the function.
3. **Text helper**: `MREAutoText` (or `Text` named constructor) that forwards every `Text` parameter and fills `textDirection`/`textAlign` only when null. Cover `Text.rich` via the plain-text projection of the span.
4. **Widget extension** `withTextDirection(sample)`: wrap in `Directionality` only when different from ambient, so the common case adds no widget.
5. **Field**: one `ValueNotifier<TextDirection>` fed by a controller listener; only the `TextField` subtree listens. Empty text → ambient direction. Explicit `textDirection` param disables detection.
6. Export from the barrel with the pure function and extensions usable without the field.
7. Tests: cases listed in the rule; plus a widget test typing Arabic → English → empty and asserting direction/alignment at each step, and a build-count test (no whole-field rebuild per keystroke).
8. Preview cards: multiple LTR and RTL scripts (including astral letters), mixed, empty. Arabic and English are examples only. Example page: "Text direction".
9. `CHANGELOG`, dartdoc with a snippet for each public member.

## Check

```bash
flutter analyze && flutter test test/src/text
```

Include the multilingual and punctuation regressions in `unicode_direction_test.dart`.
