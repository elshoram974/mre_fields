# mre_fields

[![pub package](https://img.shields.io/pub/v/mre_fields.svg)](https://pub.dev/packages/mre_fields)
[![pub points](https://img.shields.io/pub/points/mre_fields)](https://pub.dev/packages/mre_fields/score)
[![CI](https://github.com/elshoram974/mre_fields/actions/workflows/ci.yml/badge.svg)](https://github.com/elshoram974/mre_fields/actions/workflows/ci.yml)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)

Text fields and texts for Flutter that **follow the language being typed**:
Arabic reads from the right, English from the left, with no code from you.
Paste images into a field, suggest values, and theme everything from your own
`ThemeData`.

![A text field and a plain text follow the language being typed: left to right for English, right to left for Arabic](https://raw.githubusercontent.com/elshoram974/mre_fields/main/doc/images/text-direction.gif)

## Why use it

- **Right direction, automatically.** The first word with a letter decides.
  Numbers and symbols before it are skipped, so `123 مرحبا` is right to left.
- **Works with your theme.** Colors and fonts come from your `ThemeData`. Set a
  value once for the whole app, or for a single field.
- **Ready for translation.** Every text a field shows can be replaced.
- **Pieces, not a black box.** Every rule is also a plain function or widget you
  can use alone.
- **Six platforms.** Android, iOS, web, macOS, Windows and Linux. CI builds the
  example on all of them with the latest stable Flutter.

## Install

```yaml
dependencies:
  mre_fields: ^0.1.1
```

```dart
import 'package:mre_fields/mre_fields.dart';
```

## Quick start

**1. Register the theme once.** Skip this to use the defaults.

<!-- snippet: theme/global -->
```dart
final app = MaterialApp(
  theme: ThemeData(
    extensions: const [
      MREFieldsTheme(
        fieldBorderRadius: 16,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ],
  ),
  home: const HomePage(),
);
```

**2. Use a field.** It changes direction as the user types.

<!-- snippet: text_field/basic -->
```dart
final field = MRETextField(
  labelText: 'Name',
  hintText: 'Type in any language',
  showClearButton: true,
);
```

**3. Optional: let users paste images.**

<!-- snippet: attachments/quick -->
```dart
final field = MRETextField(
  labelText: 'Message',
  maxLines: 3,
  imagePaste: MREImageAttachmentPaste(maxImages: 4),
);
```

![Pasting three images into a field: they appear under it, each with remove and replace buttons](https://raw.githubusercontent.com/elshoram974/mre_fields/main/doc/images/image-paste.gif)

Run the example app to try everything:

```bash
cd example
flutter run   # any device: phone, desktop or web
```

## What you can do

| I want to... | Use | Guide |
|---|---|---|
| Show text in its own direction | `MREAutoText`, `Text.autoDirection()` | [Text direction](doc/text.md) |
| A form field that follows the language | `MRETextField` | [Text field](doc/text_field.md) |
| Suggestions and a clear button | `MRETextField(suggestions:, showClearButton:)` | [Text field](doc/text_field.md) |
| Paste images into a field | `MRETextField(imagePaste:)` | [Image paste](doc/attachments.md) |
| Change radius, padding and texts everywhere | `MREFieldsTheme`, `MREFieldsStrings` | [Theme](doc/theme.md) |
| Use the rules with no widget | `detectTextDirection`, `safeDisplayText`, `mreFilterSuggestions`, `mreSniffImageMimeType` | [Functions](doc/functions.md) |
| Give any `TextField` image paste | `MREImagePasteScope` | [Image paste](doc/attachments.md) |

### Use the functions without a widget

<!-- snippet: functions/quick -->
```dart
final direction = detectTextDirection('مرحبا'); // TextDirection.rtl
final isRtl = '123 hello'.isRtl; // false
final cities = mreFilterSuggestions(allCities, 'ai'); // ['Cairo']
final type = mreSniffImageMimeType(bytes); // 'image/png' or null
```

## Change one field, or all of them

Order of priority: a widget parameter, then `MREFieldsTheme`, then your
`InputDecorationTheme`, then the default.

<!-- snippet: theme/one_field -->
```dart
final field = MRETextField(
  labelText: 'Search',
  borderRadius: 28, // this field only; the theme keeps its own radius
  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
);
```

Dark mode, breakpoints and translated texts are in [the theme guide](doc/theme.md).

## Platform support

| Platform | Text direction and field | Images arrive through |
|---|---|---|
| Android | yes | selection menu, on-screen keyboard (stickers, GIFs, images) |
| iOS | yes | selection menu |
| Web | yes | browser paste event (Ctrl or Cmd + V), selection menu |
| macOS, Windows, Linux | yes | paste shortcut, selection menu |

Needs Flutter 3.38 or newer. The package also compiles to WebAssembly.

## Questions

**Which languages count as right to left?** Every right-to-left script:
Arabic, Hebrew, Persian, Urdu, Pashto, Kurdish (Sorani), Syriac, Thaana, N'Ko
and more.

**What if I want a fixed direction?** Set `textDirection` on the field, for
example `TextDirection.ltr` for emails and links.

**Does it work inside a `Form`?** Yes. `MRETextField` takes a `validator`, an
`onSaved` and a `fieldKey` like `TextFormField`.

**Does image paste need permissions?** Not on the web: the browser gives the
image in its paste event. Mobile systems may show their own notice when an app
reads the clipboard.

**Can I replace the English texts?** Yes. Pass your own `MREFieldsStrings` in
`MREFieldsTheme`. See [the theme guide](doc/theme.md).

## Documentation

- [API reference](https://pub.dev/documentation/mre_fields/latest/)
- Guides: [theme](doc/theme.md), [text direction](doc/text.md),
  [text field](doc/text_field.md), [image paste](doc/attachments.md),
  [functions](doc/functions.md)
- [Example app](example/example.md) and [changelog](CHANGELOG.md)

## Coming next

A phone number field with a country picker and validation for every country.

## Contributing

```bash
flutter pub get
flutter analyze
flutter test
flutter widget-preview start   # preview any widget with @MREPreview()
```

## License

BSD 3-Clause. See [LICENSE](LICENSE).
