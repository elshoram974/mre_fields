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
    ]);
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
