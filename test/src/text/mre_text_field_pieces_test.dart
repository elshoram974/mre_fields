import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

void main() {
  group('mreFilterSuggestions', () {
    const all = ['Cairo', 'Alexandria', 'Giza', 'Luxor'];

    test('an empty query matches everything', () {
      expect(mreFilterSuggestions(all, ''), all);
      expect(mreFilterSuggestions(all, '   '), all);
    });

    test('matches inside the text and ignores case', () {
      expect(mreFilterSuggestions(all, 'AL'), ['Alexandria']);
      expect(mreFilterSuggestions(all, 'r'), ['Cairo', 'Alexandria', 'Luxor']);
    });

    test('drops the suggestion that equals the query', () {
      expect(mreFilterSuggestions(all, 'giza'), isEmpty);
    });

    test('stops at the limit', () {
      expect(mreFilterSuggestions(all, '', limit: 2), ['Cairo', 'Alexandria']);
    });

    test('works with Arabic', () {
      expect(mreFilterSuggestions(['القاهرة', 'الإسكندرية'], 'قاه'), [
        'القاهرة',
      ]);
    });
  });

  group('MRESuggestionBar', () {
    testWidgets('shows a chip per suggestion and reports the tapped one', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MRESuggestionBar(
              suggestions: const ['A', 'B'],
              onSelected: (v) => picked = v,
            ),
          ),
        ),
      );

      expect(find.byType(ActionChip), findsNWidgets(2));
      await tester.tap(find.text('B'));

      expect(picked, 'B');
    });

    testWidgets('uses itemBuilder when given', (tester) async {
      String? picked;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MRESuggestionBar(
              suggestions: const ['A'],
              onSelected: (v) => picked = v,
              itemBuilder: (context, suggestion, select) => TextButton(
                onPressed: select,
                child: Text('pick $suggestion'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ActionChip), findsNothing);
      await tester.tap(find.text('pick A'));

      expect(picked, 'A');
    });

    testWidgets('scrolls instead of overflowing at large text', (tester) async {
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, app) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: app!,
          ),
          home: Scaffold(
            body: MRESuggestionBar(
              suggestions: const [
                'Cairo',
                'Alexandria',
                'Giza',
                'Luxor',
                'Aswan',
              ],
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('MREFieldClearButton', () {
    testWidgets('calls onPressed and shows its tooltip', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MREFieldClearButton(
              onPressed: () => pressed++,
              tooltip: 'Clear it',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MREFieldClearButton));

      expect(pressed, 1);
      expect(find.byTooltip('Clear it'), findsOneWidget);
    });

    testWidgets('has a touch target of at least 40', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: MREFieldClearButton(onPressed: () {})),
          ),
        ),
      );

      final size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(40));
      expect(size.height, greaterThanOrEqualTo(40));
    });
  });

  group('MRESafeTextEditingController', () {
    test('keeps clean text and selection', () {
      final controller = MRESafeTextEditingController(text: 'Hello');
      addTearDown(controller.dispose);

      controller.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 3,
      );

      expect(controller.text, 'Hello');
      expect(
        controller.selection,
        const TextSelection(baseOffset: 1, extentOffset: 3),
      );
    });

    test('replaces unpaired surrogates when the text is set', () {
      final controller = MRESafeTextEditingController(text: 'a\uD800b');
      addTearDown(controller.dispose);

      expect(controller.text, 'a�b');

      controller.text = 'x\uDC00';
      expect(controller.text, 'x�');
    });

    test('keeps valid pairs', () {
      final controller = MRESafeTextEditingController(text: 'a😀b');
      addTearDown(controller.dispose);

      expect(controller.text, 'a😀b');
    });

    test('clamps the selection to the shorter text', () {
      final controller = MRESafeTextEditingController();
      addTearDown(controller.dispose);

      controller.value = const TextEditingValue(
        text: '\uD800\uD800',
        selection: TextSelection.collapsed(offset: 10),
      );

      expect(controller.text, '��');
      expect(controller.selection.extentOffset, 2);
      expect(controller.value.composing, TextRange.empty);
    });

    testWidgets('draws without throwing when the composing range cuts a pair', (
      tester,
    ) async {
      final controller = MRESafeTextEditingController(text: 'a😀b');
      addTearDown(controller.dispose);
      controller.value = controller.value.copyWith(
        composing: const TextRange(start: 2, end: 3),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TextField(controller: controller)),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
