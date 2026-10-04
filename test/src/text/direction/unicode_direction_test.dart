import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

void main() {
  test('neutral punctuation, marks and emoji do not decide direction', () {
    for (final prefix in [
      '،',
      '。',
      '、',
      '…',
      '\u0301',
      '\u064E',
      '❤️',
      '🧑🏽‍💻',
      '١٢٣',
      '۱۲۳',
    ]) {
      expect(
        detectStrongTextDirection('$prefix Hello'),
        TextDirection.ltr,
        reason: prefix,
      );
      expect(
        detectStrongTextDirection('$prefix שלום'),
        TextDirection.rtl,
        reason: prefix,
      );
      expect(detectStrongTextDirection(prefix), isNull, reason: prefix);
    }
  });

  test(
    'Unicode writing systems are supported, including supplementary planes',
    () {
      for (final text in [
        'Hello',
        'Bonjour',
        'Olá',
        'Привет',
        'Γεια',
        'Բարեւ',
        'გამარჯობა',
        'नमस्ते',
        'বাংলা',
        'தமிழ்',
        'తెలుగు',
        'ไทย',
        'ສະບາຍດີ',
        'မြန်မာ',
        'ខ្មែរ',
        '你好',
        'こんにちは',
        '안녕하세요',
        'ሰላም',
        'ᎣᏏᏲ',
        '\u{10400}',
        '\u{20000}',
      ]) {
        expect(
          detectStrongTextDirection(text),
          TextDirection.ltr,
          reason: text,
        );
      }
      for (final text in [
        'مرحبا',
        'שלום',
        'فارسی',
        'اردو',
        'ܫܠܡܐ',
        'ދިވެހި',
        'ߊߟߎ',
        'ࠔࠋࠌ',
        'ࡀࡁ',
        '\u{10800}',
        '؟',
        '؛',
        '\u{10900}',
        '\u{1E900}',
        '\u{10D00}',
        '\u{10D50}',
        '\u{1EE01}',
      ]) {
        expect(
          detectStrongTextDirection(text),
          TextDirection.rtl,
          reason: text,
        );
      }
    },
  );

  test(
    'isolated content and embedding controls do not decide outer direction',
    () {
      expect(
        detectStrongTextDirection('\u2067שלום\u2069 Hello'),
        TextDirection.ltr,
      );
      expect(
        detectStrongTextDirection('\u2066Hello\u2069 שלום'),
        TextDirection.rtl,
      );
      expect(detectStrongTextDirection('\u2068Hello'), isNull);
      expect(detectStrongTextDirection('\u202BHello'), TextDirection.ltr);
      expect(detectStrongTextDirection('\u200FHello'), TextDirection.rtl);
    },
  );

  test('malformed and truncated surrogate pairs remain neutral', () {
    expect(detectStrongTextDirection('\uD802Hello'), TextDirection.ltr);
    expect(detectStrongTextDirection('\uD83B'), isNull);
    expect(
      detectStrongTextDirection(
        '${' ' * (mreDirectionScanLimit - 1)}\u{10900}',
      ),
      isNull,
    );
    expect(
      detectStrongTextDirection(
        '${' ' * (mreDirectionScanLimit - 2)}\u{10900}',
      ),
      TextDirection.rtl,
    );
  });
}
