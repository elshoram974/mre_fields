import 'package:flutter/material.dart';

import '../example_settings.dart';
import 'section_card.dart';

/// The most the radius slider can reach.
const double _maxRadius = 28;

/// Changes the field radius for the whole app through `MREFieldsTheme`.
class ThemeSection extends StatelessWidget {
  /// Creates the section for [settings].
  const ThemeSection({super.key, required this.settings});

  /// The settings the slider changes.
  final ExampleSettings settings;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Theme',
      subtitle:
          'One value in MREFieldsTheme changes every field. Colors and fonts '
          'come from your ThemeData.',
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => Row(
          children: [
            const Text('Radius'),
            Expanded(
              child: Slider(
                value: settings.radius,
                max: _maxRadius,
                divisions: _maxRadius.toInt(),
                label: settings.radius.round().toString(),
                onChanged: (value) => settings.radius = value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
