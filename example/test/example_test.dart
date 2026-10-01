import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields_example/app.dart';

void main() {
  testWidgets('the home page shows every section', (tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Text direction'), findsOneWidget);
    expect(find.text('Text field'), findsOneWidget);
    expect(find.text('Phone number'), findsWidgets);
    expect(find.text('Image paste'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a sample chip fills the field and flips the result', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExampleApp());

    await tester.tap(find.widgetWithText(ActionChip, 'مرحبا بالعالم'));
    await tester.pump();

    expect(find.text('MREAutoText · rtl'), findsOneWidget);
  });

  testWidgets('a sample number fills the phone field and shows its country', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExampleApp());

    await tester.tap(find.widgetWithText(ActionChip, '+966 50 123 4567'));
    await tester.pump();

    expect(find.text('Country: Saudi Arabia'), findsOneWidget);
    expect(find.text('Valid'), findsOneWidget);
  });

  testWidgets('the language button switches to Arabic', (tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExampleApp());

    await tester.tap(find.byTooltip('English or Arabic'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
