import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

final _egypt = MRECountries.byIsoCode('EG')!;
final _saudi = MRECountries.byIsoCode('SA')!;
final _canada = MRECountries.byIsoCode('CA')!;

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  Size size = const Size(420, 800),
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: direction, child: app!),
      ),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

/// Types [text] as one edit and builds the frame.
Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

/// Types [text] one character at a time, like a keyboard.
Future<void> _typeSlowly(WidgetTester tester, String text) async {
  for (var i = 1; i <= text.length; i++) {
    await _type(tester, text.substring(0, i));
  }
}

String _digits(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

Finder get _dialButton => find.byIcon(Icons.arrow_drop_down);

void main() {
  testWidgets('form validates a dial code still present in editor text', (
    tester,
  ) async {
    final phone = MREPhoneController(
      country: _egypt,
      nationalNumber: '+12045551234',
    );
    addTearDown(phone.dispose);
    final form = GlobalKey<FormState>();
    await _pump(
      tester,
      Form(
        key: form,
        child: MREPhoneFormField(controller: phone),
      ),
    );
    expect(phone.text.text, '+12045551234');
    expect(form.currentState!.validate(), isTrue);
    expect(phone.number().country, _canada);
    expect(phone.number().e164, '+12045551234');
    phone.text.text = '+999123456';
    await tester.pump();
    expect(form.currentState!.validate(), isFalse);
  });

  testWidgets('a plus in the middle does not select a different country', (
    tester,
  ) async {
    final phone = MREPhoneController(country: _egypt);
    addTearDown(phone.dispose);
    await _pump(tester, MREPhoneField(controller: phone));
    await _type(tester, '101+966501234567');
    expect(phone.country, _egypt);
    expect(phone.number().isValid, isFalse);
  });

  test('number parsing cache follows text, country and selection', () {
    final phone = MREPhoneController(
      country: _egypt,
      nationalNumber: '1012345678',
    );
    addTearDown(phone.dispose);
    final first = phone.number();
    expect(first.isValid, isTrue);
    expect(identical(first, phone.number()), isTrue);
    phone.text.selection = const TextSelection.collapsed(offset: 2);
    expect(identical(first, phone.number()), isTrue);
    phone.text.text = '+12045551234';
    expect(phone.number().country, _canada);
    phone.text.text = '1012345678';
    phone.country = _saudi;
    expect(phone.number().country, _saudi);
    phone.country = _egypt;
    expect(phone.number().e164, first.e164);
    expect(
      phone.number(MRECountrySelection(exclude: {'EG'})).error,
      MREPhoneError.countryNotAllowed,
    );
  });

  testWidgets(
    'typing with unchanged country does not rebuild the dial button',
    (tester) async {
      final phone = MREPhoneController(country: _egypt);
      addTearDown(phone.dispose);
      var builds = 0;
      var notifications = 0;
      phone.addListener(() => notifications++);
      await _pump(
        tester,
        MREPhoneField(
          controller: phone,
          countryNameBuilder: (country) {
            builds++;
            return country.name;
          },
        ),
      );
      final before = builds;
      await _typeSlowly(tester, '+201012345678');
      expect(builds, before);
      expect(notifications, 0);
      expect(phone.number().e164, '+201012345678');
    },
  );

  group('start', () {
    testWidgets('begins with initialCountry', (tester) async {
      await _pump(tester, MREPhoneFormField(initialCountry: _saudi));

      expect(find.text('+966'), findsOneWidget);
      expect(find.text(_saudi.flag), findsOneWidget);
    });

    testWidgets('falls back to the selection\'s initial country', (
      tester,
    ) async {
      await _pump(
        tester,
        MREPhoneFormField(selection: MRECountrySelection(initial: 'AE')),
      );

      expect(find.text('+971'), findsOneWidget);
    });

    testWidgets(
      'starts with the first accepted country when the device country is not accepted',
      (tester) async {
        await _pump(
          tester,
          MREPhoneFormField(
            selection: const MRECountrySelection(include: {'SA', 'EG'}),
          ),
        );

        expect(find.text('+20'), findsOneWidget);
      },
    );

    testWidgets('an initial country that is not accepted is ignored', (
      tester,
    ) async {
      await _pump(
        tester,
        MREPhoneFormField(
          initialCountry: MRECountries.byIsoCode('US'),
          selection: const MRECountrySelection(include: {'SA'}),
        ),
      );

      expect(find.text('+966'), findsOneWidget);
    });

    testWidgets('reads an international initial value', (tester) async {
      await _pump(tester, MREPhoneFormField(initialValue: '+201012345678'));

      expect(find.text('+20'), findsOneWidget);
      expect(_digits(tester), '1012345678');
    });

    testWidgets('reads a national initial value in the initial country', (
      tester,
    ) async {
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, initialValue: '01012345678'),
      );

      expect(find.text('+20'), findsOneWidget);
      expect(_digits(tester), '1012345678');
    });

    testWidgets('shows the label and the hint', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(
          initialCountry: _egypt,
          labelText: 'Phone',
          hintText: '10 1234 5678',
        ),
      );

      expect(find.text('Phone'), findsOneWidget);
    });
  });

  group('typing', () {
    testWidgets('reports the number on every change', (tester) async {
      final changes = <MREPhoneNumber>[];
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, onChanged: changes.add),
      );

      await _typeSlowly(tester, '1012345678');

      expect(changes, hasLength(10));
      expect(changes.last.isValid, isTrue);
      expect(changes.last.e164, '+201012345678');
      expect(changes.first.error, MREPhoneError.tooShort);
    });

    testWidgets('keeps only digits', (tester) async {
      await _pump(tester, MREPhoneFormField(initialCountry: _egypt));

      await _type(tester, 'ab1-0 1(2)');

      expect(_digits(tester), '1012');
    });

    testWidgets('turns Arabic digits into ASCII digits', (tester) async {
      await _pump(tester, MREPhoneFormField(initialCountry: _egypt));

      await _type(tester, '١٠١٢٣٤٥٦٧٨');

      expect(_digits(tester), '1012345678');
    });

    testWidgets('a national number with the trunk zero is valid', (
      tester,
    ) async {
      MREPhoneNumber? last;
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, onChanged: (n) => last = n),
      );

      await _type(tester, '01012345678');

      expect(last!.isValid, isTrue);
      expect(last!.e164, '+201012345678');
    });
  });

  group('paste', () {
    testWidgets(
      'a pasted international number sets the country and the digits',
      (tester) async {
        final countries = <MRECountry>[];
        MREPhoneNumber? last;
        await _pump(
          tester,
          MREPhoneFormField(
            initialCountry: _saudi,
            onCountryChanged: countries.add,
            onChanged: (n) => last = n,
          ),
        );

        await _type(tester, '+20 101 234 5678');

        expect(find.text('+20'), findsOneWidget);
        expect(_digits(tester), '1012345678');
        expect(countries, [_egypt]);
        expect(last!.e164, '+201012345678');
      },
    );

    testWidgets('reads 00 as the plus', (tester) async {
      await _pump(tester, MREPhoneFormField(initialCountry: _saudi));

      await _type(tester, '0020 1012345678');

      expect(find.text('+20'), findsOneWidget);
      expect(_digits(tester), '1012345678');
    });

    testWidgets(
      'a pasted number of a shared dial code finds the right country',
      (tester) async {
        await _pump(tester, MREPhoneFormField(initialCountry: _egypt));

        await _type(tester, '+1 204 555 1234');

        expect(find.text('+1'), findsOneWidget);
        expect(find.text(_canada.flag), findsOneWidget);
        expect(_digits(tester), '2045551234');
      },
    );

    testWidgets('a pasted incomplete number still moves the country', (
      tester,
    ) async {
      await _pump(tester, MREPhoneFormField(initialCountry: _saudi));

      await _type(tester, '+20 1012');

      expect(find.text('+20'), findsOneWidget);
      expect(_digits(tester), '1012');
    });

    testWidgets(
      'a typed dial code updates the country before the number is complete',
      (tester) async {
        await _pump(tester, MREPhoneFormField(initialCountry: _saudi));

        await _typeSlowly(tester, '+2010123');
        expect(
          find.text('+20'),
          findsOneWidget,
          reason: 'dial code already recognized',
        );
        expect(_digits(tester), '+2010123');

        await _typeSlowly(tester, '+201012345678');

        expect(find.text('+20'), findsOneWidget);
        expect(_digits(tester), '1012345678');
      },
    );

    testWidgets(
      'bare dial codes update immediately without repeated callbacks',
      (tester) async {
        final countries = <MRECountry>[];
        await _pump(
          tester,
          MREPhoneFormField(
            initialCountry: _saudi,
            onCountryChanged: countries.add,
          ),
        );
        await _typeSlowly(tester, '+20');
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == '+20',
          ),
          findsOneWidget,
        );
        expect(countries, [_egypt]);
        await _type(tester, '+201');
        await _type(tester, '+2010');
        expect(countries, [_egypt]);
      },
    );

    testWidgets(
      'invalid typed +1 number updates the country like the reported case',
      (tester) async {
        final controller = MREPhoneController(country: _egypt);
        addTearDown(controller.dispose);
        await _pump(tester, MREPhoneFormField(controller: controller));
        await _typeSlowly(tester, '+1');
        expect(controller.country?.isoCode, 'US');
        await _typeSlowly(tester, '+15655555555');
        expect(controller.country?.isoCode, 'US');
        expect(find.text('+1'), findsOneWidget);
        expect(controller.number().isValid, isFalse);
      },
    );

    testWidgets(
      'shared +1 follows the full Canadian number as typing continues',
      (tester) async {
        final controller = MREPhoneController(country: _egypt);
        addTearDown(controller.dispose);
        await _pump(tester, MREPhoneFormField(controller: controller));
        await _typeSlowly(tester, '+1');
        expect(controller.country?.isoCode, 'US');
        await _typeSlowly(tester, '+12045551234');
        expect(controller.country, _canada);
        expect(_digits(tester), '2045551234');
        expect(controller.number().e164, '+12045551234');
      },
    );

    testWidgets('typed 00 prefix detects a country only after its code', (
      tester,
    ) async {
      await _pump(tester, MREPhoneFormField(initialCountry: _egypt));
      await _typeSlowly(tester, '0097');
      expect(find.text('+20'), findsOneWidget);
      await _type(tester, '00971');
      expect(find.text('+971'), findsOneWidget);
    });

    testWidgets('typed excluded and unknown codes never change country', (
      tester,
    ) async {
      await _pump(
        tester,
        MREPhoneFormField(
          initialCountry: _saudi,
          selection: const MRECountrySelection(exclude: {'EG'}),
        ),
      );
      await _typeSlowly(tester, '+2010123');
      expect(find.text('+966'), findsOneWidget);
      await _typeSlowly(tester, '+99912');
      expect(find.text('+966'), findsOneWidget);
    });

    testWidgets(
      'a pasted number from an excluded country stays and is rejected',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        await _pump(
          tester,
          Form(
            key: formKey,
            child: MREPhoneFormField(
              initialCountry: _saudi,
              selection: const MRECountrySelection(exclude: {'EG'}),
            ),
          ),
        );

        await _type(tester, '+201012345678');
        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('+966'), findsOneWidget);
        expect(
          find.text('Numbers from this country are not accepted'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a pasted number with an unknown dial code stays and is rejected',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        await _pump(
          tester,
          Form(
            key: formKey,
            child: MREPhoneFormField(initialCountry: _saudi),
          ),
        );

        await _type(tester, '+999123456');
        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('+966'), findsOneWidget);
        expect(find.text('Unknown country code'), findsOneWidget);
      },
    );
  });

  group('country picker', () {
    testWidgets('opens from the dial button and changes the country', (
      tester,
    ) async {
      final countries = <MRECountry>[];
      final numbers = <MREPhoneNumber>[];
      await _pump(
        tester,
        MREPhoneFormField(
          initialCountry: _egypt,
          selection: const MRECountrySelection(include: {'EG', 'SA', 'AE'}),
          onCountryChanged: countries.add,
          onChanged: numbers.add,
        ),
      );

      await tester.tap(_dialButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Saudi Arabia'));
      await tester.pumpAndSettle();

      expect(find.text('+966'), findsOneWidget);
      expect(countries, [_saudi]);
      expect(numbers.last.country, _saudi);
    });

    testWidgets('lists only the accepted countries and pins the favorites', (
      tester,
    ) async {
      await _pump(
        tester,
        MREPhoneFormField(
          initialCountry: _egypt,
          selection: const MRECountrySelection(
            include: {'EG', 'SA', 'AE'},
            favorites: ['AE'],
          ),
        ),
      );

      await tester.tap(_dialButton);
      await tester.pumpAndSettle();

      final names = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((t) => (t.title! as Text).data);
      expect(names, ['United Arab Emirates', 'Egypt', 'Saudi Arabia']);
    });

    testWidgets('shows country names in your language', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(
          initialCountry: _egypt,
          selection: const MRECountrySelection(include: {'EG', 'SA'}),
          countryNameBuilder: (c) => c.isoCode == 'EG' ? 'مصر' : 'السعودية',
        ),
      );

      await tester.tap(_dialButton);
      await tester.pumpAndSettle();

      expect(find.text('مصر'), findsOneWidget);
      expect(find.text('السعودية'), findsOneWidget);
    });

    testWidgets('a country change checks the digits again', (tester) async {
      final formKey = GlobalKey<FormState>();
      await _pump(
        tester,
        Form(
          key: formKey,
          child: MREPhoneFormField(
            initialCountry: _egypt,
            selection: const MRECountrySelection(include: {'EG', 'SA'}),
          ),
        ),
      );
      await _type(tester, '1012345678');
      expect(find.text('This is not a valid phone number'), findsNothing);

      await tester.tap(_dialButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Saudi Arabia'));
      await tester.pumpAndSettle();

      expect(find.byType(MREPhoneFormField), findsOneWidget);
      expect(find.textContaining('phone number'), findsOneWidget);
    });

    testWidgets('does not open when disabled or read only', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, enabled: false),
      );
      await tester.tap(_dialButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(MRECountryPickerBody), findsNothing);

      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, readOnly: true),
      );
      await tester.tap(_dialButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(MRECountryPickerBody), findsNothing);
    });
  });

  group('validation', () {
    testWidgets('explains an incomplete number after the user types', (
      tester,
    ) async {
      await _pump(tester, MREPhoneFormField(initialCountry: _egypt));

      await _type(tester, '101');

      expect(find.text('The phone number is too short'), findsOneWidget);
    });

    testWidgets('accepts a valid number', (tester) async {
      await _pump(tester, MREPhoneFormField(initialCountry: _egypt));

      await _type(tester, '1012345678');

      expect(find.textContaining('phone number'), findsNothing);
    });

    testWidgets(
      'an empty required field is an error when the form is validated',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        await _pump(
          tester,
          Form(
            key: formKey,
            child: MREPhoneFormField(initialCountry: _egypt),
          ),
        );

        final valid = formKey.currentState!.validate();
        await tester.pump();

        expect(valid, isFalse);
        expect(find.text('Enter a phone number'), findsOneWidget);
      },
    );

    testWidgets('an empty field is fine when it is not required', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      await _pump(
        tester,
        Form(
          key: formKey,
          child: MREPhoneFormField(initialCountry: _egypt, required: false),
        ),
      );

      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('takes the messages from MREFieldsStrings', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt),
        theme: ThemeData(
          extensions: [
            MREFieldsTheme(
              strings: MREFieldsStrings(phoneTooShort: 'الرقم قصير جدا'),
            ),
          ],
        ),
      );

      await _type(tester, '101');

      expect(find.text('الرقم قصير جدا'), findsOneWidget);
    });

    testWidgets('a custom validator replaces the built-in one', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(
          initialCountry: _egypt,
          validator: (n) => n.isValid ? null : 'Bad: ${n.error!.name}',
        ),
      );

      await _type(tester, '101');

      expect(find.text('Bad: tooShort'), findsOneWidget);
    });

    testWidgets('errorText is shown', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, errorText: 'Already used'),
      );

      expect(find.text('Already used'), findsOneWidget);
    });

    testWidgets('validates through fieldKey without a form', (tester) async {
      final key = GlobalKey<FormFieldState<MREPhoneNumber>>();
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, fieldKey: key),
      );

      expect(key.currentState!.validate(), isFalse);

      await _type(tester, '1012345678');
      expect(key.currentState!.validate(), isTrue);
    });
  });

  group('controller', () {
    testWidgets('reads the number from your controller', (tester) async {
      final controller = MREPhoneController(country: _egypt);
      addTearDown(controller.dispose);
      await _pump(tester, MREPhoneFormField(controller: controller));

      await _type(tester, '1012345678');

      expect(controller.number().e164, '+201012345678');
      expect(controller.text.text, '1012345678');
    });

    testWidgets('setNumber changes the country and the digits', (tester) async {
      final controller = MREPhoneController(country: _egypt);
      addTearDown(controller.dispose);
      await _pump(tester, MREPhoneFormField(controller: controller));

      controller.setNumber('+966501234567');
      await tester.pump();

      expect(find.text('+966'), findsOneWidget);
      expect(_digits(tester), '501234567');
    });

    testWidgets('a controller\'s country change moves the button', (
      tester,
    ) async {
      final controller = MREPhoneController(country: _egypt);
      addTearDown(controller.dispose);
      await _pump(tester, MREPhoneFormField(controller: controller));

      controller.country = _saudi;
      await tester.pump();

      expect(find.text('+966'), findsOneWidget);
    });

    testWidgets('keeps the country and the digits of a controller you pass', (
      tester,
    ) async {
      final controller = MREPhoneController(
        country: _saudi,
        nationalNumber: '501234567',
      );
      addTearDown(controller.dispose);

      await _pump(
        tester,
        MREPhoneFormField(
          controller: controller,
          initialCountry: _egypt,
          initialValue: '+201000000000',
        ),
      );

      expect(find.text('+966'), findsOneWidget);
      expect(_digits(tester), '501234567');
    });

    testWidgets('clear empties the digits and keeps the country', (
      tester,
    ) async {
      final controller = MREPhoneController(
        country: _egypt,
        nationalNumber: '101',
      );
      addTearDown(controller.dispose);
      await _pump(tester, MREPhoneFormField(controller: controller));

      controller.clear();
      await tester.pump();

      expect(_digits(tester), '');
      expect(find.text('+20'), findsOneWidget);
    });

    testWidgets('does not dispose a controller you pass', (tester) async {
      final controller = MREPhoneController(country: _egypt);
      await _pump(tester, MREPhoneFormField(controller: controller));

      await tester.pumpWidget(SizedBox());

      expect(() => controller.country = _saudi, returnsNormally);
      controller.dispose();
    });

    testWidgets('switches to a new controller', (tester) async {
      final first = MREPhoneController(country: _egypt, nationalNumber: '101');
      final second = MREPhoneController(country: _saudi, nationalNumber: '50');
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await _pump(tester, MREPhoneFormField(controller: first));
      await _pump(tester, MREPhoneFormField(controller: second));
      await tester.pump();

      expect(find.text('+966'), findsOneWidget);
      expect(_digits(tester), '50');
    });

    test('the controller\'s number follows the typed digits', () {
      final controller = MREPhoneController(
        country: _egypt,
        nationalNumber: '01012345678',
      );
      addTearDown(controller.dispose);

      expect(controller.number().isValid, isTrue);

      controller.text.text = '+966501234567';
      expect(controller.number().country, _saudi);
    });
  });

  group('selection changes', () {
    testWidgets(
      'moves to an accepted country when the current one is excluded',
      (tester) async {
        await _pump(tester, MREPhoneFormField(initialCountry: _egypt));
        expect(find.text('+20'), findsOneWidget);

        await _pump(
          tester,
          MREPhoneFormField(
            initialCountry: _egypt,
            selection: const MRECountrySelection(exclude: {'EG'}),
          ),
        );
        await tester.pump();

        expect(find.text('+20'), findsNothing);
      },
    );
  });

  group('look', () {
    testWidgets(
      'the digits read left to right, aligned left in a left to right app',
      (tester) async {
        await _pump(tester, MREPhoneFormField(initialCountry: _egypt));

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.textDirection, TextDirection.ltr);
        expect(field.textAlign, TextAlign.left);
        expect(field.keyboardType, TextInputType.phone);
      },
    );

    testWidgets(
      'the digits stay left to right but align right in a right to left app',
      (tester) async {
        await _pump(
          tester,
          MREPhoneFormField(initialCountry: _egypt),
          direction: TextDirection.rtl,
        );

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.textDirection, TextDirection.ltr);
        expect(field.textAlign, TextAlign.right);
      },
    );

    testWidgets('the dial button can hide the flag', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, showFlags: false),
      );

      expect(find.text(_egypt.flag), findsNothing);
      expect(find.text('+20'), findsOneWidget);
    });

    testWidgets('the dial button is named for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, MREPhoneFormField(initialCountry: _egypt));

      expect(find.bySemanticsLabel('Egypt +20'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('shows a clear button while there are digits', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, showClearButton: true),
      );
      expect(find.byType(MREFieldClearButton), findsNothing);

      await _type(tester, '101');
      expect(find.byType(MREFieldClearButton), findsOneWidget);

      await tester.tap(find.byType(MREFieldClearButton));
      await tester.pump();
      expect(_digits(tester), '');
    });

    for (final width in [320.0, 420.0, 1024.0]) {
      for (final direction in TextDirection.values) {
        testWidgets(
          'has no overflow at $width wide, text scale 1.3, ${direction.name}',
          (tester) async {
            await _pump(
              tester,
              MREPhoneFormField(
                initialCountry: _saudi,
                labelText: 'A rather long label for the phone field',
                helperText: 'We will send you a code',
                showClearButton: true,
                initialValue: '501234567',
              ),
              size: Size(width, 700),
              textScale: 1.3,
              direction: direction,
            );

            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('renders in a dark theme', (tester) async {
      await _pump(
        tester,
        MREPhoneFormField(initialCountry: _egypt, labelText: 'Phone'),
        theme: ThemeData(brightness: Brightness.dark),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('form', () {
    testWidgets('submits the number', (tester) async {
      MREPhoneNumber? submitted;
      await _pump(
        tester,
        MREPhoneFormField(
          initialCountry: _egypt,
          onFieldSubmitted: (n) => submitted = n,
        ),
      );

      await _type(tester, '1012345678');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submitted!.e164, '+201012345678');
    });
  });
}
