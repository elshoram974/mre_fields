import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

final _egypt = MRECountries.byIsoCode('EG')!;

void main() {
  group('MREPhoneValidators.valid', () {
    test('accepts a valid number', () {
      final validator = MREPhoneValidators.valid(country: _egypt);

      expect(validator('01012345678'), isNull);
      expect(validator('+201012345678'), isNull);
    });

    test('says why a number is not valid, in English by default', () {
      final validator = MREPhoneValidators.valid(country: _egypt);

      expect(validator(''), 'Enter a phone number');
      expect(validator(null), 'Enter a phone number');
      expect(validator('0101234'), 'The phone number is too short');
      expect(validator('01012345678901234'), 'The phone number is too long');
      expect(validator('+999123456'), 'Unknown country code');
      expect(validator('+20 9912345678'), 'This is not a valid phone number');
    });

    test('asks for a country when none was given', () {
      expect(MREPhoneValidators.valid()('01012345678'), 'Choose a country');
    });

    test('takes the message from your strings', () {
      final validator = MREPhoneValidators.valid(
        country: _egypt,
        strings: const MREFieldsStrings(
          phoneEmpty: 'اكتب رقم الهاتف',
          phoneTooShort: 'الرقم قصير',
        ),
      );

      expect(validator(''), 'اكتب رقم الهاتف');
      expect(validator('0101234'), 'الرقم قصير');
    });

    test('takes the message from errorText first', () {
      final validator = MREPhoneValidators.valid(
        country: _egypt,
        errorText: (error) => 'custom ${error.name}',
      );

      expect(validator('0101234'), 'custom tooShort');
    });

    test('accepts an empty value when it is not required', () {
      final validator = MREPhoneValidators.valid(
        country: _egypt,
        required: false,
      );

      expect(validator(''), isNull);
      expect(validator(null), isNull);
      expect(validator('0101234'), 'The phone number is too short');
    });

    test('rejects a country the selection does not accept', () {
      final validator = MREPhoneValidators.valid(
        country: _egypt,
        selection: const MRECountrySelection(exclude: {'EG'}),
      );

      expect(
        validator('01012345678'),
        'Numbers from this country are not accepted',
      );
    });
  });

  group('MREPhoneErrorText', () {
    test('has a message for every error', () {
      const strings = MREFieldsStrings();

      for (final error in MREPhoneError.values) {
        expect(strings.phoneError(error), isNotEmpty, reason: error.name);
      }
      expect(
        MREPhoneError.values.map(strings.phoneError).toSet(),
        hasLength(MREPhoneError.values.length),
      );
    });
  });
}
