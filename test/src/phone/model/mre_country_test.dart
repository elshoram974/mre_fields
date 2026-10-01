import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

void main() {
  group('MRECountries.all', () {
    test('has one country for every region the phone data knows', () {
      expect(MRECountries.all, hasLength(IsoCode.values.length));
      expect(
        MRECountries.all.map((c) => c.isoCode).toSet(),
        IsoCode.values.map((i) => i.name).toSet(),
      );
    });

    test('every country has a name, a dial code and a flag', () {
      for (final country in MRECountries.all) {
        expect(country.name, isNotEmpty, reason: country.isoCode);
        expect(
          country.dialCode,
          matches(RegExp(r'^\d{1,4}$')),
          reason: country.isoCode,
        );
        expect(country.flag.runes, hasLength(2), reason: country.isoCode);
      }
    });

    test('is sorted by name, ignoring accents and case', () {
      final names = MRECountries.all.map((c) => c.name).toList();

      expect(names.first, 'Afghanistan');
      expect(
        names.indexOf('Åland Islands'),
        lessThan(names.indexOf('Albania')),
      );
      expect(names.indexOf('Albania'), lessThan(names.indexOf('Algeria')));
      expect(names.last, 'Zimbabwe');
    });

    test('cannot be changed', () {
      expect(
        () => MRECountries.all.add(MRECountries.all.first),
        throwsUnsupportedError,
      );
    });
  });

  group('lookups', () {
    test('byIsoCode ignores case and returns null for an unknown code', () {
      expect(MRECountries.byIsoCode('eg')!.name, 'Egypt');
      expect(MRECountries.byIsoCode('EG')!.dialCode, '20');
      expect(MRECountries.byIsoCode('ZZ'), isNull);
    });

    test('byDialCode returns every country that shares it', () {
      final plusOne = MRECountries.byDialCode('+1').map((c) => c.isoCode);

      expect(plusOne, containsAll(['US', 'CA']));
      expect(MRECountries.byDialCode('20').map((c) => c.isoCode), ['EG']);
      expect(MRECountries.byDialCode('0000'), isEmpty);
    });

    test('a dial code is not a key: +1 and +7 are shared', () {
      expect(MRECountries.byDialCode('1').length, greaterThan(10));
      expect(
        MRECountries.byDialCode('7').map((c) => c.isoCode),
        containsAll(['RU', 'KZ']),
      );
    });
  });

  group('MRECountry', () {
    final egypt = MRECountries.byIsoCode('EG')!;

    test('formats the dial code and the flag', () {
      expect(egypt.dialCodeWithPlus, '+20');
      expect(egypt.flag, '🇪🇬');
    });

    test('equals by ISO code', () {
      expect(egypt, MRECountries.byIsoCode('EG'));
      expect(egypt.hashCode, MRECountries.byIsoCode('EG').hashCode);
      expect(egypt, isNot(MRECountries.byIsoCode('SA')));
    });

    test('describes itself', () {
      expect(egypt.toString(), 'MRECountry(EG, +20, Egypt)');
    });
  });
}
