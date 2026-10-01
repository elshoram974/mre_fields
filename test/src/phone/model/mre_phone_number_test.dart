import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';
import 'package:phone_numbers_parser/metadata.dart';

final _egypt = MRECountries.byIsoCode('EG')!;

void main() {
  group('parse an international number', () {
    test('splits +20 1012345678 into country and national number', () {
      final number = MREPhoneNumber.parse('+201012345678');

      expect(number.isValid, isTrue);
      expect(number.country, _egypt);
      expect(number.nationalNumber, '1012345678');
      expect(number.e164, '+201012345678');
      expect(number.error, isNull);
    });

    test('formats it nationally and internationally', () {
      final number = MREPhoneNumber.parse('+201012345678');

      expect(number.national, '10 12345678');
      expect(number.international, '+20 10 12345678');
    });

    test('reads 00 as the international prefix', () {
      expect(MREPhoneNumber.parse('0020 101 234 5678').e164, '+201012345678');
    });

    test('accepts spaces, dashes, brackets and other digit scripts', () {
      expect(MREPhoneNumber.parse('+20 (10) 1234-5678').e164, '+201012345678');
      expect(MREPhoneNumber.parse('+٢٠١٠١٢٣٤٥٦٧٨').e164, '+201012345678');
      expect(MREPhoneNumber.parse('+۲۰۱۰۱۲۳۴۵۶۷۸').e164, '+201012345678');
    });

    test(
      'finds the country from the whole number when a dial code is shared',
      () {
        expect(MREPhoneNumber.parse('+1 204 555 1234').country!.isoCode, 'CA');
        expect(MREPhoneNumber.parse('+1 212 555 1234').country!.isoCode, 'US');
        expect(MREPhoneNumber.parse('+7 701 234 5678').country!.isoCode, 'KZ');
      },
    );

    test('prefers the longest dial code', () {
      expect(MREPhoneNumber.parse('+971501234567').country!.isoCode, 'AE');
      expect(MREPhoneNumber.parse('+212612345678').country!.isoCode, 'MA');
    });
  });

  group('parse a national number', () {
    test('reads it as a number of the default country', () {
      final number = MREPhoneNumber.parse(
        '01012345678',
        defaultCountry: _egypt,
      );

      expect(number.isValid, isTrue);
      expect(number.e164, '+201012345678');
    });

    test('strips the national prefix once', () {
      expect(
        MREPhoneNumber.parse(
          '1012345678',
          defaultCountry: _egypt,
        ).nationalNumber,
        '1012345678',
      );
      expect(
        MREPhoneNumber.parse(
          '010 1234 5678',
          defaultCountry: _egypt,
        ).nationalNumber,
        '1012345678',
      );
    });

    test('accepts Arabic-Indic digits', () {
      expect(
        MREPhoneNumber.parse('٠١٠١٢٣٤٥٦٧٨', defaultCountry: _egypt).e164,
        '+201012345678',
      );
    });

    test('a number with a dial code ignores the default country', () {
      final saudi = MRECountries.byIsoCode('SA')!;

      expect(
        MREPhoneNumber.parse('+201012345678', defaultCountry: saudi).country,
        _egypt,
      );
    });

    test('without a default country it says a country is missing', () {
      final number = MREPhoneNumber.parse('01012345678');

      expect(number.error, MREPhoneError.missingCountry);
      expect(number.country, isNull);
      expect(number.isValid, isFalse);
      expect(number.e164, isNull);
    });
  });

  group('errors', () {
    test('nothing entered', () {
      expect(MREPhoneNumber.parse('').error, MREPhoneError.empty);
      expect(MREPhoneNumber.parse('   ').error, MREPhoneError.empty);
      expect(MREPhoneNumber.parse('+').error, MREPhoneError.empty);
      expect(MREPhoneNumber.parse('', defaultCountry: _egypt).country, _egypt);
    });

    test('only a dial code', () {
      final number = MREPhoneNumber.parse('+20');

      expect(number.country, _egypt);
      expect(number.error, MREPhoneError.empty);
    });

    test('too few digits', () {
      expect(MREPhoneNumber.parse('+20101234').error, MREPhoneError.tooShort);
      expect(
        MREPhoneNumber.parse('0101234', defaultCountry: _egypt).error,
        MREPhoneError.tooShort,
      );
    });

    test('too many digits', () {
      expect(
        MREPhoneNumber.parse('+2010123456789012345').error,
        MREPhoneError.tooLong,
      );
    });

    test('a dial code that belongs to no country', () {
      expect(
        MREPhoneNumber.parse('+999123456').error,
        MREPhoneError.unknownCountry,
      );
      expect(MREPhoneNumber.parse('+2').error, MREPhoneError.unknownCountry);
    });

    test('a number that fits the length but not the patterns', () {
      final number = MREPhoneNumber.parse('+20 9912345678');

      expect(number.isValid, isFalse);
      expect(number.error, MREPhoneError.invalid);
    });

    test('an invalid number has no E.164 form', () {
      expect(MREPhoneNumber.parse('+20101234').e164, isNull);
    });
  });

  group('selection', () {
    test('a number from an excluded country is not allowed', () {
      const selection = MRECountrySelection(exclude: {'EG'});
      final number = MREPhoneNumber.parse(
        '+201012345678',
        selection: selection,
      );

      expect(number.error, MREPhoneError.countryNotAllowed);
      expect(number.country, _egypt);
      expect(number.isValid, isFalse);
    });

    test('a number from a country outside the include list is not allowed', () {
      const selection = MRECountrySelection(include: {'SA'});

      expect(
        MREPhoneNumber.parse('+201012345678', selection: selection).error,
        MREPhoneError.countryNotAllowed,
      );
      expect(
        MREPhoneNumber.parse('+966501234567', selection: selection).error,
        isNot(MREPhoneError.countryNotAllowed),
      );
    });

    test('a national number of an excluded country is not allowed either', () {
      const selection = MRECountrySelection(exclude: {'EG'});

      expect(
        MREPhoneNumber.parse(
          '01012345678',
          defaultCountry: _egypt,
          selection: selection,
        ).error,
        MREPhoneError.countryNotAllowed,
      );
    });
  });

  group('MREPhoneNumber.national', () {
    test('reads digits as a number of the given country', () {
      final number = MREPhoneNumber.national(_egypt, '01012345678');

      expect(number.isValid, isTrue);
      expect(number.e164, '+201012345678');
    });

    test('does not read 00 as an international prefix', () {
      final number = MREPhoneNumber.national(_egypt, '0020101234567');

      expect(number.country, _egypt);
      expect(number.isValid, isFalse);
    });

    test('keeps the chosen country when the digits are empty', () {
      final number = MREPhoneNumber.national(_egypt, '');

      expect(number.country, _egypt);
      expect(number.error, MREPhoneError.empty);
    });
  });

  test('numbers are equal when country, digits and error are', () {
    final a = MREPhoneNumber.parse('+201012345678');
    final b = MREPhoneNumber.parse('0020 1012345678');

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(MREPhoneNumber.parse('+201012345679')));
    expect(a.toString(), contains('EG'));
  });

  group('every country', () {
    test('accepts the example numbers of its own data', () {
      var checked = 0;
      final failures = <String>[];

      for (final MapEntry(key: iso, value: examples)
          in metadataExamplesByIsoCode.entries) {
        final country = MRECountries.byIsoCode(iso.name)!;
        for (final example in [examples.mobile, examples.fixedLine]) {
          if (example.isEmpty) {
            continue;
          }
          checked++;
          final number = MREPhoneNumber.parse('+${country.dialCode}$example');
          if (!number.isValid || number.country!.dialCode != country.dialCode) {
            failures.add(
              '${iso.name} +${country.dialCode} $example -> ${number.error} ${number.country?.isoCode}',
            );
          }
        }
      }

      expect(checked, greaterThan(400));
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('rejects an example number with too many digits added', () {
      final accepted = <String>[];

      for (final MapEntry(key: iso, value: examples)
          in metadataExamplesByIsoCode.entries) {
        final country = MRECountries.byIsoCode(iso.name)!;
        final example = examples.mobile.isNotEmpty
            ? examples.mobile
            : examples.fixedLine;
        if (example.isEmpty) {
          continue;
        }
        final number = MREPhoneNumber.parse(
          '+${country.dialCode}${example}00000000000',
        );
        if (number.isValid) {
          accepted.add(iso.name);
        }
      }

      expect(accepted, isEmpty);
    });

    test(
      'national numbers of the default country are read for every country',
      () {
        final failures = <String>[];

        for (final MapEntry(key: iso, value: examples)
            in metadataExamplesByIsoCode.entries) {
          final country = MRECountries.byIsoCode(iso.name)!;
          final example = examples.mobile.isNotEmpty
              ? examples.mobile
              : examples.fixedLine;
          if (example.isEmpty) {
            continue;
          }
          final number = MREPhoneNumber.national(country, example);
          if (!number.isValid) {
            failures.add('${iso.name} $example -> ${number.error}');
          }
        }

        expect(failures, isEmpty, reason: failures.join('\n'));
      },
    );
  });
}
