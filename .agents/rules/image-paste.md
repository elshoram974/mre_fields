---
description: Optional image paste for text fields — behaviour classes, default is no image handling
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
| `MREImagePasteBehavior` (abstract) | — | Limits (`maxImages`, `maxBytes`, `allowedMimeTypes`), `onImagePasted`, `onImageRejected`, `reader`. Hosts may extend it. |
| `MRENoImagePaste` (default) | none | `acceptsImages` is false: no hooks, no widgets, no cost. |
| `MREImageCallbackPaste` | none | Calls `onImagePasted(MREPastedImage)`; host decides everything. |
| `MREImageAttachmentPaste` | thumbnail strip under the field | Keeps the images; open, remove, replace; `onImagesChanged`; optional host `MREAttachmentsController`. |

Pieces hosts can use alone: `MREImagePasteScope` (paste hooks for any text field), `MREAttachmentStrip`, `MREImageViewer`, `MREAttachmentsController`, `MREPasteboardImageReader`, `mreSniffImageMimeType`.

## Rules the code follows

- **Text wins.** The paste shortcut reads the clipboard text first. Only when there is no text does it read an image. A copy from a document (text + picture) pastes as text.
- **Never replace text paste.** No image → fall back to the field's own paste action (`callingAction` of the overridable `PasteTextIntent`).
- **Value type:** `MREPastedImage` holds `Uint8List bytes`, `mimeType`, `name`. No `dart:io` `File` (web and desktop parity). Type comes from the bytes (`mreSniffImageMimeType`), not from the claimed type.
- **Rejections** (`MREImageRejection`): `tooLarge`, `wrongType`, `tooMany`, `unreadable`. The package shows no message of its own; the host passes strings through `MREFieldsStrings`.
- **Replace** swaps in the image on the clipboard. It ignores the clipboard text and does not count the replaced image against `maxImages`.
- **Errors:** only `PlatformException` and `MissingPluginException` from the reader are caught, and both become `unreadable`. No other catch.

## Where images arrive (all three go through one `_accept`)

- Paste shortcut: ancestor `Actions` overriding `PasteTextIntent` (desktop and web).
- Selection menu: `contextMenuBuilder` adds "Paste image" when the clipboard holds one.
- On-screen keyboard: `contentInsertionConfiguration` (Android only, a Flutter limitation).

## Clipboard dependency

The default reader uses the `pasteboard` plugin (Android, iOS, macOS, Windows, Linux, web). It is a normal dependency of the package, so text-only users also get the plugin; it stays idle unless a behaviour accepts images. Anything else goes through the `MREClipboardImageReader` interface, which tests fake.

## UI rules

- Thumbnails decode with `cacheWidth`; the list is a lazy horizontal `ListView.builder`, no unbounded `Row`.
- Thumbnail edge: 96 compact / 120 expanded. Remove and replace buttons are 40 px with `tapTargetSize: shrinkWrap` — the default 48 px hit area would cover the image and block the open tap.
- A tap on the image opens `MREImageViewer` (full screen, `InteractiveViewer`, close button).
- Colors from `Theme`; radius from `MREFieldsTheme`; texts from `MREFieldsStrings`.

## Do not

- Swallow decode errors silently — `Image.memory` shows a broken-image icon.
- Keep full-size bytes in `State` after the host took ownership (callback behaviour holds none).
- Call the clipboard to decide whether to show a menu item more than once per menu open.
