# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2026-10-01

### Changed

- Works on Flutter 3.38.1 and newer (Dart 3.10). The SDK constraint was `^3.12.0`, which needed Flutter 3.44. All tests pass on 3.38.1 and on the latest stable.
- `meta` constraint loosened to `^1.15.0`, so it resolves with the version each Flutter pins.

## [0.1.1] - 2026-10-01

### Changed

- README rewritten: why to use it, install, quick start, a table of what to use for each need, platform support, and questions.
- The pub.dev Example tab now shows a full walkthrough (`example/example.md`) instead of three lines of `main.dart`.
- API reference landing page lists the guides.
- README and example page code is copied from the tested snippets, so it cannot drift.

## [0.1.0] - 2026-10-01

### Added

- `MREFieldsTheme` theme extension: field border radius, content padding (compact and expanded), window-size breakpoints, and `MREWindowSize` classification. Works without registration through `MREFieldsTheme.defaults`.
- `MREFieldsStrings`: one immutable set of user-visible texts with English defaults, so every field text can be localized.
- Text direction: `detectTextDirection` and `detectStrongTextDirection` (first word with a letter decides, constant cost), `String` getters `textDirection`, `isRtl`, `directionOr`, `autoTextAlign`, the `MREAutoText` widget (every `Text` parameter, plus `autoAlign`; also `MREAutoText.rich`), `Text.autoDirection()` and `Text.autoAlign()`, `Widget.withTextDirection`, and `safeDisplayText` for unpaired surrogates.
- `MRETextField`: a form text field with live direction, clear button, select on focus, suggestions, and the parameters of `TextFormField`. Radius and padding come from the parameter, then `MREFieldsTheme`, then your `InputDecorationTheme`.
- `MRESuggestionBar`, `mreFilterSuggestions`, `MREFieldClearButton` and `MRESafeTextEditingController`, usable without the field.
- Image paste for `MRETextField` through `imagePaste`: `MRENoImagePaste` (default), `MREImageCallbackPaste` and `MREImageAttachmentPaste`, with limits, rejection reasons, and `onImagePasted` / `onImagesChanged`. Images arrive through the paste shortcut (desktop), the browser `paste` event (web), the selection menu and the Android keyboard.
- `MREAttachmentStrip` (thumbnails with open, remove and replace), `MREImageViewer`, `MREAttachmentsController`, `MREImagePasteScope` for any text field, `MREClipboardImageReader`, and `mreSniffImageMimeType`.
- New `MREFieldsStrings` texts: `pasteImageLabel` and `attachedImageLabel`.
- Depends on `pasteboard` to read images from the clipboard, and on `web` for the browser paste event.
- An example app for every platform (`example/`), with a page for each feature, a light and dark switch, an English and Arabic switch, and a live radius slider.
- `@MREPreview()` annotation to preview any widget in light, dark, right to left, large text, narrow and wide layouts.
