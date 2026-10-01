import 'package:flutter/material.dart';

import '../text/mre_text_field.dart';
import 'preview_harness.dart';

/// An empty field with a label and a hint.
@MREPreview()
Widget previewTextFieldEmpty() {
  return const MRETextField(
    labelText: 'Name',
    hintText: 'Type in any language',
    showClearButton: true,
  );
}

/// English text with the clear button.
@MREPreview()
Widget previewTextFieldEnglish() {
  return const MRETextField(
    labelText: 'Name',
    initialValue: 'Mohamed Ali',
    showClearButton: true,
  );
}

/// Arabic text: right to left, with the clear button.
@MREPreview()
Widget previewTextFieldArabic() {
  return const MRETextField(
    labelText: 'الاسم',
    initialValue: 'محمد علي',
    showClearButton: true,
  );
}

/// A focused field with suggestions under it.
@MREPreview()
Widget previewTextFieldSuggestions() {
  return const MRETextField(
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
  return const MRETextField(
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
  return const MRETextField(
    labelText: 'Notes',
    hintText: 'Write a note',
    minLines: 3,
    maxLines: 5,
  );
}

/// A disabled and a read-only field.
@MREPreview()
Widget previewTextFieldStates() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: [
      MRETextField(
        labelText: 'Disabled',
        initialValue: 'Cannot edit',
        enabled: false,
      ),
      MRETextField(
        labelText: 'Read only',
        initialValue: 'Can copy',
        readOnly: true,
      ),
    ],
  );
}
