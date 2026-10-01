---
name: add-image-paste
description: >-
  Adds optional image paste to MRETextField through a behaviour class (none /
  callback / attachment strip), with preview, open, remove and replace. Use when
  the user wants paste-image-into-field, chat-style attachments, or a callback
  with the pasted image.
---

# Image paste behaviours

Read `.cursor/rules/image-paste.mdc`, `performance.mdc`, `responsive-adaptive.mdc`.

## Steps

1. **Wire the paste entry points**: `contentInsertionConfiguration` (mobile keyboards), `FocusNode.onKeyEvent` for Ctrl/Cmd+V, `contextMenuBuilder` paste item. Verify each platform in the example app and record the matrix in the README "Platform notes".
2. **Types** under `lib/src/attachments/`: `MREPastedImage`, `MREImageRejection` (enum: tooLarge, wrongType, tooMany, undecodable), `MREImagePasteBehavior` (abstract).
3. **Behaviours**: `MRENoImagePaste` (const default), `MREImageCallbackPaste`, `MREImageAttachmentPaste`. Shared validation lives in the base class, not copied.
4. **Clipboard reader**: `MREClipboardImageReader` interface + a default implementation on a maintained plugin (check pub.dev release date first), in its own library file so text-only imports stay plugin-free.
5. **Hook into `MRETextField`**: new param `imagePaste` (default `const MRENoImagePaste()`). Intercept only when the clipboard has an allowed image; otherwise let text paste run.
6. **Attachment UI** (`MREAttachmentStrip`, exported): lazy horizontal list, thumbnails with `cacheWidth`, remove button, replace action, tap → `MREImageViewer` (full-screen, `InteractiveViewer`). Semantics labels and tooltips are params.
7. **State**: attachments owned by a small `MREAttachmentsController` (`ChangeNotifier`) the host can pass in or let the field create. Callback fires on add/remove/replace.
8. **Tests**: default behaviour ignores images; callback receives bytes + mime; limits reject with the right reason; remove/replace update the controller; text paste still works; compact + expanded + RTL + textScale 1.3.
9. **Previews/example**: three cards — none, callback (shows host-side usage), attachments.
10. `CHANGELOG`, dartdoc with one snippet per behaviour.

## Check

```bash
flutter analyze && flutter test test/src/attachments test/src/text
```
