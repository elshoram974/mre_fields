import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';
import 'package:mre_fields/src/attachments/paste/mre_image_paste_handler.dart';

import '../../../support/images.dart';
import '../../../support/clipboard.dart';

class _PendingReader implements MREClipboardImageReader {
  final result = Completer<MREPastedImage?>();
  @override
  Future<MREPastedImage?> read() => result.future;
}

void main() {
  test(
    'replacement follows the original image after an earlier removal',
    () async {
      final first = png();
      final target = png(otherPngBytes());
      final replacement = png();
      final controller = MREAttachmentsController(images: [first, target]);
      addTearDown(controller.dispose);
      final reader = _PendingReader();
      final handler = MREImagePasteHandler(
        behavior: MREImageAttachmentPaste(reader: reader),
        controller: controller,
        isActive: () => true,
      );
      final pending = handler.replace(1);
      controller.removeAt(0);
      reader.result.complete(replacement);
      await pending;
      expect(controller.images.single, same(replacement));
    },
  );

  test('removing the target while reading cancels replacement', () async {
    final controller = MREAttachmentsController(images: [png()]);
    addTearDown(controller.dispose);
    final reader = _PendingReader();
    final pasted = <MREPastedImage>[];
    final handler = MREImagePasteHandler(
      behavior: MREImageAttachmentPaste(
        reader: reader,
        onImagePasted: pasted.add,
      ),
      controller: controller,
      isActive: () => true,
    );
    final pending = handler.replace(0);
    controller.clear();
    reader.result.complete(png());
    await pending;
    expect(controller.isEmpty, isTrue);
    expect(pasted, isEmpty);
  });

  for (final change in ['lock', 'controller', 'dispose']) {
    testWidgets('pending paste is cancelled on $change', (tester) async {
      mockClipboardText(tester, null);
      final reader = _PendingReader();
      final first = MREAttachmentsController();
      final second = MREAttachmentsController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      final accepted = <MREPastedImage>[];
      Widget host({
        bool locked = false,
        MREAttachmentsController? controller,
      }) => MaterialApp(
        home: Scaffold(
          body: MRETextField(
            readOnly: locked,
            imagePaste: MREImageAttachmentPaste(
              controller: controller ?? first,
              reader: reader,
              onImagePasted: accepted.add,
            ),
          ),
        ),
      );
      await tester.pumpWidget(host());
      await tester.tap(find.byType(TextField));
      await tester.pump();
      Actions.invoke(
        FocusManager.instance.primaryFocus!.context!,
        const PasteTextIntent(SelectionChangedCause.keyboard),
      );
      await tester.pump();
      await tester.pumpWidget(
        change == 'dispose'
            ? const SizedBox.shrink()
            : host(
                locked: change == 'lock',
                controller: change == 'controller' ? second : first,
              ),
      );
      reader.result.complete(png());
      await tester.pump();
      expect(first.isEmpty, isTrue);
      expect(second.isEmpty, isTrue);
      expect(accepted, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  for (final readOnly in [true, false]) {
    testWidgets(
      'locked field protects suggestions and images: readOnly=$readOnly',
      (tester) async {
        final images = MREAttachmentsController(images: [png()]);
        final text = TextEditingController();
        addTearDown(images.dispose);
        addTearDown(text.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MRETextField(
                controller: text,
                readOnly: readOnly,
                enabled: readOnly,
                suggestions: const ['Hello'],
                imagePaste: MREImageAttachmentPaste(controller: images),
              ),
            ),
          ),
        );
        if (readOnly) await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(find.byType(ActionChip), findsNothing);
        expect(find.byIcon(Icons.close_rounded), findsNothing);
        expect(find.byIcon(Icons.swap_horiz_rounded), findsNothing);
        final editor = tester.widget<TextField>(find.byType(TextField));
        expect(editor.contentInsertionConfiguration, isNull);
        expect(images.count, 1);
        expect(text.text, isEmpty);
        await tester.tap(find.byType(Image));
        await tester.pumpAndSettle();
        expect(find.byType(MREImageViewer), findsOneWidget);
      },
    );
  }

  testWidgets('custom attachments render inside the same decorated surface', (
    tester,
  ) async {
    final images = MREAttachmentsController(images: [png()]);
    addTearDown(images.dispose);
    MREAttachmentsPresentation? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MRETextField(
            imagePaste: MREImageAttachmentPaste(
              controller: images,
              builder: (context, presentation) {
                received = presentation;
                return const Text('Custom image presentation');
              },
            ),
          ),
        ),
      ),
    );
    final decorated = find.ancestor(
      of: find.text('Custom image presentation'),
      matching: find.byType(InputDecorator),
    );
    expect(decorated, findsOneWidget);
    expect(
      find.descendant(of: decorated, matching: find.byType(EditableText)),
      findsOneWidget,
    );
    expect(find.byType(MREAttachmentStrip), findsNothing);
    received!.onRemove!(0);
    await tester.pump();
    expect(images.isEmpty, isTrue);
    expect(find.text('Custom image presentation'), findsOneWidget);
    expect(received!.controller.count, 0);
  });

  testWidgets('disabled custom presentation receives no edit actions', (
    tester,
  ) async {
    final images = MREAttachmentsController(images: [png()]);
    addTearDown(images.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MRETextField(
            enabled: false,
            imagePaste: MREImageAttachmentPaste(
              controller: images,
              builder: (context, presentation) {
                expect(presentation.onRemove, isNull);
                expect(presentation.onReplace, isNull);
                return const Text('Image');
              },
            ),
          ),
        ),
      ),
    );
  });
}
