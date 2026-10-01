import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

import '../../doc/snippets/phone.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

String _digits(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  testWidgets('basic: reports a valid number as E.164', (tester) async {
    await tester.pumpWidget(_host(basicPhone()));

    expect(find.byType(MREPhoneField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '+201012345678');
    await tester.pump();

    expect(find.text('+20'), findsOneWidget);
    expect(_digits(tester), '1012345678');
  });

  testWidgets('selection: the Gulf field starts with Saudi Arabia', (
    tester,
  ) async {
    await tester.pumpWidget(_host(gulfOnly()));

    expect(find.text('+966'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();

    final names = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((t) => (t.title! as Text).data)
        .toList();
    expect(names.take(2), ['Saudi Arabia', 'United Arab Emirates']);
    expect(names, isNot(contains('Egypt')));
  });

  testWidgets('exclude: Israel is not offered', (tester) async {
    await tester.pumpWidget(_host(everyoneButOne()));

    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'israel');
    await tester.pump();

    expect(find.text('No countries found'), findsOneWidget);
  });

  test('parse: matches the comments in the example', () {
    expect(parseExamples(), [
      'Egypt',
      '+201012345678',
      '+20 10 12345678',
      true,
    ]);
  });

  test('error: names the problem', () {
    expect(whatIsWrong('0101234'), MREPhoneError.tooShort);
    expect(whatIsWrong('01012345678'), isNull);
    expect(whatIsWrong(''), MREPhoneError.empty);
  });

  test('national: reads a national number', () {
    expect(nationalNumber(), '+201012345678');
  });

  test('countries: matches the comments in the example', () {
    final values = countryLookups();

    expect(values[0], '+20');
    expect(values[1], '🇪🇬');
    expect(
      (values[2] as List<MRECountry>).map((c) => c.isoCode),
      containsAll(['US', 'CA']),
    );
  });

  testWidgets('validator: works in a plain form field', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _host(Form(key: formKey, child: phoneInPlainField())),
    );

    await tester.enterText(find.byType(TextField), '0101234');
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('The phone number is too short'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '01012345678');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('picker: returns the chosen country', (tester) async {
    late Future<MRECountry?> result;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => result = choose(context),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Egypt'));
    await tester.pumpAndSettle();

    expect((await result)!.isoCode, 'EG');
  });

  testWidgets('controller: setNumber moves the country', (tester) async {
    final controller = MREPhoneController(
      country: MRECountries.byIsoCode('EG'),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(withPhoneController(controller)));
    await tester.pump();

    expect(find.text('+966'), findsOneWidget);
    expect(_digits(tester), '501234567');
    expect(controller.number().e164, '+966501234567');
  });

  testWidgets('translate: Arabic names in the picker', (tester) async {
    await tester.pumpWidget(_host(arabicPhone()));

    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();

    expect(find.text('اختر الدولة'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'مصر');
    await tester.pump();

    expect(find.widgetWithText(ListTile, 'مصر'), findsOneWidget);
  });

  testWidgets('form: an empty required number fails the form', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(_host(phoneForm(formKey)));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Enter a phone number'), findsOneWidget);
  });

  test('messages: English by default', () {
    expect(messageFor(MREPhoneError.tooShort), 'The phone number is too short');
  });
}
