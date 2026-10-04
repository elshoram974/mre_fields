import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

import '../../../support/images.dart';

void main() {
  testWidgets('optional counter follows additions, replacement and removal', (
    tester,
  ) async {
    final images = MREAttachmentsController();
    addTearDown(images.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MRETextField(
            imagePaste: MREImageAttachmentPaste(
              controller: images,
              showCounter: true,
              maxImages: 2,
            ),
          ),
        ),
      ),
    );
    expect(find.text('0 / 2'), findsOneWidget);
    images.add(png());
    images.add(png());
    await tester.pump();
    expect(find.text('2 / 2'), findsOneWidget);
    images.replaceAt(0, png());
    await tester.pump();
    expect(find.text('2 / 2'), findsOneWidget);
    images.removeAt(0);
    await tester.pump();
    expect(find.text('1 / 2'), findsOneWidget);
    images.clear();
    await tester.pump();
    expect(find.text('0 / 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom builder receives the limit even with no images', (
    tester,
  ) async {
    final images = MREAttachmentsController();
    addTearDown(images.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MRETextFormField(
            imagePaste: MREImageAttachmentPaste(
              controller: images,
              maxImages: 1,
              builder: (context, value) => Text(
                '${value.controller.count}/${value.maxImages}:${value.isAtLimit}',
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('0/1:false'), findsOneWidget);
    images.add(png());
    await tester.pump();
    expect(find.text('1/1:true'), findsOneWidget);
  });

  for (final size in const [
    Size(390, 844),
    Size(834, 1112),
    Size(1024, 768),
    Size(400, 300),
  ]) {
    testWidgets('composer contains images and input at $size, dark RTL 1.3', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final images = MREAttachmentsController(images: [png(), png(), png()]);
      addTearDown(images.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: MRETextFormField(
                labelText: 'Message',
                maxLines: 3,
                imagePaste: MREImageAttachmentPaste(
                  controller: images,
                  showCounter: true,
                ),
              ),
            ),
          ),
        ),
      );
      final decoration = find.ancestor(
        of: find.byType(MREAttachmentStrip),
        matching: find.byType(InputDecorator),
      );
      expect(decoration, findsOneWidget);
      final border = tester.getRect(decoration);
      expect(
        border.contains(tester.getCenter(find.byType(Image).first)),
        isTrue,
      );
      expect(
        border.contains(tester.getCenter(find.byType(EditableText))),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
