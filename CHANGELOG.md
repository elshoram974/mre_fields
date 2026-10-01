# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `MREFieldsTheme` theme extension: field border radius, content padding (compact and expanded), window-size breakpoints, and `MREWindowSize` classification. Works without registration through `MREFieldsTheme.defaults`.
- `MREFieldsStrings`: one immutable set of user-visible texts with English defaults, so every field text can be localized.
- Text direction: `detectTextDirection` (first strong letter, constant cost), `String` getters `textDirection`, `isRtl`, `directionOr`, the `MREAutoText` widget (also `MREAutoText.rich`), `Widget.withTextDirection`, and `safeDisplayText` for unpaired surrogates.
- `@MREPreview()` annotation to preview any widget in light, dark, right to left, large text, narrow and wide layouts.
