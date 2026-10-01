import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

import '../sections/phone_result.dart';
import 'demo_frame.dart';

/// Typing, pasting and picking a phone number. This page is recorded for the
/// documentation.
class PhoneDemo extends StatefulWidget {
  /// Creates the page.
  const PhoneDemo({super.key});

  @override
  State<PhoneDemo> createState() => _PhoneDemoState();
}

class _PhoneDemoState extends State<PhoneDemo> {
  MREPhoneNumber? _number;

  @override
  Widget build(BuildContext context) {
    return DemoFrame(
      title: 'Phone number',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          MREPhoneField(
            labelText: 'MREPhoneField',
            initialCountry: MRECountries.byIsoCode('EG'),
            showClearButton: true,
            required: false,
            onChanged: (number) => setState(() => _number = number),
          ),
          PhoneResult(number: _number),
        ],
      ),
    );
  }
}
