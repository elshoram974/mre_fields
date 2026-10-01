import 'package:flutter/material.dart';

import '../example_settings.dart';
import '../sections/direction_section.dart';
import '../sections/field_section.dart';
import '../sections/image_paste_section.dart';
import '../sections/theme_section.dart';

/// Widest the page gets, so cards stay readable on a desktop window.
const double _maxContentWidth = 760;

/// The demo home page: one card per feature.
class HomePage extends StatelessWidget {
  /// Creates the page.
  const HomePage({super.key, required this.settings});

  /// Theme, language and radius.
  final ExampleSettings settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mre_fields'),
        actions: [
          IconButton(
            tooltip: 'Light or dark',
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => settings.toggleDark(context),
          ),
          IconButton(
            tooltip: 'English or Arabic',
            icon: const Icon(Icons.translate),
            onPressed: settings.toggleLanguage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              spacing: 16,
              children: [
                const DirectionSection(),
                const FieldSection(),
                const ImagePasteSection(),
                ThemeSection(settings: settings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
