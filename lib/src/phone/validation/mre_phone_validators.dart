import 'package:flutter/widgets.dart';

import '../../theme/mre_fields_strings.dart';
import '../model/mre_country.dart';
import '../model/mre_country_selection.dart';
import '../model/mre_phone_number.dart';

/// The text of a phone error, taken from [MREFieldsStrings].
///
/// {@category Phone}
extension MREPhoneErrorText on MREFieldsStrings {
  /// The message for [error] in the strings you registered.
  String phoneError(MREPhoneError error) {
    return switch (error) {
      MREPhoneError.empty => phoneEmpty,
      MREPhoneError.tooShort => phoneTooShort,
      MREPhoneError.tooLong => phoneTooLong,
      MREPhoneError.invalid => phoneInvalid,
      MREPhoneError.unknownCountry => phoneUnknownCountry,
      MREPhoneError.countryNotAllowed => phoneCountryNotAllowed,
      MREPhoneError.missingCountry => phoneMissingCountry,
    };
  }
}

/// Validators for phone numbers, for any form field.
///
/// {@example /doc/snippets/phone.dart#validator}
///
/// {@category Phone}
abstract final class MREPhoneValidators {
  /// A validator that accepts a valid phone number of any accepted country.
  ///
  /// A number without a dial code is read as a number of [country]. The message
  /// comes from [errorText] when given, else from [strings], so every message
  /// can be translated. With [required] false an empty value is accepted.
  static FormFieldValidator<String> valid({
    MRECountry? country,
    MRECountrySelection selection = const MRECountrySelection(),
    bool required = true,
    MREFieldsStrings strings = const MREFieldsStrings(),
    String Function(MREPhoneError error)? errorText,
  }) {
    return (value) {
      final number = MREPhoneNumber.parse(
        value ?? '',
        defaultCountry: country,
        selection: selection,
      );
      final error = number.error;
      if (error == null || (error == MREPhoneError.empty && !required)) {
        return null;
      }
      return errorText?.call(error) ?? strings.phoneError(error);
    };
  }
}
