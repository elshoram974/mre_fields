import 'package:flutter/material.dart';

import '../text/field/mre_text_form_field.dart';
import 'preview_harness.dart';

/// An empty field with a label and a hint.
@MREPreview()
Widget previewTextFieldEmpty() {
  return MRETextFormField(
    labelText: 'Name',
    hintText: 'Type in any language',
    showClearButton: true,
  );
}

/// English text with the clear button.
@MREPreview()
Widget previewTextFieldEnglish() {
  return MRETextFormField(
    labelText: 'Name',
    initialValue: 'Mohamed Ali',
    showClearButton: true,
  );
}

/// Arabic text: right to left, with the clear button.
@MREPreview()
Widget previewTextFieldArabic() {
  return MRETextFormField(
    labelText: 'الاسم',
    initialValue: 'محمد علي',
    showClearButton: true,
  );
}

/// A focused field with suggestions under it.
@MREPreview()
Widget previewTextFieldSuggestions() {
  return MRETextFormField(
    labelText: 'City',
    initialValue: 'a',
    autofocus: true,
    showClearButton: true,
    suggestions: ['Cairo', 'Alexandria', 'Giza', 'Aswan', 'القاهرة'],
  );
}

/// A field with an error and icons.
@MREPreview()
Widget previewTextFieldError() {
  return MRETextFormField(
    labelText: 'Email',
    initialValue: 'not-an-email',
    errorText: 'Enter a valid email',
    prefixIcon: Icon(Icons.mail_outline),
    textDirection: TextDirection.ltr,
  );
}

/// A multiline field.
@MREPreview()
Widget previewTextFieldMultiline() {
  return MRETextFormField(
    labelText: 'Notes',
    hintText: 'Write a note',
    minLines: 3,
    maxLines: 5,
  );
}

/// A disabled and a read-only field.
@MREPreview()
Widget previewTextFieldStates() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: [
      MRETextFormField(
        labelText: 'Disabled',
        initialValue: 'Cannot edit',
        enabled: false,
      ),
      MRETextFormField(
        labelText: 'Read only',
        initialValue: 'Can copy',
        readOnly: true,
      ),
    ],
  );
}
