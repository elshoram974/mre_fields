# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `MREFieldsTheme` theme extension: field border radius, content padding (compact and expanded), window-size breakpoints, and `MREWindowSize` classification. Works without registration through `MREFieldsTheme.defaults`.
- `MREFieldsStrings`: one immutable set of user-visible texts with English defaults, so every field text can be localized.
- Text direction: `detectTextDirection` and `detectStrongTextDirection` (first word with a letter decides, constant cost), `String` getters `textDirection`, `isRtl`, `directionOr`, `autoTextAlign`, the `MREAutoText` widget (every `Text` parameter, plus `autoAlign`; also `MREAutoText.rich`), `Text.autoDirection()` and `Text.autoAlign()`, `Widget.withTextDirection`, and `safeDisplayText` for unpaired surrogates.
- `MRETextField`: a form text field with live direction, clear button, select on focus, suggestions, and the parameters of `TextFormField`. Radius and padding come from the parameter, then `MREFieldsTheme`, then your `InputDecorationTheme`.
- `MRESuggestionBar`, `mreFilterSuggestions`, `MREFieldClearButton` and `MRESafeTextEditingController`, usable without the field.
- `@MREPreview()` annotation to preview any widget in light, dark, right to left, large text, narrow and wide layouts.
