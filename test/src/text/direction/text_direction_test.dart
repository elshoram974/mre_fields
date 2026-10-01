import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

void main() {
  group('detectTextDirection', () {
    test('Arabic is rtl', () {
      expect(detectTextDirection('مرحبا بالعالم'), TextDirection.rtl);
    });

    test('Hebrew is rtl', () {
      expect(detectTextDirection('שלום עולם'), TextDirection.rtl);
    });

    test('Persian and Urdu are rtl', () {
      expect(detectTextDirection('سلام دنیا'), TextDirection.rtl);
      expect(detectTextDirection('ہیلو دنیا'), TextDirection.rtl);
    });

    test('every right to left script is rtl', () {
      const samples = {
        'Arabic': 'مرحبا',
        'Hebrew': 'שלום',
        'Persian': 'سلام',
        'Urdu': 'ہیلو',
        'Pashto': 'سلام ملګریه',
        'Kurdish Sorani': 'سڵاو',
        'Syriac': 'ܫܠܡܐ',
        'Thaana (Dhivehi)': 'ހެލޯ',
        'NKo': 'ߊߟߎ߫',
        'Samaritan': 'ࠔࠋࠌ',
        'Mandaic': 'ࡀࡁࡂ',
        'Hebrew presentation form': '\uFB2A',
        'Arabic presentation form': '\uFE8D',
        'Phoenician (astral)': '\u{10900}',
        'Adlam (astral)': '\u{1E921}',
        'Arabic mathematical (astral)': '\u{1EE01}',
      };

      for (final MapEntry(:key, :value) in samples.entries) {
        expect(detectTextDirection(value), TextDirection.rtl, reason: key);
      }
    });

    test('English and other left to right scripts are ltr', () {
      expect(detectTextDirection('Hello'), TextDirection.ltr);
      expect(detectTextDirection('Привет'), TextDirection.ltr);
      expect(detectTextDirection('你好世界'), TextDirection.ltr);
      expect(detectTextDirection('नमस्ते'), TextDirection.ltr);
    });

    test('the first letter decides in mixed text', () {
      expect(detectTextDirection('hello مرحبا'), TextDirection.ltr);
      expect(detectTextDirection('مرحبا hello'), TextDirection.rtl);
    });

    test('digits, spaces, punctuation and emoji are skipped', () {
      expect(detectTextDirection('123 مرحبا'), TextDirection.rtl);
      expect(detectTextDirection('  (12) hello'), TextDirection.ltr);
      expect(detectTextDirection('😀 مرحبا'), TextDirection.rtl);
      expect(detectTextDirection('😀 hello'), TextDirection.ltr);
    });

    test('Arabic-Indic digits are not letters', () {
      expect(detectTextDirection('١٢٣'), TextDirection.ltr);
      expect(
        detectTextDirection('١٢٣', fallback: TextDirection.rtl),
        TextDirection.rtl,
      );
    });

    test('text without a letter returns the fallback', () {
      expect(detectTextDirection(''), TextDirection.ltr);
      expect(
        detectTextDirection('', fallback: TextDirection.rtl),
        TextDirection.rtl,
      );
      expect(
        detectTextDirection('12345 -', fallback: TextDirection.rtl),
        TextDirection.rtl,
      );
    });

    test('a letter beyond the scan limit is ignored', () {
      final late = '${' ' * mreDirectionScanLimit}hello';

      expect(
        detectTextDirection(late, fallback: TextDirection.rtl),
        TextDirection.rtl,
      );
      expect(
        detectTextDirection('${' ' * (mreDirectionScanLimit - 1)}hello'),
        TextDirection.ltr,
      );
    });

    test('long text without a letter is cheap', () {
      final text = ' ' * 5000000;
      final watch = Stopwatch()..start();

      detectTextDirection(text);

      expect(watch.elapsedMilliseconds, lessThan(50));
    });

    test('unpaired surrogates do not throw', () {
      expect(detectTextDirection('\uD800'), TextDirection.ltr);
      expect(detectTextDirection('\uDC00 مرحبا'), TextDirection.rtl);
    });
  });

  group('detectStrongTextDirection', () {
    test('returns null without a strong letter', () {
      expect(detectStrongTextDirection(''), isNull);
      expect(detectStrongTextDirection('12345 -'), isNull);
      expect(detectStrongTextDirection('😀'), isNull);
    });

    test('returns the direction of the first word with a letter', () {
      expect(detectStrongTextDirection('(#1) مرحبا'), TextDirection.rtl);
      expect(detectStrongTextDirection('2024 Report مرحبا'), TextDirection.ltr);
      expect(detectStrongTextDirection('Wi-Fi مرحبا'), TextDirection.ltr);
    });
  });

  group('MRETextDirection', () {
    test('autoTextAlign is the side the content starts on', () {
      expect('مرحبا'.autoTextAlign, TextAlign.right);
      expect('Hello'.autoTextAlign, TextAlign.left);
      expect('12345'.autoTextAlign, TextAlign.start);
      expect(''.autoTextAlign, TextAlign.start);
    });

    test('getters follow detectTextDirection', () {
      expect('مرحبا'.textDirection, TextDirection.rtl);
      expect('مرحبا'.isRtl, isTrue);
      expect('Hello'.isRtl, isFalse);
      expect('12345'.directionOr(TextDirection.rtl), TextDirection.rtl);
      expect('Hello'.directionOr(TextDirection.rtl), TextDirection.ltr);
    });
  });

  group('safeDisplayText', () {
    test('returns clean text unchanged', () {
      expect(safeDisplayText(''), '');
      expect(safeDisplayText('Hello مرحبا'), 'Hello مرحبا');
    });

    test('keeps valid surrogate pairs', () {
      expect(safeDisplayText('a😀b'), 'a😀b');
    });

    test('replaces an unpaired high surrogate', () {
      expect(safeDisplayText('a\uD800b'), 'a�b');
      expect(safeDisplayText('end\uD800'), 'end�');
    });

    test('replaces an unpaired low surrogate', () {
      expect(safeDisplayText('a\uDC00b'), 'a�b');
    });

    test('replaces only the broken half of a mixed string', () {
      expect(safeDisplayText('😀\uD800😀'), '😀�😀');
    });
  });
}
