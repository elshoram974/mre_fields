import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

Widget _app(Widget child, {TextDirection ambient = TextDirection.ltr}) {
  return Directionality(textDirection: ambient, child: child);
}

/// The direction the text really lays out with, own or inherited.
TextDirection _directionOf(WidgetTester tester) {
  final rich = tester.widget<RichText>(find.byType(RichText));
  return rich.textDirection ??
      Directionality.of(tester.element(find.byType(RichText)));
}

void main() {
  group('MREAutoText', () {
    testWidgets('Arabic text is rtl in an ltr app', (tester) async {
      await tester.pumpWidget(_app(const MREAutoText('مرحبا')));

      expect(_directionOf(tester), TextDirection.rtl);
    });

    testWidgets('English text is ltr in an rtl app', (tester) async {
      await tester.pumpWidget(
        _app(const MREAutoText('Hello'), ambient: TextDirection.rtl),
      );

      expect(_directionOf(tester), TextDirection.ltr);
    });

    testWidgets('text without a letter keeps the app direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const MREAutoText('12345'), ambient: TextDirection.rtl),
      );

      expect(_directionOf(tester), TextDirection.rtl);
    });

    testWidgets('textDirection turns detection off', (tester) async {
      await tester.pumpWidget(
        _app(const MREAutoText('مرحبا', textDirection: TextDirection.ltr)),
      );

      expect(_directionOf(tester), TextDirection.ltr);
    });

    testWidgets('direction follows a changed text', (tester) async {
      await tester.pumpWidget(_app(const MREAutoText('Hello')));
      expect(_directionOf(tester), TextDirection.ltr);

      await tester.pumpWidget(_app(const MREAutoText('مرحبا')));
      expect(_directionOf(tester), TextDirection.rtl);
    });

    testWidgets('passes Text parameters through', (tester) async {
      await tester.pumpWidget(
        _app(
          const MREAutoText(
            'Hello',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            semanticsLabel: 'greeting',
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.textAlign, TextAlign.center);
      expect(text.semanticsLabel, 'greeting');
    });

    testWidgets('passes the remaining Text parameters through', (tester) async {
      await tester.pumpWidget(
        _app(
          const MREAutoText(
            'Hello',
            style: TextStyle(fontSize: 30),
            locale: Locale('en'),
            textWidthBasis: TextWidthBasis.longestLine,
            textHeightBehavior: TextHeightBehavior(
              applyHeightToFirstAscent: false,
            ),
            selectionColor: Colors.red,
            semanticsIdentifier: 'greeting-id',
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontSize, 30);
      expect(text.locale, const Locale('en'));
      expect(text.textWidthBasis, TextWidthBasis.longestLine);
      expect(text.selectionColor, Colors.red);
      expect(text.semanticsIdentifier, 'greeting-id');
    });

    testWidgets('autoAlign pins Arabic to the right and English to the left', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const MREAutoText('مرحبا', autoAlign: true)),
      );
      expect(tester.widget<Text>(find.byType(Text)).textAlign, TextAlign.right);

      await tester.pumpWidget(
        _app(const MREAutoText('Hello', autoAlign: true)),
      );
      expect(tester.widget<Text>(find.byType(Text)).textAlign, TextAlign.left);
    });

    testWidgets('textAlign wins over autoAlign', (tester) async {
      await tester.pumpWidget(
        _app(
          const MREAutoText(
            'مرحبا',
            autoAlign: true,
            textAlign: TextAlign.center,
          ),
        ),
      );

      expect(
        tester.widget<Text>(find.byType(Text)).textAlign,
        TextAlign.center,
      );
    });

    testWidgets('rich text follows the plain text of its spans', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const MREAutoText.rich(
            TextSpan(
              text: 'مرحبا ',
              children: [TextSpan(text: 'world')],
            ),
          ),
        ),
      );

      expect(_directionOf(tester), TextDirection.rtl);
      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('MREDirectionalWidget.withTextDirection', () {
    Finder directionalityIn(Key key) {
      return find.descendant(
        of: find.byKey(key),
        matching: find.byType(Directionality),
      );
    }

    testWidgets('adds a Directionality when the direction differs', (
      tester,
    ) async {
      const key = Key('host');
      await tester.pumpWidget(
        _app(
          Container(
            key: key,
            child: const Text('x').withTextDirection('مرحبا'),
          ),
        ),
      );

      final wrapper = tester.widget<Directionality>(directionalityIn(key));
      expect(wrapper.textDirection, TextDirection.rtl);
    });

    testWidgets('adds nothing when the direction already matches', (
      tester,
    ) async {
      const key = Key('host');
      await tester.pumpWidget(
        _app(
          Container(
            key: key,
            child: const Text('x').withTextDirection('Hello'),
          ),
        ),
      );

      expect(directionalityIn(key), findsNothing);
    });

    testWidgets('keeps the app direction for text without a letter', (
      tester,
    ) async {
      const key = Key('host');
      await tester.pumpWidget(
        _app(
          Container(key: key, child: const Text('x').withTextDirection('123')),
          ambient: TextDirection.rtl,
        ),
      );

      expect(directionalityIn(key), findsNothing);
    });
  });
}
