`MRETextField` is a `TextFormField` that follows the language of what the user
types. It takes the colors, fonts and borders of your `ThemeData`, and every
value can be changed for one field.

## Basic field

The direction follows the first word with a letter, as the user types. See
[Text](Text-topic.html) for how it is chosen. A clear button shows while the
field has text.

<!-- snippet: basic -->
```dart
final field = MRETextField(
  labelText: 'Name',
  hintText: 'Type in any language',
  showClearButton: true,
);
```

## Lock the direction

Emails, links and numbers read left to right in any language. Set
`textDirection` to turn detection off for that field.

<!-- snippet: lock_direction -->
```dart
final email = MRETextField(
  labelText: 'Email',
  keyboardType: TextInputType.emailAddress,
  textDirection: TextDirection.ltr,
);
```

## Change one field

A parameter beats `MREFieldsTheme`, and `MREFieldsTheme` beats your
`InputDecorationTheme`. Radius applies to outline borders only. Without a
registered `MREFieldsTheme` or a `borderRadius`, borders stay as your theme
defines them.

<!-- snippet: override_one_field -->
```dart
final field = MRETextField(
  labelText: 'Search',
  borderRadius: 28, // this field only; the theme keeps its own radius
  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
);
```

## Use it in a form

<!-- snippet: form -->
```dart
final form = Form(
  key: formKey,
  child: MRETextField(
    labelText: 'Name',
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Enter a name';
      }
      return null;
    },
  ),
);
```

Call `formKey.currentState!.validate()` as with any form field. Without a
parent `Form`, pass `fieldKey` and call `fieldKey.currentState!.validate()`.

## Suggestions

Suggestions show under the field while it has focus. They filter as the user
types, ignore case, and hide the one that equals the text.

<!-- snippet: suggestions -->
```dart
final field = MRETextField(
  labelText: 'City',
  suggestions: const ['Cairo', 'Alexandria', 'Giza', 'القاهرة'],
  maxSuggestions: 5,
);
```

## Select the text on focus

<!-- snippet: select_on_focus -->
```dart
final field = MRETextField(
  labelText: 'Title',
  initialValue: 'Draft',
  selectTextOnFocus: true,
);
```

## Own the controller

Without a controller the field creates one and disposes it. With one, you own
it. `MRESafeTextEditingController` is the one used by default; it replaces
unpaired surrogates that crash Flutter's text layout.

<!-- snippet: controller -->
```dart
final field = MRETextField(
  controller: controller,
  labelText: 'Notes',
  maxLines: 4,
);
```

## Use the pieces alone

The clear button and the suggestion bar work in any field.

<!-- snippet: clear_button -->
```dart
final field = TextField(
  controller: controller,
  decoration: InputDecoration(
    suffixIcon: MREFieldClearButton(
      onPressed: controller.clear,
      tooltip: 'Clear',
    ),
  ),
);
```

<!-- snippet: suggestion_bar -->
```dart
final bar = MRESuggestionBar(
  suggestions: const ['Cairo', 'Giza'],
  onSelected: (city) => controller.text = city,
);
```
