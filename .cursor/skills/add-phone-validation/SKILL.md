---
name: add-phone-validation
description: >-
  Extends the phone support of mre_fields: parsing and validation for every
  country, country selection (include, exclude, favorites), the picker, the
  field, and their messages. Use for phone number validation, dial code
  detection, or limiting which countries a field accepts.
---

# Phone parse, validate, pick

Read `.cursor/rules/phone-countries.mdc` first. It holds the layout, the data rules and the typing/paste rules.

## Files

```text
lib/src/phone/
  model/       mre_country.dart, mre_country_names.dart, mre_country_parser_code.dart,
               mre_country_selection.dart, mre_phone_digits.dart, mre_phone_number.dart
  validation/  mre_phone_validators.dart
  picker/      mre_country_picker_body.dart, mre_country_picker.dart
  field/       mre_phone_controller.dart, mre_dial_button.dart, mre_phone_field.dart
```

## Add or change something

1. **A rule about numbers** goes in `model/` as a pure function or class. Test it with `test/src/phone/model/`, no widgets.
2. **A new error reason**: add it to `MREPhoneError`, to `MREFieldsStrings` (default English, `copyWith`, `==`, `hashCode`, the uniqueness test), and to `MREPhoneErrorText.phoneError` (the `switch` is exhaustive, so the compiler tells you).
3. **A new country** appears when `phone_numbers_parser` adds a region. Regenerate `mre_country_names.dart` from `Intl.DisplayNames(['en'], {type: 'region'})` for every `IsoCode`; `mre_country_test.dart` fails if a name is missing.
4. **Field behaviour**: keep logic in `MREPhoneController`/`MREPhoneNumber`; the widget only wires. Typed-versus-pasted detection compares the text length before and after.
5. **Picker**: the body stays reusable (`MRECountryPickerBody`); `showMRECountryPicker` only chooses sheet or dialog.
6. **Docs**: snippet in `doc/snippets/phone.dart`, guide `doc/phone.md`, test in `test/doc/phone_snippets_test.dart`, preview in `lib/src/previews/mre_phone_previews.dart`, example in `example/lib/sections/phone_section.dart`, GIF scenario `phone` in `tool/demo/record.mjs`.

## Check

```bash
flutter analyze && flutter test test/src/phone test/doc/phone_snippets_test.dart test/architecture_test.dart
```
