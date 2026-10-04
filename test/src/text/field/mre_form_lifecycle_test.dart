import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

void main() {
  testWidgets('ordinary text and phone inputs do not register with a form', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: Column(
              children: [
                const MRETextField(),
                MREPhoneField(initialCountry: MRECountries.byIsoCode('EG')),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is FormField),
      findsNothing,
    );
    expect(form.currentState!.validate(), isTrue);
  });

  testWidgets('text form saves and resets an external controller', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    final controller = TextEditingController(text: 'Start');
    addTearDown(controller.dispose);
    String? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: MRETextFormField(
              controller: controller,
              validator: (text) => text!.isEmpty ? 'Required' : null,
              onSaved: (text) => saved = text,
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Changed');
    form.currentState!.save();
    expect(saved, 'Changed');
    form.currentState!.reset();
    await tester.pump();
    expect(controller.text, 'Start');
    controller.clear();
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('phone form saves typed value and resets country and digits', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    final egypt = MRECountries.byIsoCode('EG')!;
    final controller = MREPhoneController(
      country: egypt,
      nationalNumber: '1012345678',
    );
    addTearDown(controller.dispose);
    MREPhoneNumber? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: MREPhoneFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Phone',
                filled: true,
              ),
              onSaved: (number) => saved = number,
            ),
          ),
        ),
      ),
    );
    controller.setNumber('+966501234567');
    await tester.pump();
    form.currentState!.save();
    expect(saved!.e164, '+966501234567');
    expect(form.currentState!.validate(), isTrue);
    form.currentState!.reset();
    await tester.pump();
    expect(controller.country, egypt);
    expect(controller.text.text, '1012345678');
    form.currentState!.save();
    expect(saved!.e164, '+201012345678');
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.filled,
      isTrue,
    );
  });
}
