// Snippets embedded in the API docs and the theme guide. They are analyzed
// and run in test/doc/theme_snippets_test.dart, so each example is correct.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mre_fields/mre_fields.dart';

/// Registers the field tokens once for the whole app.
Widget globalTheme() {
  // #region global
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
  // #endregion global

  return app;
}

/// Changes one field and leaves the theme as it is.
Widget oneFieldOverride() {
  // #region one_field
  final field = MRETextField(
    labelText: 'Search',
    borderRadius: 28, // this field only; the theme keeps its own radius
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );
  // #endregion one_field

  return field;
}

/// Changes one token and keeps every other default.
MREFieldsTheme squarerFields() {
  // #region copy_with
  final tokens = MREFieldsTheme.defaults.copyWith(fieldBorderRadius: 4);
  // #endregion copy_with

  return tokens;
}

/// Registers the tokens on both themes, so dark mode keeps them too.
Widget lightAndDark() {
  // #region light_dark
  const fields = MREFieldsTheme(fieldBorderRadius: 16);

  final app = MaterialApp(
    theme: ThemeData(extensions: const [fields]),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      extensions: const [fields],
    ),
    home: const HomePage(),
  );
  // #endregion light_dark

  return app;
}

/// Moves the window-size breakpoints.
MREFieldsTheme customBreakpoints() {
  // #region breakpoints
  const tokens = MREFieldsTheme(
    compactBreakpoint: 480,
    expandedBreakpoint: 1024,
  );
  // #endregion breakpoints

  return tokens;
}

// #region strings
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
// #endregion strings

// #region read_tokens
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
// #endregion read_tokens

/// Stand-in for the app's first screen.
class HomePage extends StatelessWidget {
  /// Creates the page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: AdaptiveBox());
}
