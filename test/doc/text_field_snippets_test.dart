import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

import '../../doc/snippets/text_field.dart';
import '../../doc/snippets/theme.dart' as theme_snippets;

Widget _host(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

TextField _textField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

void main() {
  testWidgets('basic: shows a clear button once there is text', (tester) async {
    await tester.pumpWidget(_host(basicField()));
    expect(find.byType(MREFieldClearButton), findsNothing);

    await tester.enterText(find.byType(TextField), 'مرحبا');
    await tester.pump();

    expect(find.byType(MREFieldClearButton), findsOneWidget);
    expect(_textField(tester).textDirection, TextDirection.rtl);
  });

  testWidgets('override_one_field: beats a theme radius for that field only', (
    tester,
  ) async {
    final theme = ThemeData(
      extensions: const [MREFieldsTheme(fieldBorderRadius: 16)],
    );
    await tester.pumpWidget(
      _host(
        Column(
          children: [
            overrideOneField(),
            const MRETextField(key: Key('other')),
          ],
        ),
        theme: theme,
      ),
    );

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    OutlineInputBorder border(TextField f) =>
        f.decoration!.border! as OutlineInputBorder;

    expect(border(fields[0]).borderRadius, BorderRadius.circular(28));
    expect(border(fields[1]).borderRadius, BorderRadius.circular(16));
  });

  testWidgets('one_field (theme guide) is the same example', (tester) async {
    await tester.pumpWidget(_host(theme_snippets.oneFieldOverride()));

    final border = _textField(tester).decoration!.border! as OutlineInputBorder;
    expect(border.borderRadius, BorderRadius.circular(28));
  });

  testWidgets('lock_direction: stays left to right in Arabic', (tester) async {
    await tester.pumpWidget(_host(lockedDirection()));

    await tester.enterText(find.byType(TextField), 'مرحبا');
    await tester.pump();

    expect(_textField(tester).textDirection, TextDirection.ltr);
    expect(_textField(tester).keyboardType, TextInputType.emailAddress);
  });

  testWidgets('form: reports the error until a name is entered', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(_host(nameForm(formKey)));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter a name'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Mona');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('suggestions: shows at most five matches while focused', (
    tester,
  ) async {
    await tester.pumpWidget(_host(suggestionsField()));

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(find.byType(ActionChip), findsNWidgets(4));
    expect(find.text('القاهرة'), findsOneWidget);
  });

  testWidgets('select_on_focus: selects the draft', (tester) async {
    await tester.pumpWidget(_host(selectOnFocus()));

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump();

    final controller = _textField(tester).controller!;
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 5),
    );
  });

  testWidgets('controller: uses the controller you pass', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(withController(controller)));

    await tester.enterText(find.byType(TextField), 'note');

    expect(controller.text, 'note');
    expect(_textField(tester).maxLines, 4);
  });

  testWidgets('clear_button: empties a plain TextField', (tester) async {
    final controller = TextEditingController(text: 'abc');
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(clearButtonAlone(controller)));

    await tester.tap(find.byType(MREFieldClearButton));

    expect(controller.text, '');
  });

  testWidgets('suggestion_bar: fills a plain TextField', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(suggestionBarAlone(controller)));

    await tester.tap(find.text('Giza'));

    expect(controller.text, 'Giza');
  });
}
