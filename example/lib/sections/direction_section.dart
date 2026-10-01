import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

import 'section_card.dart';

/// Texts that show how the first word with a letter decides the direction.
const _samples = [
  'Hello world',
  'مرحبا بالعالم',
  '123 مرحبا',
  '(#1) Hello',
  'مرحبا Hello',
  '12345',
];

/// A field and a plain text that follow what is typed.
class DirectionSection extends StatefulWidget {
  /// Creates the section.
  const DirectionSection({super.key});

  @override
  State<DirectionSection> createState() => _DirectionSectionState();
}

class _DirectionSectionState extends State<DirectionSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Text direction',
      subtitle:
          'The first word with a letter decides. Digits and symbols before it '
          'are skipped.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          MRETextField(
            controller: _controller,
            labelText: 'MRETextField',
            hintText: 'Type in any language',
            showClearButton: true,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sample in _samples)
                ActionChip(
                  label: MREAutoText(sample),
                  onPressed: () => _controller.text = sample,
                ),
            ],
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => _Result(text: value.text),
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final direction = detectStrongTextDirection(text);

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
            'MREAutoText · ${direction?.name ?? 'no letter yet'}',
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
