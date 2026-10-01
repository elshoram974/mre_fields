import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

/// What `MREPhoneNumber` found in the number: the country, the formats and
/// whether it is valid, or why it is not.
class PhoneResult extends StatelessWidget {
  /// Creates the result for [number].
  const PhoneResult({super.key, required this.number});

  /// The number to describe, or null before the user typed anything.
  final MREPhoneNumber? number;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final current = number;
    final valid = current?.isValid ?? false;

    final lines = [
      'Country: ${current?.country?.name ?? '-'}',
      'International: ${valid ? current!.international : '-'}',
      'E.164: ${current?.e164 ?? '-'}',
      valid
          ? 'Valid'
          : 'Problem: ${current?.error?.name ?? 'nothing typed yet'}',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (valid ? scheme.primaryContainer : scheme.secondaryContainer)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          for (final line in lines)
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(line, style: text.bodyMedium),
            ),
        ],
      ),
    );
  }
}
