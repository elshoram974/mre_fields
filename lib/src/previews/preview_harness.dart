import 'package:flutter/material.dart';

/// Shared wrapper for Widget Previewer and local sandbox screens.
///
/// When [MreFieldsTheme] exists, register it on [theme.extensions].
ThemeData mreFieldsPreviewTheme({Brightness brightness = Brightness.light}) {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF005F73),
      brightness: brightness,
    ),
    useMaterial3: true,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}
