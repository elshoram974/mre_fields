import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

Future<MREFieldsTheme> _resolve(WidgetTester tester, ThemeData theme) async {
  late MREFieldsTheme resolved;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          resolved = MREFieldsTheme.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return resolved;
}

void main() {
  group('MREFieldsTheme.of', () {
    testWidgets('falls back to defaults without a registered extension', (
      tester,
    ) async {
      final theme = await _resolve(tester, ThemeData());

      expect(theme, same(MREFieldsTheme.defaults));
      expect(theme.fieldBorderRadius, MREFieldsTheme.defaultFieldBorderRadius);
      expect(theme.contentPadding, MREFieldsTheme.defaultContentPadding);
      expect(theme.strings, const MREFieldsStrings());
    });

    testWidgets('returns the values registered on the host theme', (
      tester,
    ) async {
      const registered = MREFieldsTheme(
        fieldBorderRadius: 20,
        contentPadding: EdgeInsets.all(24),
        strings: MREFieldsStrings(clearTooltip: 'Löschen'),
      );

      final theme = await _resolve(
        tester,
        ThemeData(extensions: const [registered]),
      );

      expect(theme, same(registered));
      expect(theme.fieldBorderRadius, 20);
      expect(theme.strings.clearTooltip, 'Löschen');
    });
  });

  group('windowSizeFor', () {
    const theme = MREFieldsTheme();

    test('uses the default breakpoints', () {
      expect(theme.windowSizeFor(0), MREWindowSize.compact);
      expect(theme.windowSizeFor(599.9), MREWindowSize.compact);
      expect(theme.windowSizeFor(600), MREWindowSize.medium);
      expect(theme.windowSizeFor(839.9), MREWindowSize.medium);
      expect(theme.windowSizeFor(840), MREWindowSize.expanded);
      expect(theme.windowSizeFor(2000), MREWindowSize.expanded);
    });

    test('uses custom breakpoints', () {
      const custom = MREFieldsTheme(
        compactBreakpoint: 400,
        expandedBreakpoint: 700,
      );

      expect(custom.windowSizeFor(399), MREWindowSize.compact);
      expect(custom.windowSizeFor(400), MREWindowSize.medium);
      expect(custom.windowSizeFor(700), MREWindowSize.expanded);
    });

    test('rejects breakpoints in the wrong order', () {
      expect(
        () => MREFieldsTheme(compactBreakpoint: 900, expandedBreakpoint: 800),
        throwsAssertionError,
      );
    });
  });

  group('contentPaddingFor', () {
    const theme = MREFieldsTheme(
      contentPadding: EdgeInsets.all(16),
      expandedContentPadding: EdgeInsets.all(8),
    );

    test('is denser only on expanded', () {
      expect(
        theme.contentPaddingFor(MREWindowSize.compact),
        const EdgeInsets.all(16),
      );
      expect(
        theme.contentPaddingFor(MREWindowSize.medium),
        const EdgeInsets.all(16),
      );
      expect(
        theme.contentPaddingFor(MREWindowSize.expanded),
        const EdgeInsets.all(8),
      );
    });
  });

  group('copyWith', () {
    test('replaces only the given values', () {
      const base = MREFieldsTheme(fieldBorderRadius: 8);
      final copy = base.copyWith(compactBreakpoint: 500);

      expect(copy.compactBreakpoint, 500);
      expect(copy.fieldBorderRadius, 8);
      expect(copy.expandedBreakpoint, base.expandedBreakpoint);
      expect(copy.strings, base.strings);
    });
  });

  group('lerp', () {
    const a = MREFieldsTheme(
      fieldBorderRadius: 0,
      contentPadding: EdgeInsets.all(0),
      strings: MREFieldsStrings(clearTooltip: 'A'),
    );
    const b = MREFieldsTheme(
      fieldBorderRadius: 20,
      contentPadding: EdgeInsets.all(20),
      strings: MREFieldsStrings(clearTooltip: 'B'),
    );

    test('interpolates numbers and paddings', () {
      final mid = a.lerp(b, 0.5);

      expect(mid.fieldBorderRadius, 10);
      expect(mid.contentPadding, const EdgeInsets.all(10));
    });

    test('switches strings at the halfway point', () {
      expect(a.lerp(b, 0.49).strings.clearTooltip, 'A');
      expect(a.lerp(b, 0.5).strings.clearTooltip, 'B');
    });

    test('returns itself for a foreign extension', () {
      expect(a.lerp(null, 0.5), same(a));
    });

    test('runs through ThemeData.lerp', () {
      final mid = ThemeData.lerp(
        ThemeData(extensions: const [a]),
        ThemeData(extensions: const [b]),
        0.5,
      );

      expect(mid.extension<MREFieldsTheme>()!.fieldBorderRadius, 10);
    });
  });
}
