import 'package:flutter/material.dart';

/// A titled card that holds one demo.
class SectionCard extends StatelessWidget {
  /// Creates a card with a [title], a short [subtitle] and the demo [child].
  const SectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  /// What the demo shows.
  final String title;

  /// How to try it.
  final String subtitle;

  /// The demo itself.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(title, style: text.titleMedium),
            Text(subtitle, style: text.bodyMedium),
            child,
          ],
        ),
      ),
    );
  }
}
