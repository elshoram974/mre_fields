import 'package:flutter/material.dart';

/// Width of the demo card.
const double _demoWidth = 440;

/// Space above the card. The card is top-aligned so it does not move while a
/// recording grows it.
const double _demoTop = 40;

/// A top-aligned card with a [title], used by the recorded demo pages.
class DemoFrame extends StatelessWidget {
  /// Creates a frame around [child].
  const DemoFrame({super.key, required this.title, required this.child});

  /// Heading of the card.
  final String title;

  /// The demo content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: _demoTop),
          child: SizedBox(
            width: _demoWidth,
            child: Card(
              elevation: 0,
              color: scheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
