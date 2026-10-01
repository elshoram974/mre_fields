import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

import 'demo_frame.dart';

/// Typing in any language: the field and a plain text follow the first word
/// that has a letter. This page is recorded for the documentation.
class TextDemo extends StatefulWidget {
  /// Creates the page.
  const TextDemo({super.key});

  @override
  State<TextDemo> createState() => _TextDemoState();
}

class _TextDemoState extends State<TextDemo> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoFrame(
      title: 'mre_fields',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          MRETextField(
            controller: _controller,
            labelText: 'MRETextField',
            hintText: 'Type in any language',
            showClearButton: true,
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => _Mirror(text: value.text),
          ),
        ],
      ),
    );
  }
}

/// The same text in a plain [MREAutoText], and the direction it found.
class _Mirror extends StatelessWidget {
  const _Mirror({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final direction = detectStrongTextDirection(text);
    final label = switch (direction) {
      TextDirection.rtl => 'right to left',
      TextDirection.ltr => 'left to right',
      null => 'no letter yet',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            'MREAutoText · $label',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          MREAutoText(
            text.isEmpty ? '…' : text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
