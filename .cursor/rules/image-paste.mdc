---
description: Optional image paste for text fields — strategy classes, default is no image handling
globs: "lib/src/text/**/*.dart,lib/src/attachments/**/*.dart,test/**/*.dart"
alwaysApply: true
---
# Image paste

Pasting an image into a field (chat / prompt style) is **opt-in**. A plain `MRETextField` behaves exactly like a text field.

## Shape

One constructor parameter takes a behaviour object:

```dart
MRETextField(
  imagePaste: const MRENoImagePaste(),          // default
)
```

| Class | UI | Does |
|---|---|---|
| `MREImagePasteBehavior` (abstract) | — | Contract: limits, `onImagePasted`, how to render. Hosts may extend it. |
| `MRENoImagePaste` (default) | none | Ignores images; text paste untouched. |
| `MREImageCallbackPaste` | none | Calls `onImagePasted(MREPastedImage)`; host decides everything. |
| `MREImageAttachmentPaste` | thumbnail strip inside/under the field | Preview, open full-screen, remove, replace, plus the same callback. |

Every behaviour exposes the callback; only the UI differs.

## Value type

`MREPastedImage` — `Uint8List bytes`, `String mimeType`, optional `name`, `width`/`height` once decoded. Immutable, `==` by identity of bytes + metadata. No `dart:io` `File` in the public type (web/desktop parity).

## Limits (params, validated before the callback)

`maxImages`, `maxBytes`, `allowedMimeTypes`. Rejected images call `onImageRejected(MREImageRejection reason)`; the package shows no text of its own (host passes strings).

## Getting the image

- Clipboard reading goes through a small `MREClipboardImageReader` interface (`Future<MREPastedImage?> read()`), so hosts can swap the implementation and text-only users do not pull an image/clipboard plugin. A default reader backed by a maintained plugin ships in its own library file.
- Android/iOS keyboards (stickers, GIF, images): use `TextField.contentInsertionConfiguration`.
- Desktop/web `Ctrl/Cmd+V`: intercept in the field's `FocusNode.onKeyEvent` and in `contextMenuBuilder` (paste item). Only claim the event when the clipboard actually has an allowed image — otherwise return `KeyEventResult.ignored` so normal text paste works.
- Pasting images is a standard, solved flow (web apps and desktop apps do it). Build it directly and verify each platform in the example app; record the support matrix in the README.

## UI rules

- Thumbnails use `cacheWidth`/`cacheHeight`; list is a lazy `ListView.builder` (horizontal) — no unbounded `Row`.
- Tap opens a viewer (`InteractiveViewer`, close, dark-safe); remove and replace have ≥ 40 px targets and `Semantics` labels passed as params.
- Layout adapts by constraints (compact: one strip above the text; expanded: larger thumbs). See `responsive-adaptive.mdc`.
- Colors from `Theme`; sizes/radii from `MREFieldsTheme`.

## Do not

- Make clipboard/image packages a dependency of users who only want text.
- Swallow decode errors silently — report via `onImageRejected`.
- Keep full-size bytes in `State` after the host took ownership.
