import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

void main() {
  group('mreNormalizePhoneInput', () {
    test('keeps digits and a leading plus', () {
      expect(mreNormalizePhoneInput('+201012345678'), '+201012345678');
      expect(mreNormalizePhoneInput('01012345678'), '01012345678');
    });

    test('drops spaces, dashes, dots and brackets', () {
      expect(mreNormalizePhoneInput('+20 (10) 1234-5678'), '+201012345678');
      expect(mreNormalizePhoneInput('010.1234.5678'), '01012345678');
    });

    test('turns Arabic-Indic, Persian and full-width digits into ASCII', () {
      expect(
        mreNormalizePhoneInput('٠١٠١٢٣٤٥٦٧٨'),
        '0101234 5678'.replaceAll(' ', ''),
      );
      expect(mreNormalizePhoneInput('۰۱۰۱۲۳۴۵۶۷۸'), '01012345678');
      expect(mreNormalizePhoneInput('０１０１２３４５６７８'), '01012345678');
    });

    test('keeps only a plus at the start', () {
      expect(mreNormalizePhoneInput('20+10'), '2010');
      expect(mreNormalizePhoneInput('++20'), '+20');
      expect(mreNormalizePhoneInput('  +20'), '+20');
    });

    test('drops letters and symbols', () {
      expect(mreNormalizePhoneInput('ab12-cd34'), '1234');
      expect(mreNormalizePhoneInput(''), '');
    });
  });

  group('MREPhoneInputFormatter', () {
    const formatter = MREPhoneInputFormatter();

    TextEditingValue run(String text, {int? cursor}) {
      return formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: cursor ?? text.length),
        ),
      );
    }

    test('returns clean input untouched', () {
      final value = TextEditingValue(
        text: '0101',
        selection: const TextSelection.collapsed(offset: 2),
      );

      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, value),
        same(value),
      );
    });

    test('cleans a pasted number and puts the cursor at its end', () {
      final result = run('+20 (10) 1234-5678');

      expect(result.text, '+201012345678');
      expect(result.selection.baseOffset, 13);
    });

    test('keeps the cursor in place when a character before it is removed', () {
      final result = run('01-23', cursor: 3);

      expect(result.text, '0123');
      expect(result.selection.baseOffset, 2);
    });
  });
}
