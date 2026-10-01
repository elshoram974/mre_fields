# mre_fields

[![pub package](https://img.shields.io/pub/v/mre_fields.svg)](https://pub.dev/packages/mre_fields)
[![pub points](https://img.shields.io/pub/points/mre_fields)](https://pub.dev/packages/mre_fields/score)
[![CI](https://github.com/elshoram974/mre_fields/actions/workflows/ci.yml/badge.svg)](https://github.com/elshoram974/mre_fields/actions/workflows/ci.yml)
[![Flutter 3.38.1+](https://img.shields.io/badge/Flutter-%E2%89%A5%203.38.1-02569B?logo=flutter&logoColor=white)](#platform-support)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)

Form fields for Flutter that handle what people really type: **Arabic and
English in the same field**, **phone numbers from any country**, and **pasted
images**. Everything uses your own `ThemeData` and can be translated.

![A text field and a plain text follow the language being typed: left to right for English, right to left for Arabic](https://raw.githubusercontent.com/elshoram974/mre_fields/main/doc/images/text-direction.gif)

## What you get

- **Direction and alignment that follow the language.** Type Arabic and the text
  starts from the right; type English and it starts from the left. It also works
  for a plain `Text`, and on widgets you already have.
- **A phone field that checks every country.** 245 countries and regions, a
  searchable country picker, and a clear message for each problem. Paste
  `+20 101 234 5678` and the country switches to Egypt on its own.
- **Choose which countries are accepted.** Allow only some, drop some, pin
  favorites. The picker, the paste and the validation all follow the same list.
- **Paste images into a field.** Keep them under the field with open, remove and
  replace, or hand them to your code.
- **One theme, one place for texts.** Radius and padding for every field in one
  spot, every text and error message replaceable for translation.
- **Pieces you can use alone.** The rules are plain functions and classes:
  parse a phone number, detect a direction or filter suggestions with no widget.
- **Six platforms.** Android, iOS, web, macOS, Windows and Linux.

## Install

```yaml
dependencies:
  mre_fields: ^0.2.0
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

**2. A text field that follows the language.**

<!-- snippet: text_field/basic -->
```dart
final field = MRETextField(
  labelText: 'Name',
  hintText: 'Type in any language',
  showClearButton: true,
);
```

**3. A phone field.** `number.e164` is the number to save, `null` until it is valid.

<!-- snippet: phone/basic -->
```dart
final field = MREPhoneField(
  labelText: 'Phone number',
  onChanged: (number) {
    if (number.isValid) {
      saveNumber(number.e164!); // '+201012345678'
    }
  },
);
```

![Typing, pasting and picking a phone number: the flag and dial code follow, and the number is checked](https://raw.githubusercontent.com/elshoram974/mre_fields/main/doc/images/phone-field.gif)

**4. Optional: let users paste images.**

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
| Ask for a phone number | `MREPhoneField` | [Phone](doc/phone.md) |
| Accept only some countries | `MRECountrySelection` | [Phone](doc/phone.md) |
| Validate a phone number in any field | `MREPhoneValidators.valid` | [Phone](doc/phone.md) |
| Paste images into a field | `MRETextField(imagePaste:)` | [Image paste](doc/attachments.md) |
| Change radius, padding and texts everywhere | `MREFieldsTheme`, `MREFieldsStrings` | [Theme](doc/theme.md) |
| Use the rules with no widget | `MREPhoneNumber.parse`, `detectTextDirection`, `mreFilterSuggestions` | [Functions](doc/functions.md) |

### Choose the countries

<!-- snippet: phone/selection -->
```dart
const selection = MRECountrySelection(
  include: {'SA', 'AE', 'KW', 'QA', 'BH', 'OM'},
  favorites: ['SA', 'AE'],
  initial: 'SA',
);

final field = MREPhoneField(selection: selection);
```

### Read a phone number in code

<!-- snippet: phone/parse -->
```dart
final number = MREPhoneNumber.parse('+20 101 234 5678');

final country = number.country!.name; // 'Egypt'
final e164 = number.e164; // '+201012345678'
final nice = number.international; // '+20 10 12345678'
final valid = number.isValid; // true
```

### The other rules without a widget

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

| Platform | Text direction, text field, phone | Images arrive through |
|---|---|---|
| Android | yes | selection menu, on-screen keyboard (stickers, GIFs, images) |
| iOS | yes | selection menu |
| Web | yes | browser paste event (Ctrl or Cmd + V), selection menu |
| macOS, Windows, Linux | yes | paste shortcut, selection menu |

Needs Flutter 3.38.1 or newer (Dart 3.10). CI runs the tests on 3.38.1, on the
latest stable and on beta, and builds the example on every platform. The package
also compiles to WebAssembly.

## Questions

**How is the direction chosen?** The first word with a letter decides. Numbers
and symbols before it are skipped, so `123 مرحبا` is right to left and
`(#1) Hello` is left to right. A text with no letter keeps the surrounding
direction.

**Which languages count as right to left?** Every right-to-left script:
Arabic, Hebrew, Persian, Urdu, Pashto, Kurdish (Sorani), Syriac, Thaana, N'Ko
and more.

**Where do the phone rules come from?** The libphonenumber data, through the
[phone_numbers_parser](https://pub.dev/packages/phone_numbers_parser) package.
Your code uses `MREPhoneNumber`, so it does not depend on it.

**Can I show country names in my language?** Yes. Pass `countryNameBuilder` to
the phone field and your texts through `MREFieldsStrings`. See
[the phone guide](doc/phone.md).

**What if I want a fixed direction?** Set `textDirection` on the field, for
example `TextDirection.ltr` for emails and links.

**Does it work inside a `Form`?** Yes. `MRETextField` and `MREPhoneField` take a
`validator`, an `onSaved` and a `fieldKey` like `TextFormField`.

**Does image paste need permissions?** Not on the web: the browser gives the
image in its paste event. Mobile systems may show their own notice when an app
reads the clipboard.

## Documentation

- [API reference](https://pub.dev/documentation/mre_fields/latest/)
- Guides: [theme](doc/theme.md), [text direction](doc/text.md),
  [text field](doc/text_field.md), [phone](doc/phone.md),
  [image paste](doc/attachments.md), [functions](doc/functions.md)
- [Example app](example/example.md) and [changelog](CHANGELOG.md)

## Contributing

```bash
flutter pub get
flutter analyze
flutter test
flutter widget-preview start   # preview any widget with @MREPreview()
```

## License

BSD 3-Clause. See [LICENSE](LICENSE).
