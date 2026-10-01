import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

import 'section_card.dart';

/// Suggestions for the city field.
const _cities = ['Cairo', 'Alexandria', 'Giza', 'Luxor', 'Aswan', 'القاهرة'];

/// The field's features: clear, validation, locked direction, suggestions and
/// select on focus.
class FieldSection extends StatefulWidget {
  /// Creates the section.
  const FieldSection({super.key});

  @override
  State<FieldSection> createState() => _FieldSectionState();
}

class _FieldSectionState extends State<FieldSection> {
  final _formKey = GlobalKey<FormState>();
  String _result = '';

  String? _requiredName(String? value) {
    return (value ?? '').trim().isEmpty ? 'Enter a name' : null;
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    setState(() => _result = valid ? 'Valid' : 'Fix the errors above');
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Text field',
      subtitle: 'Every value can be set for one field, or once in the theme.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            MRETextField(
              labelText: 'Name (required)',
              showClearButton: true,
              validator: _requiredName,
            ),
            const MRETextField(
              labelText: 'Email (always left to right)',
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
            ),
            const MRETextField(
              labelText: 'City (suggestions)',
              suggestions: _cities,
            ),
            const MRETextField(
              labelText: 'Title (selects on focus)',
              initialValue: 'Draft',
              selectTextOnFocus: true,
            ),
            Row(
              spacing: 12,
              children: [
                FilledButton(onPressed: _submit, child: const Text('Validate')),
                Text(_result),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
