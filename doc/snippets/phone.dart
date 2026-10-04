// Snippets embedded in the API docs and the phone guide. They are analyzed and
// run in test/doc/phone_snippets_test.dart, so each example is correct.
import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

/// Stand-in for saving the number.
void saveNumber(String e164) {}

/// A phone field that reports valid numbers.
Widget basicPhone() {
  // #region basic
  final field = MREPhoneFormField(
    labelText: 'Phone number',
    onChanged: (number) {
      if (number.isValid) {
        saveNumber(number.e164!); // '+201012345678'
      }
    },
  );
  // #endregion basic

  return field;
}

/// Gulf numbers only, with the favorite on top.
Widget gulfOnly() {
  // #region selection
  const selection = MRECountrySelection(
    include: {'SA', 'AE', 'KW', 'QA', 'BH', 'OM'},
    favorites: ['SA', 'AE'],
    initial: 'SA',
  );

  final field = MREPhoneFormField(selection: selection);
  // #endregion selection

  return field;
}

/// Every country except one.
Widget everyoneButOne() {
  // #region exclude
  final field = MREPhoneFormField(
    selection: const MRECountrySelection(exclude: {'IL'}),
  );
  // #endregion exclude

  return field;
}

/// Splits what the user typed or pasted.
List<Object?> parseExamples() {
  // #region parse
  final number = MREPhoneNumber.parse('+20 101 234 5678');

  final country = number.country!.name; // 'Egypt'
  final e164 = number.e164; // '+201012345678'
  final nice = number.international; // '+20 10 12345678'
  final valid = number.isValid; // true
  // #endregion parse

  return [country, e164, nice, valid];
}

/// Says what is wrong with a number.
MREPhoneError? whatIsWrong(String typed) {
  // #region error
  final number = MREPhoneNumber.parse(
    typed,
    defaultCountry: MRECountries.byIsoCode('EG'),
  );

  final error = number.error; // null, or tooShort, tooLong, invalid, ...
  // #endregion error

  return error;
}

/// Reads a national number with a default country.
String? nationalNumber() {
  // #region national
  final egypt = MRECountries.byIsoCode('EG')!;
  final number = MREPhoneNumber.parse('010 1234 5678', defaultCountry: egypt);

  final e164 = number.e164; // '+201012345678'
  // #endregion national

  return e164;
}

/// Looks countries up.
List<Object?> countryLookups() {
  // #region countries
  final egypt = MRECountries.byIsoCode('EG')!;
  final dial = egypt.dialCodeWithPlus; // '+20'
  final flag = egypt.flag; // 🇪🇬
  final sharing = MRECountries.byDialCode('+1'); // United States, Canada, ...
  // #endregion countries

  return [dial, flag, sharing];
}

/// The validation in a plain form field.
Widget phoneInPlainField() {
  // #region validator
  final field = TextFormField(
    keyboardType: TextInputType.phone,
    validator: MREPhoneValidators.valid(
      country: MRECountries.byIsoCode('EG'),
      selection: const MRECountrySelection(include: {'EG', 'SA'}),
    ),
  );
  // #endregion validator

  return field;
}

/// Opens the picker on its own.
Future<MRECountry?> choose(BuildContext context) {
  // #region picker
  final country = showMRECountryPicker(
    context,
    countries: MRECountries.all,
    favorites: [MRECountries.byIsoCode('EG')!],
  );
  // #endregion picker

  return country;
}

/// Reads and sets the number from code.
Widget withPhoneController(MREPhoneController controller) {
  // #region controller
  // Create the controller in initState and dispose it in dispose.
  final field = MREPhoneFormField(controller: controller, labelText: 'Phone');

  controller.setNumber('+966 50 123 4567'); // sets the country and the digits
  final number = controller.number(); // an MREPhoneNumber
  // #endregion controller

  return number.isValid ? field : field;
}

/// Arabic country names and messages.
Widget arabicPhone() {
  // #region translate
  final field = MREPhoneFormField(
    labelText: 'رقم الهاتف',
    countryNameBuilder: (country) =>
        arabicNames[country.isoCode] ?? country.name,
    pickerTitle: 'اختر الدولة',
    pickerSearchHint: 'ابحث عن دولة أو رمز',
  );

  // The error messages come from MREFieldsStrings, registered once in the theme:
  const strings = MREFieldsStrings(
    phoneEmpty: 'اكتب رقم الهاتف',
    phoneTooShort: 'الرقم قصير',
    phoneInvalid: 'رقم غير صحيح',
  );
  // #endregion translate

  return strings.phoneEmpty.isEmpty ? SizedBox() : field;
}

/// Names for the countries a demo shows.
const arabicNames = {'EG': 'مصر', 'SA': 'السعودية', 'AE': 'الإمارات'};

/// A required phone number in a form.
Widget phoneForm(GlobalKey<FormState> formKey) {
  // #region form
  final form = Form(
    key: formKey,
    child: MREPhoneFormField(labelText: 'Phone number', required: true),
  );
  // #endregion form

  return form;
}

/// Keeps every message in one place.
String messageFor(MREPhoneError error) {
  // #region messages
  const strings = MREFieldsStrings();
  final message = strings.phoneError(error); // 'The phone number is too short'
  // #endregion messages

  return message;
}
