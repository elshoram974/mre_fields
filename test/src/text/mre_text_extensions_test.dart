import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

void main() {
  group('autoDirection', () {
    test('sets the direction from the content', () {
      expect(
        const Text('مرحبا').autoDirection().textDirection,
        TextDirection.rtl,
      );
      expect(
        const Text('Hello').autoDirection().textDirection,
        TextDirection.ltr,
      );
    });

    test('follows the first word, not the whole text', () {
      expect(
        const Text('123 مرحبا hello world').autoDirection().textDirection,
        TextDirection.rtl,
      );
      expect(
        const Text('Hello مرحبا مرحبا مرحبا').autoDirection().textDirection,
        TextDirection.ltr,
      );
    });

    test('keeps a direction that is already set', () {
      const original = Text('مرحبا', textDirection: TextDirection.ltr);

      expect(original.autoDirection(), same(original));
    });

    test('returns the same Text when there is no strong letter', () {
      const original = Text('12345');

      expect(original.autoDirection(), same(original));
    });

    test('keeps every other property', () {
      const key = Key('name');
      const original = Text(
        'مرحبا',
        key: key,
        style: TextStyle(fontSize: 22),
        strutStyle: StrutStyle(fontSize: 22),
        textAlign: TextAlign.center,
        locale: Locale('ar'),
        softWrap: false,
        overflow: TextOverflow.fade,
        textScaler: TextScaler.linear(1.5),
        maxLines: 3,
        semanticsLabel: 'name',
        semanticsIdentifier: 'name-id',
        textWidthBasis: TextWidthBasis.longestLine,
        textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
        selectionColor: Colors.red,
      );

      final copy = original.autoDirection();

      expect(copy.key, key);
      expect(copy.data, 'مرحبا');
      expect(copy.style, original.style);
      expect(copy.strutStyle, original.strutStyle);
      expect(copy.textAlign, TextAlign.center);
      expect(copy.locale, original.locale);
      expect(copy.softWrap, false);
      expect(copy.overflow, TextOverflow.fade);
      expect(copy.textScaler, original.textScaler);
      expect(copy.maxLines, 3);
      expect(copy.semanticsLabel, 'name');
      expect(copy.semanticsIdentifier, 'name-id');
      expect(copy.textWidthBasis, TextWidthBasis.longestLine);
      expect(copy.textHeightBehavior, original.textHeightBehavior);
      expect(copy.selectionColor, Colors.red);
      expect(copy.textDirection, TextDirection.rtl);
    });

    test('keeps the spans of Text.rich', () {
      const spans = TextSpan(
        text: 'مرحبا ',
        children: [TextSpan(text: 'world')],
      );

      final copy = const Text.rich(spans).autoDirection();

      expect(copy.textSpan, same(spans));
      expect(copy.data, isNull);
      expect(copy.textDirection, TextDirection.rtl);
    });
  });

  group('autoAlign', () {
    test('aligns to the side the content starts on', () {
      expect(const Text('مرحبا').autoAlign().textAlign, TextAlign.right);
      expect(const Text('Hello').autoAlign().textAlign, TextAlign.left);
    });

    test('keeps an alignment that is already set', () {
      const original = Text('مرحبا', textAlign: TextAlign.center);

      expect(original.autoAlign(), same(original));
    });

    test('returns the same Text when there is no strong letter', () {
      const original = Text('12345');

      expect(original.autoAlign(), same(original));
    });

    test('chains with autoDirection', () {
      final text = const Text('مرحبا').autoDirection().autoAlign();

      expect(text.textDirection, TextDirection.rtl);
      expect(text.textAlign, TextAlign.right);
    });
  });
}
