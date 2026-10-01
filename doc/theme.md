Fields take colors and fonts from your `ThemeData`. `MREFieldsTheme` adds the
values Material does not have: corner radius, padding, breakpoints and texts.

## Change it for the whole app

Register the extension on your theme. Every field below it uses these values.

<!-- snippet: global -->
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

## Change one value

Start from the defaults and replace only what you need.

<!-- snippet: copy_with -->
```dart
final tokens = MREFieldsTheme.defaults.copyWith(fieldBorderRadius: 4);
```

## Change one field

A parameter on the widget beats the theme for that field only.

<!-- snippet: one_field -->
```dart
final field = MRETextField(
  labelText: 'Search',
  borderRadius: 28, // this field only; the theme keeps its own radius
  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
);
```

## Dark mode

Register the extension on **both** themes. A theme without it falls back to the
defaults.

<!-- snippet: light_dark -->
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

## Breakpoints

A field measures the width it really gets and picks a size.

| Width | Size | Content padding |
|---|---|---|
| below 600 | `MREWindowSize.compact` | `contentPadding` |
| 600 to 839 | `MREWindowSize.medium` | `contentPadding` |
| 840 and up | `MREWindowSize.expanded` | `expandedContentPadding` |

Move the limits:

<!-- snippet: breakpoints -->
```dart
const tokens = MREFieldsTheme(
  compactBreakpoint: 480,
  expandedBreakpoint: 1024,
);
```

## Use the tokens in your own widget

<!-- snippet: read_tokens -->
```dart
/// A custom widget that follows the same tokens and breakpoints as the fields.
class AdaptiveBox extends StatelessWidget {
  /// Creates the box.
  const AdaptiveBox({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = MREFieldsTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = tokens.windowSizeFor(constraints.maxWidth);

        return Padding(
          padding: tokens.contentPaddingFor(size),
          child: Text('Window size: ${size.name}'),
        );
      },
    );
  }
}
```

## Translate the texts

Every text a field shows is in `MREFieldsStrings`, in English by default. Swap
it when the app locale changes:

<!-- snippet: strings -->
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

Add `localizationsDelegates` and `supportedLocales` as in your app. Without a
supported locale, Flutter resolves back to English.
