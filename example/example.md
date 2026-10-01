# mre_fields example

A small app that shows every piece of the package. The code below is what each
card in the app is built from.

```bash
cd example
flutter run   # phone, desktop or web
```

The app bar has a light and dark switch and an English and Arabic switch. A
slider changes the field radius for the whole app through `MREFieldsTheme`.

![Typing English and Arabic: the field and the text under it change direction](https://raw.githubusercontent.com/elshoram974/mre_fields/main/doc/images/text-direction.gif)

## 1. Register the theme once

Do this where you build your `MaterialApp`. Register it on both themes so dark
mode keeps the values.

<!-- snippet: theme/light_dark -->
```dart
const fields = MREFieldsTheme(fieldBorderRadius: 16);

final app = MaterialApp(
  theme: ThemeData(extensions: const [fields]),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [fields],
  ),
  home: const HomePage(),
);
```

## 2. Text that follows its language

`MREAutoText` takes every parameter of `Text`. The first word with a letter
decides the direction, so `123 مرحبا` is right to left and `(#1) Hello` is left
to right.

<!-- snippet: text/auto_text -->
```dart
final column = Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: const [
    MREAutoText('مرحبا بالعالم'), // reads right to left
    MREAutoText('Hello world'), // reads left to right
    MREAutoText('مرحبا', textDirection: TextDirection.ltr), // fixed
  ],
);
```

Already have a `Text`? Add the direction and the alignment to it:

<!-- snippet: text/text_extension -->
```dart
final text = Text(
  name,
  style: const TextStyle(fontSize: 20),
).autoDirection().autoAlign();
```

## 3. A field that follows the language

<!-- snippet: text_field/basic -->
```dart
final field = MRETextField(
  labelText: 'Name',
  hintText: 'Type in any language',
  showClearButton: true,
);
```

Lock the direction for emails, links and numbers:

<!-- snippet: text_field/lock_direction -->
```dart
final email = MRETextField(
  labelText: 'Email',
  keyboardType: TextInputType.emailAddress,
  textDirection: TextDirection.ltr,
);
```

## 4. Suggestions and select on focus

<!-- snippet: text_field/suggestions -->
```dart
final field = MRETextField(
  labelText: 'City',
  suggestions: const ['Cairo', 'Alexandria', 'Giza', 'القاهرة'],
  maxSuggestions: 5,
);
```

<!-- snippet: text_field/select_on_focus -->
```dart
final field = MRETextField(
  labelText: 'Title',
  initialValue: 'Draft',
  selectTextOnFocus: true,
);
```

## 5. Validation in a form

<!-- snippet: text_field/form -->
```dart
final form = Form(
  key: formKey,
  child: MRETextField(
    labelText: 'Name',
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Enter a name';
      }
      return null;
    },
  ),
);
```

## 6. Change one field

A parameter beats the theme for that field only.

<!-- snippet: theme/one_field -->
```dart
final field = MRETextField(
  labelText: 'Search',
  borderRadius: 28, // this field only; the theme keeps its own radius
  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
);
```

## 7. Paste images

![Pasting three images into a field](https://raw.githubusercontent.com/elshoram974/mre_fields/main/doc/images/image-paste.gif)

A field takes one of three behaviours: nothing, a callback with the image, or
thumbnails under the field with open, remove and replace.

<!-- snippet: attachments/behaviors -->
```dart
// Text only. This is the default.
const textOnly = MRETextField(labelText: 'Message');

// Your code gets each image. Nothing is shown.
final callback = MRETextField(
  labelText: 'Message',
  imagePaste: MREImageCallbackPaste(
    onImagePasted: (image) => upload(image.bytes),
  ),
);

// Images appear under the field.
const attachments = MRETextField(
  labelText: 'Message',
  imagePaste: MREImageAttachmentPaste(),
);
```

Read and change the images from your own code:

<!-- snippet: attachments/controller -->
```dart
// Create the controller in initState and dispose it in dispose.
final field = MRETextField(
  labelText: 'Message',
  imagePaste: MREImageAttachmentPaste(controller: controller),
);

// Later: controller.images, controller.removeAt(0), controller.clear().
```

## 8. Translate the texts

Every text a field shows is in `MREFieldsStrings`.

<!-- snippet: theme/strings -->
```dart
/// Returns the field texts for [locale]. English is the fallback.
MREFieldsStrings stringsFor(Locale locale) {
  return switch (locale.languageCode) {
    'ar' => const MREFieldsStrings(
      clearTooltip: 'مسح',
      countryPickerTitle: 'اختر الدولة',
      countrySearchHint: 'ابحث عن دولة أو رمز',
      noCountriesFound: 'لا توجد دول',
      removeImageTooltip: 'إزالة الصورة',
      replaceImageTooltip: 'استبدال الصورة',
      closeViewerTooltip: 'إغلاق',
    ),
    _ => const MREFieldsStrings(),
  };
}

/// Swaps the strings whenever the app locale changes.
Widget localizedFields(BuildContext context, Widget child) {
  final theme = Theme.of(context);
  final fields = MREFieldsTheme.of(
    context,
  ).copyWith(strings: stringsFor(Localizations.localeOf(context)));

  return Theme(
    data: theme.copyWith(
      extensions: [
        ...theme.extensions.values.where((e) => e is! MREFieldsTheme),
        fields,
      ],
    ),
    child: child,
  );
}

Widget localizedApp() {
  return MaterialApp(
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('en'), Locale('ar')],
    builder: (context, child) => localizedFields(context, child!),
    home: const HomePage(),
  );
}
```

## 9. Use the rules without a widget

<!-- snippet: functions/direction_functions -->
```dart
final direction = detectTextDirection(name, fallback: TextDirection.ltr);
final strong = detectStrongTextDirection(name); // null when no letter
final side = name.autoTextAlign;
```

<!-- snippet: functions/sanitize -->
```dart
final clean = safeDisplayText(pasted); // lone surrogates become U+FFFD
```

<!-- snippet: functions/filter -->
```dart
const cities = ['Cairo', 'Alexandria', 'Giza', 'Luxor', 'Aswan'];
final matches = mreFilterSuggestions(cities, query, limit: 3);
```

<!-- snippet: functions/sniff -->
```dart
final type = mreSniffImageMimeType(
  upload,
); // 'image/png', 'image/jpeg', ... or null
final isPng = type == 'image/png';
```

## More

- [Package page](https://pub.dev/packages/mre_fields)
- [API reference](https://pub.dev/documentation/mre_fields/latest/)
- [Source](https://github.com/elshoram974/mre_fields)
