import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

/// Pumps [child] in a themed app, [width] wide, with an optional [textScale].
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  double width = 400,
  double textScale = 1,
  TextDirection ambient = TextDirection.ltr,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: ambient, child: app!),
      ),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

/// Types [text] and builds the frame the field rebuilds in.
Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

TextField _textField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

InputDecoration _decoration(WidgetTester tester) =>
    _textField(tester).decoration!;

void main() {
  group('direction', () {
    testWidgets('follows the typed language and returns to the app direction', (
      tester,
    ) async {
      await _pump(tester, const MRETextField());
      expect(_textField(tester).textDirection, isNull);

      await _type(tester, 'مرحبا');
      expect(_textField(tester).textDirection, TextDirection.rtl);

      await _type(tester, 'مرحبا hello');
      expect(_textField(tester).textDirection, TextDirection.rtl);

      await _type(tester, 'Hello');
      expect(_textField(tester).textDirection, TextDirection.ltr);

      await _type(tester, '');
      expect(_textField(tester).textDirection, isNull);
    });

    testWidgets('digits alone keep the app direction', (tester) async {
      await _pump(tester, const MRETextField());

      await _type(tester, '12345');

      expect(_textField(tester).textDirection, isNull);
    });

    testWidgets('a leading number does not decide', (tester) async {
      await _pump(tester, const MRETextField());

      await _type(tester, '123 مرحبا');

      expect(_textField(tester).textDirection, TextDirection.rtl);
    });

    testWidgets('English typed in a right to left app is left to right', (
      tester,
    ) async {
      await _pump(tester, const MRETextField(), ambient: TextDirection.rtl);

      await _type(tester, 'Hello');

      expect(_textField(tester).textDirection, TextDirection.ltr);
    });

    testWidgets('textDirection locks the direction', (tester) async {
      await _pump(tester, const MRETextField(textDirection: TextDirection.ltr));

      await _type(tester, 'مرحبا');

      expect(_textField(tester).textDirection, TextDirection.ltr);
    });

    testWidgets('initial Arabic text starts right to left', (tester) async {
      await _pump(tester, const MRETextField(initialValue: 'مرحبا'));

      expect(_textField(tester).textDirection, TextDirection.rtl);
    });

    testWidgets('textAlign wins over the default start', (tester) async {
      await _pump(tester, const MRETextField(textAlign: TextAlign.center));

      expect(_textField(tester).textAlign, TextAlign.center);
    });
  });

  group('rebuilds', () {
    testWidgets(
      'typing more letters of the same language does not rebuild the field',
      (tester) async {
        await _pump(tester, const MRETextField());
        var rebuilds = 0;
        // The field rebuilds through a ValueListenableBuilder over its flags.
        debugOnRebuildDirtyWidget = (element, builtOnce) {
          if (element.widget.runtimeType.toString().contains('_FieldFlags')) {
            rebuilds++;
          }
        };
        addTearDown(() => debugOnRebuildDirtyWidget = null);

        await _type(tester, 'H');
        final afterFirst = rebuilds;
        for (final text in [
          'He',
          'Hel',
          'Hell',
          'Hello',
          'Hello w',
          'Hello wo',
        ]) {
          await _type(tester, text);
        }

        expect(afterFirst, 1, reason: 'empty to text, no direction to ltr');
        expect(rebuilds, afterFirst);
      },
    );
  });

  group('clear button', () {
    testWidgets('is off by default', (tester) async {
      await _pump(tester, const MRETextField(initialValue: 'abc'));

      expect(find.byType(MREFieldClearButton), findsNothing);
    });

    testWidgets('shows only while there is text', (tester) async {
      await _pump(tester, const MRETextField(showClearButton: true));
      expect(find.byType(MREFieldClearButton), findsNothing);

      await _type(tester, 'abc');
      await tester.pump();
      expect(find.byType(MREFieldClearButton), findsOneWidget);

      await _type(tester, '');
      await tester.pump();
      expect(find.byType(MREFieldClearButton), findsNothing);
    });

    testWidgets('empties the field and reports the change', (tester) async {
      final changes = <String>[];
      final controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);
      await _pump(
        tester,
        MRETextField(
          controller: controller,
          showClearButton: true,
          onChanged: changes.add,
        ),
      );

      await tester.tap(find.byType(MREFieldClearButton));
      await tester.pump();

      expect(controller.text, '');
      expect(changes, ['']);
      expect(find.byType(MREFieldClearButton), findsNothing);
    });

    testWidgets('direction returns to the app direction after clearing', (
      tester,
    ) async {
      await _pump(
        tester,
        const MRETextField(initialValue: 'مرحبا', showClearButton: true),
      );
      expect(_textField(tester).textDirection, TextDirection.rtl);

      await tester.tap(find.byType(MREFieldClearButton));
      await tester.pump();

      expect(_textField(tester).textDirection, isNull);
    });

    testWidgets('uses the tooltip from MREFieldsStrings', (tester) async {
      await _pump(
        tester,
        const MRETextField(initialValue: 'abc', showClearButton: true),
        theme: ThemeData(
          extensions: const [
            MREFieldsTheme(strings: MREFieldsStrings(clearTooltip: 'مسح')),
          ],
        ),
      );

      expect(find.byTooltip('مسح'), findsOneWidget);
    });

    testWidgets('clearTooltip wins over the theme', (tester) async {
      await _pump(
        tester,
        const MRETextField(
          initialValue: 'abc',
          showClearButton: true,
          clearTooltip: 'Reset',
        ),
        theme: ThemeData(
          extensions: const [
            MREFieldsTheme(strings: MREFieldsStrings(clearTooltip: 'مسح')),
          ],
        ),
      );

      expect(find.byTooltip('Reset'), findsOneWidget);
      expect(find.byTooltip('مسح'), findsNothing);
    });

    testWidgets('is hidden when read only or disabled', (tester) async {
      await _pump(
        tester,
        const MRETextField(
          initialValue: 'abc',
          showClearButton: true,
          readOnly: true,
        ),
      );
      expect(find.byType(MREFieldClearButton), findsNothing);

      await _pump(
        tester,
        const MRETextField(
          initialValue: 'abc',
          showClearButton: true,
          enabled: false,
        ),
      );
      expect(find.byType(MREFieldClearButton), findsNothing);
    });

    testWidgets('sits next to a suffix icon', (tester) async {
      await _pump(
        tester,
        const MRETextField(
          initialValue: 'abc',
          showClearButton: true,
          suffixIcon: Icon(Icons.search, key: Key('search')),
        ),
      );

      expect(find.byType(MREFieldClearButton), findsOneWidget);
      expect(find.byKey(const Key('search')), findsOneWidget);
    });
  });

  group('select text on focus', () {
    testWidgets('selects all text when focused', (tester) async {
      final controller = TextEditingController(text: 'Hello');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      await _pump(
        tester,
        MRETextField(
          controller: controller,
          focusNode: focusNode,
          selectTextOnFocus: true,
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      await tester.pump();

      expect(
        controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 5),
      );
    });

    testWidgets('does not select when the option is off', (tester) async {
      final controller = TextEditingController(text: 'Hello');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      await _pump(
        tester,
        MRETextField(controller: controller, focusNode: focusNode),
      );

      focusNode.requestFocus();
      await tester.pump();
      await tester.pump();

      expect(controller.selection.isCollapsed, isTrue);
    });
  });

  group('suggestions', () {
    const cities = ['Cairo', 'Alexandria', 'Giza', 'القاهرة'];

    testWidgets('are hidden until the field has focus', (tester) async {
      await _pump(tester, const MRETextField(suggestions: cities));

      expect(find.byType(MRESuggestionBar), findsNothing);
    });

    testWidgets('show all on focus and filter while typing', (tester) async {
      await _pump(tester, const MRETextField(suggestions: cities));

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(find.byType(ActionChip), findsNWidgets(4));

      await _type(tester, 'AL');
      await tester.pump();
      expect(find.widgetWithText(ActionChip, 'Alexandria'), findsOneWidget);
      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('hide the one that equals the text', (tester) async {
      await _pump(tester, const MRETextField(suggestions: cities));

      await tester.tap(find.byType(TextField));
      await _type(tester, 'giza');
      await tester.pump();

      expect(find.byType(MRESuggestionBar), findsNothing);
    });

    testWidgets('picking one fills the field and calls both callbacks', (
      tester,
    ) async {
      final changes = <String>[];
      final picks = <String>[];
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        MRETextField(
          controller: controller,
          suggestions: const ['Cairo', 'Giza'],
          onChanged: changes.add,
          onSuggestionSelected: picks.add,
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.tap(find.widgetWithText(ActionChip, 'Cairo'));
      await tester.pump();

      expect(controller.text, 'Cairo');
      expect(controller.selection, const TextSelection.collapsed(offset: 5));
      expect(changes, ['Cairo']);
      expect(picks, ['Cairo']);
    });

    testWidgets('picking one works on every platform', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        MRETextField(controller: controller, suggestions: const ['Cairo']),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.tap(find.widgetWithText(ActionChip, 'Cairo'));
      await tester.pump();

      expect(controller.text, 'Cairo');
    }, variant: TargetPlatformVariant.all());

    testWidgets('picking an Arabic suggestion switches the direction', (
      tester,
    ) async {
      await _pump(tester, const MRETextField(suggestions: ['القاهرة']));

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.tap(find.widgetWithText(ActionChip, 'القاهرة'));
      await tester.pump();

      expect(find.text('القاهرة'), findsOneWidget);
      expect(_textField(tester).textDirection, TextDirection.rtl);
    });

    testWidgets('maxSuggestions limits the bar', (tester) async {
      await _pump(
        tester,
        const MRETextField(suggestions: cities, maxSuggestions: 2),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(find.byType(ActionChip), findsNWidgets(2));
    });
  });

  group('theme and overrides', () {
    testWidgets('use the package padding without any registration', (
      tester,
    ) async {
      await _pump(tester, const MRETextField());

      expect(
        _decoration(tester).contentPadding,
        MREFieldsTheme.defaultContentPadding,
      );
      expect(
        _decoration(tester).border,
        isNull,
        reason: 'borders stay with the host theme',
      );
    });

    testWidgets('use the registered tokens', (tester) async {
      await _pump(
        tester,
        const MRETextField(),
        theme: ThemeData(
          extensions: const [
            MREFieldsTheme(
              fieldBorderRadius: 20,
              contentPadding: EdgeInsets.all(24),
            ),
          ],
        ),
      );

      expect(_decoration(tester).contentPadding, const EdgeInsets.all(24));
      final border = _decoration(tester).border! as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('use the expanded padding on wide space', (tester) async {
      const theme = MREFieldsTheme(
        contentPadding: EdgeInsets.all(24),
        expandedContentPadding: EdgeInsets.all(8),
      );
      await _pump(
        tester,
        const MRETextField(),
        theme: ThemeData(extensions: const [theme]),
        width: 1000,
      );

      expect(_decoration(tester).contentPadding, const EdgeInsets.all(8));
    });

    testWidgets('parameters win over the registered tokens', (tester) async {
      await _pump(
        tester,
        const MRETextField(borderRadius: 4, contentPadding: EdgeInsets.all(2)),
        theme: ThemeData(
          extensions: const [
            MREFieldsTheme(
              fieldBorderRadius: 20,
              contentPadding: EdgeInsets.all(24),
            ),
          ],
        ),
      );

      expect(_decoration(tester).contentPadding, const EdgeInsets.all(2));
      final border = _decoration(tester).border! as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(4));
    });

    testWidgets('a borderRadius parameter works without a registered theme', (
      tester,
    ) async {
      await _pump(tester, const MRETextField(borderRadius: 30));

      final border = _decoration(tester).border! as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(30));
    });

    testWidgets(
      'keep the host InputDecorationTheme padding when nothing is registered',
      (tester) async {
        await _pump(
          tester,
          const MRETextField(),
          theme: ThemeData(
            inputDecorationTheme: const InputDecorationThemeData(
              contentPadding: EdgeInsets.all(30),
            ),
          ),
        );

        expect(_decoration(tester).contentPadding, const EdgeInsets.all(30));
      },
    );

    testWidgets('apply the radius to the host outline borders', (tester) async {
      await _pump(
        tester,
        const MRETextField(borderRadius: 6),
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationThemeData(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      );

      final enabled = _decoration(tester).enabledBorder! as OutlineInputBorder;
      expect(enabled.borderRadius, BorderRadius.circular(6));
      expect(
        enabled.borderSide.color,
        Colors.red,
        reason: 'the host color is kept',
      );
    });

    testWidgets('leave a host underline border alone', (tester) async {
      await _pump(
        tester,
        const MRETextField(borderRadius: 6),
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationThemeData(
            border: UnderlineInputBorder(),
          ),
        ),
      );

      expect(_decoration(tester).border, isA<UnderlineInputBorder>());
    });

    testWidgets('the decoration parameter is the starting point', (
      tester,
    ) async {
      await _pump(
        tester,
        const MRETextField(
          hintText: 'From parameter',
          decoration: InputDecoration(
            hintText: 'From decoration',
            helperText: 'Help',
          ),
        ),
      );

      expect(_decoration(tester).hintText, 'From parameter');
      expect(_decoration(tester).helperText, 'Help');
    });
  });

  group('form', () {
    testWidgets('validates through the form', (tester) async {
      final formKey = GlobalKey<FormState>();
      await _pump(
        tester,
        Form(
          key: formKey,
          child: MRETextField(
            validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);

      await _type(tester, 'x');
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('validates through fieldKey without a form', (tester) async {
      final fieldKey = GlobalKey<FormFieldState<String>>();
      await _pump(
        tester,
        MRETextField(
          fieldKey: fieldKey,
          validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
        ),
      );

      expect(fieldKey.currentState!.validate(), isFalse);
    });

    testWidgets('validates after the user interacts', (tester) async {
      await _pump(
        tester,
        MRETextField(
          validator: (v) => (v ?? '').length < 3 ? 'Too short' : null,
        ),
      );
      expect(find.text('Too short'), findsNothing);

      await _type(tester, 'a');
      await tester.pump();

      expect(find.text('Too short'), findsOneWidget);
    });

    testWidgets('errorText is shown', (tester) async {
      await _pump(tester, const MRETextField(errorText: 'Taken'));

      expect(find.text('Taken'), findsOneWidget);
    });

    testWidgets('onSaved receives the text', (tester) async {
      final formKey = GlobalKey<FormState>();
      String? saved;
      await _pump(
        tester,
        Form(
          key: formKey,
          child: MRETextField(onSaved: (v) => saved = v),
        ),
      );

      await _type(tester, 'مرحبا');
      formKey.currentState!.save();

      expect(saved, 'مرحبا');
    });
  });

  group('keyboard', () {
    testWidgets('multiline fields get a newline action', (tester) async {
      await _pump(tester, const MRETextField(maxLines: 3));

      expect(_textField(tester).textInputAction, TextInputAction.newline);
    });

    testWidgets('textInputAction is passed through', (tester) async {
      await _pump(
        tester,
        const MRETextField(textInputAction: TextInputAction.search),
      );

      expect(_textField(tester).textInputAction, TextInputAction.search);
    });

    testWidgets('submit calls onFieldSubmitted', (tester) async {
      String? submitted;
      await _pump(tester, MRETextField(onFieldSubmitted: (v) => submitted = v));

      await _type(tester, 'done');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submitted, 'done');
    });

    testWidgets('inputFormatters are applied', (tester) async {
      await _pump(
        tester,
        MRETextField(inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
      );

      await _type(tester, 'a1b2');

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '12',
      );
    });
  });

  group('ownership', () {
    testWidgets('creates its own controller from initialValue', (tester) async {
      await _pump(tester, const MRETextField(initialValue: 'Hello'));

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('does not dispose a controller or focus node it was given', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'x');
      final focusNode = FocusNode();
      await _pump(
        tester,
        MRETextField(controller: controller, focusNode: focusNode),
      );

      await tester.pumpWidget(const SizedBox());

      expect(() => controller.text = 'y', returnsNormally);
      expect(() => focusNode.requestFocus(), returnsNormally);
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('switches to a new controller', (tester) async {
      final first = TextEditingController(text: 'مرحبا');
      final second = TextEditingController(text: 'Hello');
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await _pump(tester, MRETextField(controller: first));
      expect(_textField(tester).textDirection, TextDirection.rtl);

      await _pump(tester, MRETextField(controller: second));
      await tester.pump();

      expect(find.text('Hello'), findsOneWidget);
      expect(_textField(tester).textDirection, TextDirection.ltr);

      second.text = 'مرحبا';
      await tester.pump();
      expect(_textField(tester).textDirection, TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a new initialValue replaces the text of an owned controller', (
      tester,
    ) async {
      await _pump(tester, const MRETextField(initialValue: 'One'));

      await _pump(tester, const MRETextField(initialValue: 'Two'));
      await tester.pump();

      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('a new initialValue never touches a controller you own', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Mine');
      addTearDown(controller.dispose);

      await _pump(
        tester,
        MRETextField(controller: controller, initialValue: 'One'),
      );
      await _pump(
        tester,
        MRETextField(controller: controller, initialValue: 'Two'),
      );
      await tester.pump();

      expect(controller.text, 'Mine');
    });

    testWidgets('survives being removed while focused', (tester) async {
      await _pump(
        tester,
        const MRETextField(selectTextOnFocus: true, suggestions: ['a']),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('layout', () {
    const sizes = [390.0, 834.0, 1024.0];

    for (final width in sizes) {
      for (final scale in [1.0, 1.3]) {
        for (final ambient in TextDirection.values) {
          testWidgets(
            'has no overflow at $width wide, scale $scale, ${ambient.name}',
            (tester) async {
              await _pump(
                tester,
                const MRETextField(
                  labelText:
                      'A rather long label that must not clip at large text',
                  hintText: 'A long hint for the field',
                  initialValue: 'a',
                  showClearButton: true,
                  prefixIcon: Icon(Icons.person),
                  suggestions: [
                    'Cairo',
                    'Alexandria',
                    'Giza',
                    'Luxor',
                    'Aswan',
                    'Suez',
                  ],
                ),
                width: width,
                textScale: scale,
                ambient: ambient,
              );
              await tester.tap(find.byType(TextField));
              await tester.pump();

              expect(tester.takeException(), isNull);
              expect(find.byType(ActionChip), findsWidgets);
            },
          );
        }
      }
    }

    testWidgets('renders in a dark theme', (tester) async {
      await _pump(
        tester,
        const MRETextField(
          labelText: 'Name',
          initialValue: 'مرحبا',
          showClearButton: true,
        ),
        theme: ThemeData(brightness: Brightness.dark),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
