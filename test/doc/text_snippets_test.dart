import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../doc/snippets/text.dart';

Widget _host(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('auto_text: each text gets its own direction', (tester) async {
    await tester.pumpWidget(_host(autoText()));

    final directions = tester
        .widgetList<RichText>(find.byType(RichText))
        .where((r) => r.text.toPlainText().isNotEmpty)
        .map((r) => (r.text.toPlainText(), r.textDirection))
        .toList();

    expect(directions, contains(('مرحبا بالعالم', TextDirection.rtl)));
    expect(directions, contains(('Hello world', TextDirection.ltr)));
    expect(directions, contains(('مرحبا', TextDirection.ltr)));
  });

  test('detect: matches the comments in the example', () {
    expect(detectExamples(), [
      TextDirection.rtl,
      TextDirection.ltr,
      TextDirection.rtl,
      TextDirection.rtl,
      TextDirection.rtl,
    ]);
  });

  testWidgets('styled: keeps the style and pins the alignment', (tester) async {
    await tester.pumpWidget(_host(styledAutoText()));

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style?.fontSize, 20);
    expect(text.maxLines, 1);
    expect(text.textDirection, TextDirection.rtl);
    expect(text.textAlign, TextAlign.right);
  });

  testWidgets('text_extension: Arabic and English names', (tester) async {
    await tester.pumpWidget(_host(textExtension('محمد')));
    var text = tester.widget<Text>(find.byType(Text));
    expect(text.textDirection, TextDirection.rtl);
    expect(text.textAlign, TextAlign.right);
    expect(text.style?.fontSize, 20);

    await tester.pumpWidget(_host(textExtension('Mohamed')));
    text = tester.widget<Text>(find.byType(Text));
    expect(text.textDirection, TextDirection.ltr);
    expect(text.textAlign, TextAlign.left);
  });

  test('align_getter: matches the comments in the example', () {
    expect(alignExamples(), [TextAlign.right, TextAlign.left, TextAlign.start]);
  });

  test('extension_getters: matches the comments in the example', () {
    expect(extensionGetters(), [true, TextDirection.rtl]);
  });

  testWidgets('with_text_direction: Arabic name flips the tile', (
    tester,
  ) async {
    await tester.pumpWidget(_host(nameTile('محمد')));

    final tile = find.byType(ListTile);
    final direction = Directionality.of(tester.element(tile));
    expect(direction, TextDirection.rtl);
  });

  testWidgets('with_text_direction: English name keeps the tile', (
    tester,
  ) async {
    await tester.pumpWidget(_host(nameTile('Mohamed')));

    final direction = Directionality.of(tester.element(find.byType(ListTile)));
    expect(direction, TextDirection.ltr);
  });

  testWidgets('safe_text: broken text lays out without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(_host(pastedLabel('a\uD800b')));

    expect(find.text('a�b'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
