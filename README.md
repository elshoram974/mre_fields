# mre_fields

Form field widgets for Flutter: text that follows its language, phone numbers
with country codes, and suggestions. Fields use your `ThemeData`, and every
value can be changed globally or per field.

> Early release (`0.x`). The public API can change; see
> [CHANGELOG.md](CHANGELOG.md).

## Contents

- [Available now](#available-now)
- [Install](#install)
- [Theming](#theming) — guide: [doc/theme.md](doc/theme.md)
- [Text direction](#text-direction) — guide: [doc/text.md](doc/text.md)
- [Planned](#planned)
- [Development](#development)

## Available now

| Piece | What it does |
|---|---|
| `MREFieldsTheme` | Radius, padding, breakpoints and texts, set once on your `ThemeData` |
| `MREFieldsStrings` | Every text a field shows, ready for translation |
| `MREAutoText` | `Text` that reads right to left or left to right from its content |
| `detectTextDirection`, `MRETextDirection` | Direction of a string, as a function or as getters |
| `MREDirectionalWidget.withTextDirection` | Gives any widget the direction of a text |
| `safeDisplayText` | Removes broken characters that make Flutter throw |

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

## Planned

| Piece | Role |
|---|---|
| `MRETextField` | Text field with live direction, clear button, suggestions, optional image paste |
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
