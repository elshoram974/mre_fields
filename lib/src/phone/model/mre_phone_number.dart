import 'package:flutter/foundation.dart';
import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'mre_country.dart';
import 'mre_country_parser_code.dart';
import 'mre_country_selection.dart';
import 'mre_phone_digits.dart';

/// Why a phone number is not valid.
///
/// Show a message for it from `MREFieldsStrings`, or from your own text.
///
/// {@category Phone}
enum MREPhoneError {
  /// Nothing was entered.
  empty,

  /// Fewer digits than any number of the country has.
  tooShort,

  /// More digits than any number of the country has.
  tooLong,

  /// The length fits but the number does not match the country's patterns.
  invalid,

  /// The dial code after the plus belongs to no country.
  unknownCountry,

  /// The number is from a country the selection does not accept.
  countryNotAllowed,

  /// The number has no dial code and no country was chosen.
  missingCountry,
}

/// A phone number split into its country and national number.
///
/// Parse what the user typed or pasted:
///
/// {@example /doc/snippets/phone.dart#parse}
///
/// [error] says why it is not valid; it is null for a valid number. The check
/// covers every country and uses the same rules as libphonenumber.
///
/// {@category Phone}
@immutable
final class MREPhoneNumber {
  const MREPhoneNumber._({
    this.country,
    this.nationalNumber = '',
    this.error,
    PhoneNumber? parsed,
  }) : _parsed = parsed;

  /// The country, or null when none could be found.
  final MRECountry? country;

  /// The digits after the dial code, without the national prefix: `1012345678`
  /// for the Egyptian number `010 1234 5678`.
  final String nationalNumber;

  /// Why the number is not valid, or null when it is.
  final MREPhoneError? error;

  final PhoneNumber? _parsed;

  /// Reads [input] as a phone number.
  ///
  /// A number that starts with `+` or `00` carries its own dial code and finds
  /// its country. Any other number is read as a national number of
  /// [defaultCountry]. Digits in Arabic, Persian or full-width form, spaces,
  /// dashes and brackets are accepted. A number from a country that
  /// [selection] does not accept gets [MREPhoneError.countryNotAllowed].
  factory MREPhoneNumber.parse(
    String input, {
    MRECountry? defaultCountry,
    MRECountrySelection selection = const MRECountrySelection(),
  }) {
    var text = mreNormalizePhoneInput(input);
    if (text.startsWith('00')) {
      text = '+${text.substring(2)}';
    }
    final international = text.startsWith('+');
    if (!international && defaultCountry == null && text.isNotEmpty) {
      return MREPhoneNumber._(
        nationalNumber: text,
        error: MREPhoneError.missingCountry,
      );
    }
    return MREPhoneNumber._read(
      text,
      international: international,
      country: defaultCountry,
      selection: selection,
    );
  }

  /// Reads [digits], what a user typed in a field next to [country], as a
  /// national number of that country.
  ///
  /// Unlike [MREPhoneNumber.parse], a leading `00` is not an international
  /// prefix here: the user chose the country.
  factory MREPhoneNumber.national(
    MRECountry country,
    String digits, {
    MRECountrySelection selection = const MRECountrySelection(),
  }) {
    return MREPhoneNumber._read(
      mreNormalizePhoneInput(digits).replaceAll('+', ''),
      international: false,
      country: country,
      selection: selection,
    );
  }

  factory MREPhoneNumber._read(
    String text, {
    required bool international,
    required MRECountry? country,
    required MRECountrySelection selection,
  }) {
    if (text.isEmpty || text == '+') {
      return MREPhoneNumber._(country: country, error: MREPhoneError.empty);
    }

    final PhoneNumber parsed;
    try {
      parsed = international
          ? PhoneNumber.parse(text)
          : PhoneNumber.parse(
              text,
              callerCountry: mreParserIsoCode(country!),
              destinationCountry: mreParserIsoCode(country),
            );
    } on PhoneNumberException catch (exception) {
      return MREPhoneNumber._(
        country: country,
        nationalNumber: international ? '' : text,
        error: switch (exception.code) {
          Code.inputIsTooLong => MREPhoneError.tooLong,
          Code.notFound ||
          Code.invalidCountryCallingCode => MREPhoneError.unknownCountry,
          _ => MREPhoneError.invalid,
        },
      );
    }

    final found = MRECountries.byIsoCode(parsed.isoCode.name);
    return MREPhoneNumber._(
      country: found,
      nationalNumber: parsed.nsn,
      parsed: parsed,
      error: _errorOf(parsed, found, selection),
    );
  }

  /// Whether the number is valid.
  bool get isValid => error == null;

  /// The number in international form without spaces, such as
  /// `+201012345678`, or null when the number is not valid.
  String? get e164 {
    final found = country;
    return isValid && found != null
        ? '+${found.dialCode}$nationalNumber'
        : null;
  }

  /// The number as people read it nationally, such as `10 12345678`. Falls back
  /// to the raw digits when the number could not be parsed.
  String get national => _parsed?.formatNsn() ?? nationalNumber;

  /// The number with its dial code and the country's grouping, such as
  /// `+20 10 12345678`. Falls back to the raw digits.
  String get international {
    final found = country;
    final formatted = _parsed?.formatNsn(format: NsnFormat.international);
    if (found == null || formatted == null) {
      return nationalNumber;
    }
    return '${found.dialCodeWithPlus} $formatted';
  }

  static MREPhoneError? _errorOf(
    PhoneNumber parsed,
    MRECountry? country,
    MRECountrySelection selection,
  ) {
    if (country != null && !selection.allows(country)) {
      return MREPhoneError.countryNotAllowed;
    }
    if (parsed.nsn.isEmpty) {
      return MREPhoneError.empty;
    }
    if (parsed.isValid()) {
      return null;
    }

    final lengths = _lengthsOf(parsed.isoCode);
    if (lengths.isEmpty) {
      return MREPhoneError.invalid;
    }
    if (parsed.nsn.length < lengths.reduce((a, b) => a < b ? a : b)) {
      return MREPhoneError.tooShort;
    }
    if (parsed.nsn.length > lengths.reduce((a, b) => a > b ? a : b)) {
      return MREPhoneError.tooLong;
    }
    return MREPhoneError.invalid;
  }

  /// Every national number length the country has, over all number types.
  static List<int> _lengthsOf(IsoCode iso) {
    final lengths = metadataLenghtsByIsoCode[iso];
    if (lengths == null) {
      return const [];
    }
    return [
      ...lengths.general,
      ...lengths.mobile,
      ...lengths.fixedLine,
      ...lengths.voip,
      ...lengths.tollFree,
      ...lengths.premiumRate,
      ...lengths.sharedCost,
      ...lengths.personalNumber,
      ...lengths.uan,
      ...lengths.pager,
      ...lengths.voiceMail,
    ];
  }

  @override
  bool operator ==(Object other) {
    return other is MREPhoneNumber &&
        other.country == country &&
        other.nationalNumber == nationalNumber &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(country, nationalNumber, error);

  @override
  String toString() {
    return 'MREPhoneNumber(${country?.isoCode} $nationalNumber, error: $error)';
  }
}
