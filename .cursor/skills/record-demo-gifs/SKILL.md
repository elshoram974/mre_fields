---
name: record-demo-gifs
description: >-
  Records or updates the animated GIFs in doc/images from the example app (text
  direction, image paste, phone). Use when a feature needs a visual for the
  README or pub.dev screenshots, or when the demos changed.
---

# Record the demo GIFs

The GIFs are recorded from the **real example app on the web**, driven through the Chrome DevTools protocol. Nothing is mocked: the frames are screenshots of the widgets running.

## Files

| File | Role |
|---|---|
| `example/lib/demos/*.dart` | One clean page per GIF (`?demo=text`, `?demo=paste`), top-aligned so the card does not jump while it grows |
| `tool/demo/record.mjs` | Scenario script: loads the page, types, clicks, fires a paste event, saves PNG frames and their durations |
| `tool/demo/build_gifs.py` | Merges identical frames, 96 colors, 640 px wide, writes `doc/images/*.gif` |
| `tool/demo/make_gifs.sh` | Runs the whole chain |
| `doc/images/*.gif` | Output. Referenced by `pubspec.yaml` `screenshots:` and by absolute raw URLs in `README.md` |

## Steps

1. Add or change the demo page in `example/lib/demos/` and register it in `demo_pages.dart`.
2. Add a scenario branch in `tool/demo/record.mjs` (`FIELD` and `CLEAR` are click coordinates in the 640x520 viewport; read them from a probe screenshot, do not guess).
3. Add the scenario to `build_gifs.py`.
4. `sh tool/demo/make_gifs.sh`, then open the GIF frames and check them (contact sheet with Pillow).
5. Add the GIF to `pubspec.yaml` `screenshots:` (≤ 10 files, ≤ 4 MB each; png, jpg, webp, gif) with a one-sentence description.
6. README: embed with an absolute `https://raw.githubusercontent.com/<owner>/mre_fields/main/doc/images/<name>.gif` URL, because pub.dev does not resolve relative image paths.

## What a good demo shows

- One idea per GIF, 6 to 12 seconds, loops forever.
- Text direction: English, Arabic, a number first, a symbol first, mixed text. The caption shows the detected direction.
- Image paste: type a little text, paste three different images, show the thumbnails with their buttons.
- Phone (when it exists): paste `+20…`, watch the country change; exclude a country; show a validation error.
- Light theme, real labels, no mouse cursor, no tooltip left open (move the mouse away after a click).

## Gotchas

- Paste on the web is a DOM `paste` event: send a `ClipboardEvent` with a `DataTransfer` that holds a `File`.
- Type with `Input.insertText` one character at a time; Flutter's hidden text input receives it.
- Keep the file size small: merge duplicate frames, limit colors, 640 px wide.
- Do not mention tools or assistants in the page text or captions.
