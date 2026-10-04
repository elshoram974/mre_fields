// Snippets embedded in the API docs and the text field guide. They are
// analyzed and run in test/doc/text_field_snippets_test.dart, so each example
// is correct.
import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

/// A field that follows the language the user types.
Widget basicField() {
  // #region basic
  final field = MRETextField(
    labelText: 'Name',
    hintText: 'Type in any language',
    showClearButton: true,
  );
  // #endregion basic

  return field;
}

/// One field that differs from the theme.
Widget overrideOneField() {
  // #region override_one_field
  final field = MRETextField(
    labelText: 'Search',
    borderRadius: 28, // this field only; the theme keeps its own radius
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );
  // #endregion override_one_field

  return field;
}

/// A field that always reads left to right.
Widget lockedDirection() {
  // #region lock_direction
  final email = MRETextField(
    labelText: 'Email',
    keyboardType: TextInputType.emailAddress,
    textDirection: TextDirection.ltr,
  );
  // #endregion lock_direction

  return email;
}

/// A field inside a form.
Widget nameForm(GlobalKey<FormState> formKey) {
  // #region form
  final form = Form(
    key: formKey,
    child: MRETextFormField(
      labelText: 'Name',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter a name';
        }
        return null;
      },
    ),
  );
  // #endregion form

  return form;
}

/// A field with suggestions.
Widget suggestionsField() {
  // #region suggestions
  final field = MRETextField(
    labelText: 'City',
    suggestions: const ['Cairo', 'Alexandria', 'Giza', 'القاهرة'],
    maxSuggestions: 5,
  );
  // #endregion suggestions

  return field;
}

/// A field that selects its text when it gets focus.
Widget selectOnFocus() {
  // #region select_on_focus
  final field = MRETextField(
    labelText: 'Title',
    initialValue: 'Draft',
    selectTextOnFocus: true,
  );
  // #endregion select_on_focus

  return field;
}

/// A field with a controller you own.
Widget withController(TextEditingController controller) {
  // #region controller
  final field = MRETextField(
    controller: controller,
    labelText: 'Notes',
    maxLines: 4,
  );
  // #endregion controller

  return field;
}

/// The clear button inside a plain [TextField].
Widget clearButtonAlone(TextEditingController controller) {
  // #region clear_button
  final field = TextField(
    controller: controller,
    decoration: InputDecoration(
      suffixIcon: MREFieldClearButton(
        onPressed: controller.clear,
        tooltip: 'Clear',
      ),
    ),
  );
  // #endregion clear_button

  return field;
}

/// The suggestion bar under a plain [TextField].
Widget suggestionBarAlone(TextEditingController controller) {
  // #region suggestion_bar
  final bar = MRESuggestionBar(
    suggestions: const ['Cairo', 'Giza'],
    onSelected: (city) => controller.text = city,
  );
  // #endregion suggestion_bar

  return bar;
}
