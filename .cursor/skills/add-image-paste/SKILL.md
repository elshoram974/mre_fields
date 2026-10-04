---
name: add-image-paste
description: >-
  Adds optional image paste to MRETextField through a behaviour class (none /
  callback / in-field attachments), with preview, open, remove and replace. Use when
  the user wants paste-image-into-field, chat-style attachments, or a callback
  with the pasted image.
---

# Image paste behaviours

Read `.cursor/rules/image-paste.mdc`, `performance.mdc`, `responsive-adaptive.mdc`.

## Steps

1. **Types** under `lib/src/attachments/model/` and `paste/`: `MREPastedImage`, `MREImageRejection` (`tooLarge`, `wrongType`, `tooMany`, `unreadable`), `mreSniffImageMimeType`, `MREImagePasteBehavior` (abstract) with `MRENoImagePaste`, `MREImageCallbackPaste`, `MREImageAttachmentPaste`. Shared validation lives in the base `check`. Keeping images is data: a behaviour returns an `MREAttachmentsConfig` from `attachments`; code never tests for a behaviour subclass.
2. **Reader**: `MREClipboardImageReader` interface and `MREPasteboardImageReader` (plugin `pasteboard`). Check pub.dev for the plugin's release date and platform tags before changing it.
3. **State**: `MREAttachmentsController` (`ChangeNotifier`, `images` is an O(1) read-only view). The scope keeps its own when the behaviour gives none, and never disposes one the host passed.
4. **Rules and wiring**: `MREImagePasteHandler` (internal, no widgets) holds the rules and is tested alone; `MREPasteImageAction` and `MREPasteImageMenu` are small internal files; `MREImagePasteScope` wraps any text field. With a behaviour that accepts nothing it adds nothing. Otherwise it overrides `PasteTextIntent` through `Actions`, builds `contentInsertionConfiguration`, builds the selection menu item, and exposes `hooks.attachments` for the field to place inside its decoration.
5. **UI**: one input border surrounds thumbnails above text, preserving host decoration and error/focus states. `MREImageAttachmentPaste.builder` allows a host presentation with nullable edit callbacks. `MREAttachmentStrip` (lazy list, thumbnails with `cacheWidth`, remove and replace buttons, open) and `MREImageViewer`. Texts come from `MREFieldsStrings`.
6. **Field**: `MRETextField(imagePaste: ...)`, default `const MRENoImagePaste()`.
7. **Tests**: drive paste with `Actions.invoke(FocusManager.instance.primaryFocus!.context!, PasteTextIntent(...))` — the focused node's context, like a key press, so the overridable action chain works. Mock `Clipboard.getData` on `SystemChannels.platform`. Fake the reader. Cover: text wins, image to callback, limits, unreadable, attachments add/remove/replace/open, host controller, keyboard content, menu item, layout at compact and expanded with text scale 1.3 and both directions.
8. **Docs and previews**: snippets in `doc/snippets/attachments.dart`, guide `doc/attachments.md`, previews in `lib/src/previews/mre_attachments_previews.dart` (images from `preview_images.dart`).
9. `CHANGELOG`; verify in the real previewer (see `add-widget-preview`).

## Check

```bash
flutter analyze && flutter test test/src/attachments test/src/text
```

Cover enabled/readOnly for all user actions; callback-only keeps no UI/state.
Test replacement while the list changes, behavior/controller switches during a
read, and stopped web listeners. Both text field variants use the same behavior.
