import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

import '../../doc/snippets/theme.dart';

MREFieldsTheme _tokensOf(WidgetTester tester) {
  return MREFieldsTheme.of(tester.element(find.byType(AdaptiveBox)));
}

void main() {
  testWidgets('global: tokens reach every widget below the app', (
    tester,
  ) async {
    await tester.pumpWidget(globalTheme());

    final tokens = _tokensOf(tester);
    expect(tokens.fieldBorderRadius, 16);
    expect(
      tokens.contentPadding,
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
    expect(tokens.compactBreakpoint, MREFieldsTheme.defaultCompactBreakpoint);
  });

  test('copy_with: changes one token, keeps the rest', () {
    final tokens = squarerFields();

    expect(tokens.fieldBorderRadius, 4);
    expect(tokens.contentPadding, MREFieldsTheme.defaultContentPadding);
    expect(tokens.strings, MREFieldsTheme.defaults.strings);
  });

  testWidgets('light_dark: dark theme keeps the tokens', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await tester.pumpWidget(lightAndDark());

    expect(
      Theme.of(tester.element(find.byType(AdaptiveBox))).brightness,
      Brightness.dark,
    );
    expect(_tokensOf(tester).fieldBorderRadius, 16);
  });

  test('breakpoints: custom values classify widths', () {
    final tokens = customBreakpoints();

    expect(tokens.windowSizeFor(479), MREWindowSize.compact);
    expect(tokens.windowSizeFor(1024), MREWindowSize.expanded);
  });

  group('strings', () {
    test('stringsFor returns Arabic texts and an English fallback', () {
      expect(stringsFor(const Locale('ar')).clearTooltip, 'مسح');
      expect(stringsFor(const Locale('fr')), const MREFieldsStrings());
    });

    testWidgets('localizedApp follows the app locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('en'), Locale('ar')],
          builder: (context, child) => localizedFields(context, child!),
          home: const HomePage(),
        ),
      );

      expect(_tokensOf(tester).strings.clearTooltip, 'مسح');
    });

    testWidgets('localizedApp keeps English by default', (tester) async {
      await tester.pumpWidget(localizedApp());

      expect(_tokensOf(tester).strings.clearTooltip, 'Clear');
    });
  });

  group('read_tokens', () {
    Future<void> pumpAt(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(globalTheme());
    }

    testWidgets('compact width uses the compact padding', (tester) async {
      await pumpAt(tester, 400);

      expect(find.text('Window size: compact'), findsOneWidget);
      expect(
        tester
            .widget<Padding>(
              find
                  .ancestor(
                    of: find.text('Window size: compact'),
                    matching: find.byType(Padding),
                  )
                  .first,
            )
            .padding,
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    });

    testWidgets('expanded width uses the expanded padding', (tester) async {
      await pumpAt(tester, 1000);

      expect(find.text('Window size: expanded'), findsOneWidget);
      expect(
        tester
            .widget<Padding>(
              find
                  .ancestor(
                    of: find.text('Window size: expanded'),
                    matching: find.byType(Padding),
                  )
                  .first,
            )
            .padding,
        MREFieldsTheme.defaultExpandedContentPadding,
      );
    });
  });
}
