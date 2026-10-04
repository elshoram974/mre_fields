# Changelog

## [0.3.3] - 2026-10-04

### Fixed
- Update `phone_numbers_parser` to 9.0.28 and use its non-deprecated
  `metadataLengthsByIsoCode` API, so `flutter analyze` passes in CI.
- Declare Android, iOS, web, Windows, macOS and Linux support for pub.dev.

## [0.3.2] - 2026-10-04

### Added
- Optional `MREImageAttachmentPaste.showCounter` inside the field. Custom
  attachment builders receive `maxImages` and `isAtLimit`, including when empty.

### Changed
- Scope `MREPhoneField` country updates to the dial button and reuse
  `MREPhoneController.number` parsing for unchanged text, country and selection.

## [0.3.1] - 2026-10-04

### Fixed
- Recognized international dial codes update the selected country during typing,
  independently of number validity. Shared codes are refined as digits arrive.
- `onCountryChanged` is emitted only when the selected ISO country changes.


## [0.3.0] - 2026-10-04

### Added
- Ordinary `MRETextField` and `MREPhoneField` inputs paired with explicit
  `MRETextFormField` and `MREPhoneFormField` form widgets. Phone forms save a
  structured number and reset both country and digits; phone inputs accept decoration.
- Unicode 17.0.0 direction data for all writing systems, a reproducible generator
  and its Unicode license.
- Custom in-field image presentation through `MREImageAttachmentPaste.builder`.

### Changed
- Image thumbnails now share the input border and appear above the text.

### Fixed
- Weak/neutral punctuation and combining marks no longer override text direction.
- Decode supplementary characters correctly and skip isolated content.
- Read-only/disabled input blocks suggestions and image mutations while preserving viewing.
- Pending image replacement follows image identity; stale handlers and stopped web reads are ignored.
- Preserve the default text selection menu when image paste is disabled.

### Breaking
- Form-only arguments moved from `MRETextField`/`MREPhoneField` to their
  `*FormField` counterparts. Migrate existing form uses to those names.
- Phone form keys now use `FormFieldState<MREPhoneNumber>`.
- Custom `MREImagePasteScope` builders place `hooks.attachments` themselves;
  the scope no longer appends a strip below the input.


All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-10-01

### Added

- **Phone number field.** `MREPhoneField` checks the number for every country (245 countries and regions) and says what is wrong: too short, too long, not valid for the country, unknown dial code, country not accepted.
  - Paste `+20 (10) 1234-5678` or `0020 101 234 5678` and the country switches to Egypt and the digits fill in. A number that shares a dial code finds the right country: `+1 204…` is Canada, `+1 212…` is the United States.
  - Arabic, Persian and full-width digits are converted to ASCII digits as the user types.
  - Choose the countries: accept only some (`include`), drop some (`exclude`), pin favorites to the top of the picker, set the starting country. One selection controls the picker, the paste detection and the validation.
  - A searchable country picker with flags, names, ISO codes and dial codes. It opens as a draggable sheet on narrow windows and as a dialog with a maximum width on wide ones.
  - Everything can be translated: country names with `countryNameBuilder`, the picker texts and the seven error messages through `MREFieldsStrings`.
- **Phone numbers without a widget.** `MREPhoneNumber.parse` and `MREPhoneNumber.national` give the country, the digits, `e164`, the national and international formats, and the reason a number is invalid. `MREPhoneValidators.valid` validates any `TextFormField`. `MRECountries` looks countries up by ISO code or dial code.
- `MREPhoneController` to read or set the number from code, `MRECountryPickerBody` and `showMRECountryPicker` to use the picker alone.

### Changed

- Works on Flutter 3.38.1 and newer (Dart 3.10). The SDK constraint was `^3.12.0`, which needed Flutter 3.44. The test suite passes on 3.38.1, on the latest stable and on beta.
- `meta` is loosened to `^1.15.0` so it resolves with the version each Flutter pins.

## [0.1.1] - 2026-10-01

### Changed

- README rewritten: why to use the package, install, quick start, what to use for each need, platform support and questions.
- The pub.dev Example tab shows a full walkthrough (`example/example.md`) instead of three lines of `main.dart`.
- The API reference landing page lists the guides, and README and example code is copied from tested snippets.

## [0.1.0] - 2026-10-01

### Added

- **Text that follows its language.** `MRETextField` and `MREAutoText` read the first word that has a letter and switch between right to left and left to right as the user types. Digits and symbols before it are skipped, so `123 مرحبا` is right to left. Every right-to-left script works: Arabic, Hebrew, Persian, Urdu and more.
- **Direction and alignment for the widgets you already have.** `Text.autoDirection()`, `Text.autoAlign()` and `Widget.withTextDirection()`.
- **Paste images into a field.** `MREImageAttachmentPaste` keeps pasted images under the field with open, remove and replace; `MREImageCallbackPaste` hands each image to your code. Size, type and count limits, and a reason for every rejected image. Images arrive through the paste shortcut, the browser paste event, the selection menu and the Android keyboard.
- **One theme for every field.** Register `MREFieldsTheme` once for radius, padding and breakpoints, and `MREFieldsStrings` for every text. A widget parameter beats the theme for one field.
- **A text field with suggestions and select on focus**, with the parameters of `TextFormField`, usable in a `Form`.
- **The rules without a widget.** `detectTextDirection`, `safeDisplayText` (removes characters that make Flutter throw), `mreFilterSuggestions`, `mreSniffImageMimeType`, `MREAttachmentsController`, and `MREImagePasteScope` to give any `TextField` image paste.
- An example app for every platform and `@MREPreview()` to preview any widget in light, dark, right to left, large text, narrow and wide layouts.
