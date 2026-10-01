import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mre_fields/mre_fields.dart';

import 'demos/demo_pages.dart';
import 'example_settings.dart';
import 'pages/home_page.dart';

/// The seed of the demo color scheme.
const _seedColor = Color(0xFF005F73);

/// The demo app. It registers [MREFieldsTheme] once, on both themes, the way a
/// host app does.
class ExampleApp extends StatefulWidget {
  /// Creates the app.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _settings = ExampleSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  ThemeData _theme(Brightness brightness) {
    return ThemeData(
      colorSchemeSeed: _seedColor,
      brightness: brightness,
      extensions: [
        MREFieldsTheme(
          fieldBorderRadius: _settings.radius,
          strings: _settings.strings,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'mre_fields',
          debugShowCheckedModeBanner: false,
          themeMode: _settings.themeMode,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          locale: _settings.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: demoPageFromUrl() ?? HomePage(settings: _settings),
        );
      },
    );
  }
}
