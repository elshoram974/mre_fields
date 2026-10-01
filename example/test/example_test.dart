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
