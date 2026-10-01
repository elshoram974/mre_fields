import 'package:flutter/material.dart';

import '../theme/mre_fields_theme.dart';

/// Shared wrapper for Widget Previewer and local sandbox screens.
///
/// Builds a plain Material theme with [MREFieldsTheme] registered, to show
/// that the fields inherit the host color scheme.
ThemeData mreFieldsPreviewTheme({Brightness brightness = Brightness.light}) {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF005F73),
      brightness: brightness,
    ),
    useMaterial3: true,
    extensions: const [MREFieldsTheme()],
  );
  return base;
}

/// Pads [child] like a form row so unconstrained fields don't fill the preview.
Widget mreFieldsPreviewScaffold(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: mreFieldsPreviewTheme(),
    darkTheme: mreFieldsPreviewTheme(brightness: Brightness.dark),
    home: Scaffold(
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}
