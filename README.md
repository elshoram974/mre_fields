# mre_fields

![A text field and a plain text follow the language being typed: left to right for English, right to left for Arabic](https://raw.githubusercontent.com/elshoram974/mre_fields/main/doc/images/text-direction.gif)

Form field widgets for Flutter: text that follows its language, image paste, and
suggestions. Fields use your `ThemeData`, and every value can be changed
globally or per field.

> Early release (`0.x`). The public API can change; see
> [CHANGELOG.md](CHANGELOG.md).

## Try it

```bash
cd example
flutter run   # any device: phone, desktop or web
```

## Contents

- [What is inside](#what-is-inside)
- [Use the functions without a widget](#use-the-functions-without-a-widget)
- [Install](#install)
- [Theming](#theming) — guide: [doc/theme.md](doc/theme.md)
- [Text direction](#text-direction) — guide: [doc/text.md](doc/text.md)
- [Text field](#text-field) — guide: [doc/text_field.md](doc/text_field.md)
- [Image paste](#image-paste) — guide: [doc/attachments.md](doc/attachments.md)
- [Planned](#planned)
- [Development](#development)

## What is inside

| Name | Kind | Use it for |
|---|---|---|
| `MRETextField` | widget | A form field that follows the language typed, with clear button, suggestions, select on focus and image paste |
| `MREAutoText` | widget | A `Text` that reads right to left or left to right from its content |
| `MREFieldsTheme`, `MREFieldsStrings` | theme classes | Radius, padding, breakpoints and every text, set once on your `ThemeData` |
| `MREImageAttachmentPaste`, `MREImageCallbackPaste`, `MRENoImagePaste` | behaviours | What a field does with a pasted image |
| `MREAttachmentStrip`, `MREImageViewer`, `MRESuggestionBar`, `MREFieldClearButton` | widgets | The field's pieces, usable in any field |
| `MREImagePasteScope` | widget | Image paste for any `TextField` |
| `Text.autoDirection()`, `Text.autoAlign()`, `Widget.withTextDirection()` | extensions | Direction and alignment on widgets you already have |
| `detectTextDirection`, `detectStrongTextDirection`, `String.isRtl` and friends | functions | The direction of a string, in code with no widget |
| `safeDisplayText`, `MRESafeTextEditingController` | function, class | Remove broken characters that make Flutter throw |
| `mreFilterSuggestions`, `mreSniffImageMimeType` | functions | Filter suggestions, and tell an image type from its bytes |
| `MREAttachmentsController`, `MREPastedImage`, `MREClipboardImageReader` | classes | Hold and read images from your own code |

The functions and classes need no widget on screen. See
[doc/functions.md](doc/functions.md) for the full list with examples.

## Use the functions without a widget

```dart
detectTextDirection('مرحبا');            // TextDirection.rtl
'123 hello'.isRtl;                       // false, the first word with a letter is English
mreFilterSuggestions(cities, 'al');      // the cities that contain "al"
mreSniffImageMimeType(bytes);            // 'image/png', 'image/jpeg', ... or null
```

## Install

```yaml
dependencies:
  mre_fields: ^0.1.0
```

```dart
import 'package:mre_fields/mre_fields.dart';
```

## Theming

Colors and fonts come from your `ThemeData`. Register the field values on it:

```dart
MaterialApp(
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

Order of priority: a widget parameter, then `MREFieldsTheme`, then the default.
Dark mode, breakpoints and translated texts are in [doc/theme.md](doc/theme.md).

## Text direction

```dart
const MREAutoText('مرحبا بالعالم'); // right to left
const MREAutoText('Hello world'); // left to right

detectTextDirection('123 مرحبا'); // TextDirection.rtl
```

More in [doc/text.md](doc/text.md).

## Text field

```dart
MRETextField(
  labelText: 'Name',
  showClearButton: true,
  suggestions: const ['Cairo', 'Alexandria', 'القاهرة'],
);
```

The direction follows the first word with a letter as the user types. Every
value can be set for one field, through `MREFieldsTheme`, or left to your
`ThemeData`. More in [doc/text_field.md](doc/text_field.md).

## Image paste

A field pastes text only, unless you give it a behaviour:

```dart
MRETextField(
  labelText: 'Message',
  imagePaste: MREImageAttachmentPaste(
    maxImages: 4,
    onImagesChanged: (images) => attached = images,
  ),
);
```

![Pasting three images into a field: they appear under it, each with remove and replace buttons](https://raw.githubusercontent.com/elshoram974/mre_fields/main/doc/images/image-paste.gif)

Images appear under the field. The user can open, remove and replace them.
`MREImageCallbackPaste` hands each image to your code and shows nothing. Images
arrive through the paste shortcut (desktop), the browser paste event (web), the
selection menu (every platform) and the on-screen keyboard (Android). Details in
[doc/attachments.md](doc/attachments.md).

## Planned

| Piece | Role |
|---|---|
| `MREPhoneField` | Dial code and local number, validation for every country |
| `MRECountryCodePicker` | Searchable country list |

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter widget-preview start
```

Every widget can be previewed. Add `@MREPreview()` to a top-level function that
returns the widget, and the previewer shows it in light, dark, right to left,
large text, narrow and wide.

## License

BSD 3-Clause. See [LICENSE](LICENSE).
