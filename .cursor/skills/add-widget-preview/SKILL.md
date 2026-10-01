---
name: add-widget-preview
description: >-
  Adds Flutter Widget Previewer (@Preview) cards for MRETextField, MREPhoneField,
  and related UI. Use when the user asks for previews, widget preview, or visual
  sandbox for field widgets.
---

# Add widget previews (mre_fields)

Requires Flutter **3.38+** on PATH (no FVM in this repo).

## Rules

- Import `package:flutter/widget_previews.dart`.
- Targets: top-level functions / static methods / public constructors with **no required args** returning `Widget` or `WidgetBuilder`.
- Put shared harness in `lib/src/previews/preview_harness.dart` (theme + `MREFieldsTheme`).
- Put field previews next to the widget or under `lib/src/previews/` (e.g. `mre_text_field_previews.dart`).
- No `dart:io` / native plugins in preview code paths.
- Pass **literal English** strings in previews (package has no `.tr()`).
- Multiple configs: several `@Preview`s or a small `MultiPreview` subclass (light/dark, LTR/RTL).

## Preview any widget in one line

```dart
import 'package:mre_fields/src/previews/preview_harness.dart'; // or a relative import

@MREPreview()
Widget previewMyField() => const MyField();
```

`@MREPreview()` (in `lib/src/previews/preview_harness.dart`) makes six cards: light, dark, RTL, text scale 1.3, narrow 390, wide 1024. Each card keeps the previewer's color scheme and registers `MREFieldsTheme`. For a custom set, use `@Preview(wrapper: mrePreviewWrapper, ...)` or `mrePreviewRtlWrapper`.

Rules for the function: top-level, public, no required arguments, returns `Widget`. Give it a doc comment (`public_member_api_docs`). One file per feature: `lib/src/previews/<widget>_previews.dart`.

Check discovery without opening a browser:

```bash
flutter widget-preview start --web-server
rg -l previewMyField .widget_preview/lib
```

## Previewer facts (learned the hard way)

- A card **without `size`** gives the widget **unbounded width**. A `Column(crossAxisAlignment: stretch)` or any widget that fills its parent then throws "BoxConstraints forces an infinite width" and the card stays blank. `MREPreview` gives the first four cards a 480 width; custom previews must set `size: Size.fromWidth(...)` or use `mrePreviewWrapper` (it bounds the width).
- The previewer sets card brightness through `MediaQuery.platformBrightness`, not through a theme. A wrapper must build its theme from `MediaQuery.platformBrightnessOf(context)`; copying `Theme.of(context)` keeps the previewer's own theme.
- `test/src/previews/mre_preview_test.dart` reproduces both cases (unbounded width, brightness through `MediaQuery`). Add each new preview function to it.

Visual check without the IDE: run `flutter widget-preview start --web-server`, read the printed `http://localhost:<port>`, open it in Chrome (headless works through the DevTools protocol), and look for `EXCEPTION CAUGHT` in the console and for blank cards.

## Checklist

- [ ] Uses `@MREPreview()` (wraps the previewer theme and registers `MREFieldsTheme`)
- [ ] Preview for empty + filled text field
- [ ] Preview with Arabic text (RTL BIDI)
- [ ] Preview phone field (once it exists)
- [ ] Light + dark (brightness) where useful
- [ ] Open with `flutter widget-preview start` or IDE panel

## Launch

```bash
flutter widget-preview start
```

IDE (Flutter 3.38+): open **Flutter Widget Preview**; optionally filter by selected file.

## Do not

- Preview CashBook screens here
- Depend on ledger packages inside preview files
- Use unconstrained widgets without a `size:` on `@Preview` when they would expand infinitely
- Introduce FVM
