import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

import 'phone_result.dart';
import 'section_card.dart';

/// Numbers to paste, each showing something different.
const _samples = [
  '+20 101 234 5678',
  '+966 50 123 4567',
  '+1 204 555 1234',
  '00971 50 123 4567',
  '+20 101',
  '+999 123 456',
];

/// A phone field, numbers to paste, and a field that accepts the Gulf only.
class PhoneSection extends StatefulWidget {
  /// Creates the section.
  const PhoneSection({super.key});

  @override
  State<PhoneSection> createState() => _PhoneSectionState();
}

class _PhoneSectionState extends State<PhoneSection> {
  final _controller = MREPhoneController(country: MRECountries.byIsoCode('EG'));
  MREPhoneNumber? _number;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Phone number',
      subtitle:
          'Checked for every country. Paste a number with its dial code and the '
          'country follows.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          MREPhoneField(
            controller: _controller,
            labelText: 'Phone number',
            showClearButton: true,
            onChanged: (number) => setState(() => _number = number),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sample in _samples)
                ActionChip(
                  label: Text(sample),
                  // A number that arrives in one piece is read as a paste.
                  onPressed: () => _controller.text.text = sample,
                ),
            ],
          ),
          PhoneResult(number: _number),
          const Divider(),
          const MREPhoneField(
            labelText: 'Gulf numbers only',
            selection: MRECountrySelection(
              include: {'SA', 'AE', 'KW', 'QA', 'BH', 'OM'},
              favorites: ['SA', 'AE'],
              initial: 'SA',
            ),
          ),
        ],
      ),
    );
  }
}
