import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

import '../../doc/snippets/attachments.dart';
import '../support/images.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('behaviors: three fields, one for each behaviour', (
    tester,
  ) async {
    await tester.pumpWidget(_host(behaviorsExample()));

    expect(find.byType(MRETextField), findsNWidgets(3));
    final behaviors = tester
        .widgetList<MRETextField>(find.byType(MRETextField))
        .map((f) => f.imagePaste.runtimeType)
        .toList();
    expect(behaviors, [
      MRENoImagePaste,
      MREImageCallbackPaste,
      MREImageAttachmentPaste,
    ]);
    expect(find.byType(Image), findsNothing, reason: 'no image yet');
    expect(tester.getSize(find.byType(MREAttachmentStrip)).height, 0);
  });

  testWidgets('attachments: limits are the ones in the example', (
    tester,
  ) async {
    await tester.pumpWidget(_host(attachmentsField()));

    final behavior = tester
        .widget<MRETextField>(find.byType(MRETextField))
        .imagePaste;
    expect(behavior, isA<MREImageAttachmentPaste>());
    expect(behavior.maxImages, 4);
    expect(behavior.maxBytes, 5 * 1024 * 1024);
  });

  testWidgets('controller: images in your controller show under the field', (
    tester,
  ) async {
    final controller = MREAttachmentsController(images: [png()]);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(withAttachmentsController(controller)));

    expect(find.byType(Image), findsOneWidget);

    controller.removeAt(0);
    await tester.pump();
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('viewer: the button opens the viewer', (tester) async {
    await tester.pumpWidget(_host(viewerButton([png()])));

    await tester.tap(find.text('View images'));
    await tester.pumpAndSettle();

    expect(find.byType(MREImageViewer), findsOneWidget);
  });

  testWidgets('strip: shows the images with a replace button', (tester) async {
    final controller = MREAttachmentsController(images: [png()]);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(stripAlone(controller)));

    expect(find.byTooltip('Replace image'), findsOneWidget);
    expect(find.byTooltip('Remove image'), findsOneWidget);
  });

  testWidgets('scope: gives a plain TextField the paste hooks', (tester) async {
    await tester.pumpWidget(_host(scopeOnPlainField()));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.contentInsertionConfiguration, isNotNull);
    expect(field.contextMenuBuilder, isNotNull);
  });
}
