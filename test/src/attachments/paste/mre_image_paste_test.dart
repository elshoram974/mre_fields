import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

import '../../../support/clipboard.dart';
import '../../../support/images.dart';

void _setClipboardText(WidgetTester tester, String? text) =>
    mockClipboardText(tester, text);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  double width = 600,
  double textScale = 1,
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
        child: app!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
}

/// Sends the paste intent the shortcut sends, from the focused node like a key
/// press does, then lets the async clipboard reads finish.
Future<void> _paste(WidgetTester tester) async {
  Actions.invoke(
    FocusManager.instance.primaryFocus!.context!,
    const PasteTextIntent(SelectionChangedCause.keyboard),
  );
  await tester.pump();
  await tester.pump();
}

MRETextField _field(
  MREImagePasteBehavior behavior, {
  TextEditingController? controller,
}) {
  return MRETextField(controller: controller, imagePaste: behavior);
}

void main() {
  group('default behaviour', () {
    testWidgets('adds nothing around the field', (tester) async {
      await _pump(tester, const MRETextField());

      expect(find.byType(MREAttachmentStrip), findsNothing);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.contentInsertionConfiguration, isNull);
      expect(field.contextMenuBuilder, isNotNull);
    });
  });

  group('paste shortcut', () {
    testWidgets(
      'text on the clipboard pastes as text and never reads the image',
      (tester) async {
        _setClipboardText(tester, 'hello');
        final reader = FakeClipboardImageReader(png());
        final pasted = <MREPastedImage>[];
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        await _pump(
          tester,
          _field(
            MREImageCallbackPaste(onImagePasted: pasted.add, reader: reader),
            controller: controller,
          ),
        );
        await tester.showKeyboard(find.byType(EditableText));

        await _paste(tester);

        expect(controller.text, 'hello');
        expect(pasted, isEmpty);
        expect(reader.reads, 0);
      },
    );

    testWidgets(
      'an image on the clipboard goes to the callback and the text stays',
      (tester) async {
        _setClipboardText(tester, null);
        final pasted = <MREPastedImage>[];
        final controller = TextEditingController(text: 'draft');
        addTearDown(controller.dispose);
        await _pump(
          tester,
          _field(
            MREImageCallbackPaste(
              onImagePasted: pasted.add,
              reader: FakeClipboardImageReader(png()),
            ),
            controller: controller,
          ),
        );
        await tester.showKeyboard(find.byType(EditableText));

        await _paste(tester);

        expect(pasted, [png()]);
        expect(controller.text, 'draft');
        expect(find.byType(MREAttachmentStrip), findsNothing);
      },
    );

    testWidgets('nothing on the clipboard changes nothing', (tester) async {
      _setClipboardText(tester, null);
      final pasted = <MREPastedImage>[];
      final rejected = <MREImageRejection>[];
      await _pump(
        tester,
        _field(
          MREImageCallbackPaste(
            onImagePasted: pasted.add,
            onImageRejected: (reason, _) => rejected.add(reason),
            reader: FakeClipboardImageReader(),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      await _paste(tester);

      expect(pasted, isEmpty);
      expect(rejected, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a clipboard that cannot be read is reported', (tester) async {
      _setClipboardText(tester, null);
      final rejected = <(MREImageRejection, MREPastedImage?)>[];
      final reader = FakeClipboardImageReader()
        ..error = PlatformException(code: 'denied');
      await _pump(
        tester,
        _field(
          MREImageCallbackPaste(
            onImagePasted: (_) {},
            onImageRejected: (reason, image) => rejected.add((reason, image)),
            reader: reader,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      await _paste(tester);

      expect(rejected, [(MREImageRejection.unreadable, null)]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a missing plugin is reported the same way', (tester) async {
      _setClipboardText(tester, null);
      final rejected = <MREImageRejection>[];
      final reader = FakeClipboardImageReader()
        ..error = MissingPluginException();
      await _pump(
        tester,
        _field(
          MREImageCallbackPaste(
            onImagePasted: (_) {},
            onImageRejected: (reason, _) => rejected.add(reason),
            reader: reader,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      await _paste(tester);

      expect(rejected, [MREImageRejection.unreadable]);
    });

    testWidgets('limits apply before the callback', (tester) async {
      _setClipboardText(tester, null);
      final pasted = <MREPastedImage>[];
      final rejected = <(MREImageRejection, MREPastedImage?)>[];
      final reader = FakeClipboardImageReader(png());
      await _pump(
        tester,
        _field(
          MREImageCallbackPaste(
            onImagePasted: pasted.add,
            onImageRejected: (reason, image) => rejected.add((reason, image)),
            maxBytes: 10,
            reader: reader,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      await _paste(tester);
      expect(rejected, [(MREImageRejection.tooLarge, png())]);

      reader.image = MREPastedImage(
        bytes: Uint8List(4),
        mimeType: 'application/octet-stream',
      );
      await _paste(tester);

      expect(rejected.last.$1, MREImageRejection.wrongType);
      expect(pasted, isEmpty);
    });
  });

  group('attachments', () {
    testWidgets('shows pasted images under the field and reports each change', (
      tester,
    ) async {
      _setClipboardText(tester, null);
      final reader = FakeClipboardImageReader(png());
      final changes = <int>[];
      final pasted = <MREPastedImage>[];
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(
            reader: reader,
            onImagePasted: pasted.add,
            onImagesChanged: (images) => changes.add(images.length),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      expect(find.byType(Image), findsNothing);

      await _paste(tester);
      reader.image = png(otherPngBytes());
      await _paste(tester);

      expect(find.byType(Image), findsNWidgets(2));
      expect(changes, [1, 2]);
      expect(pasted, hasLength(2));
    });

    testWidgets('stops at maxImages and says why', (tester) async {
      _setClipboardText(tester, null);
      final rejected = <MREImageRejection>[];
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(
            maxImages: 1,
            reader: FakeClipboardImageReader(png()),
            onImageRejected: (reason, _) => rejected.add(reason),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      await _paste(tester);
      await _paste(tester);

      expect(find.byType(Image), findsOneWidget);
      expect(rejected, [MREImageRejection.tooMany]);
    });

    testWidgets('remove deletes the image and reports it', (tester) async {
      _setClipboardText(tester, null);
      final changes = <int>[];
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(
            reader: FakeClipboardImageReader(png()),
            onImagesChanged: (images) => changes.add(images.length),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      await _paste(tester);

      await tester.tap(find.byTooltip('Remove image'));
      await tester.pump();

      expect(find.byType(Image), findsNothing);
      expect(changes, [1, 0]);
    });

    testWidgets('replace swaps in the image on the clipboard', (tester) async {
      _setClipboardText(tester, null);
      final reader = FakeClipboardImageReader(png());
      final changes = <List<MREPastedImage>>[];
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(reader: reader, onImagesChanged: changes.add),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      await _paste(tester);

      final replacement = png(otherPngBytes());
      reader.image = replacement;
      await tester.tap(find.byTooltip('Replace image'));
      await tester.pump();
      await tester.pump();

      expect(changes.last, [replacement]);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets(
      'replace with nothing on the clipboard reports it and keeps the image',
      (tester) async {
        _setClipboardText(tester, null);
        final reader = FakeClipboardImageReader(png());
        final rejected = <MREImageRejection>[];
        await _pump(
          tester,
          _field(
            MREImageAttachmentPaste(
              reader: reader,
              onImageRejected: (reason, _) => rejected.add(reason),
            ),
          ),
        );
        await tester.showKeyboard(find.byType(EditableText));
        await _paste(tester);

        reader.image = null;
        await tester.tap(find.byTooltip('Replace image'));
        await tester.pump();
        await tester.pump();

        expect(rejected, [MREImageRejection.unreadable]);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets('a full field still lets an image be replaced', (tester) async {
      _setClipboardText(tester, null);
      final reader = FakeClipboardImageReader(png());
      final rejected = <MREImageRejection>[];
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(
            maxImages: 1,
            reader: reader,
            onImageRejected: (reason, _) => rejected.add(reason),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      await _paste(tester);

      reader.image = png(otherPngBytes());
      await tester.tap(find.byTooltip('Replace image'));
      await tester.pump();
      await tester.pump();

      expect(rejected, isEmpty);
    });

    testWidgets('allowReplace false hides the replace button', (tester) async {
      _setClipboardText(tester, null);
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(
            allowReplace: false,
            reader: FakeClipboardImageReader(png()),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      await _paste(tester);

      expect(find.byTooltip('Replace image'), findsNothing);
      expect(find.byTooltip('Remove image'), findsOneWidget);
    });

    testWidgets(
      'tapping a thumbnail opens the viewer and the close button closes it',
      (tester) async {
        _setClipboardText(tester, null);
        await _pump(
          tester,
          _field(
            MREImageAttachmentPaste(reader: FakeClipboardImageReader(png())),
          ),
        );
        await tester.showKeyboard(find.byType(EditableText));
        await _paste(tester);

        await tester.tap(find.byType(InkWell).first);
        await tester.pumpAndSettle();
        expect(find.byType(MREImageViewer), findsOneWidget);

        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
        expect(find.byType(MREImageViewer), findsNothing);
      },
    );

    testWidgets('uses the texts from MREFieldsStrings', (tester) async {
      _setClipboardText(tester, null);
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(reader: FakeClipboardImageReader(png())),
        ),
        theme: ThemeData(
          extensions: const [
            MREFieldsTheme(
              strings: MREFieldsStrings(
                removeImageTooltip: 'إزالة',
                replaceImageTooltip: 'استبدال',
              ),
            ),
          ],
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      await _paste(tester);

      expect(find.byTooltip('إزالة'), findsOneWidget);
      expect(find.byTooltip('استبدال'), findsOneWidget);
    });

    testWidgets('a controller you pass shows and receives the images', (
      tester,
    ) async {
      _setClipboardText(tester, null);
      final controller = MREAttachmentsController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(
            controller: controller,
            reader: FakeClipboardImageReader(png()),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      await _paste(tester);
      expect(controller.images, [png()]);

      controller.add(png(otherPngBytes()));
      await tester.pump();
      expect(find.byType(Image), findsNWidgets(2));

      controller.clear();
      await tester.pump();
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('your controller survives the field being removed', (
      tester,
    ) async {
      final controller = MREAttachmentsController(images: [png()]);
      await _pump(
        tester,
        _field(MREImageAttachmentPaste(controller: controller)),
      );

      await tester.pumpWidget(const SizedBox());

      expect(() => controller.add(png()), returnsNormally);
      controller.dispose();
    });

    testWidgets(
      'the images stay when the parent rebuilds with a new behaviour object',
      (tester) async {
        _setClipboardText(tester, null);
        final reader = FakeClipboardImageReader(png());
        await _pump(tester, _field(MREImageAttachmentPaste(reader: reader)));
        await tester.showKeyboard(find.byType(EditableText));
        await _paste(tester);

        await _pump(
          tester,
          _field(MREImageAttachmentPaste(reader: reader, maxImages: 9)),
        );

        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets('switching to no image paste removes the strip', (
      tester,
    ) async {
      _setClipboardText(tester, null);
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(reader: FakeClipboardImageReader(png())),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      await _paste(tester);

      await _pump(tester, const MRETextField());

      expect(find.byType(MREAttachmentStrip), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('on-screen keyboard', () {
    ContentInsertionConfiguration configOf(WidgetTester tester) {
      return tester
          .widget<TextField>(find.byType(TextField))
          .contentInsertionConfiguration!;
    }

    testWidgets('offers the allowed types to the keyboard', (tester) async {
      await _pump(
        tester,
        _field(
          const MREImageAttachmentPaste(
            allowedMimeTypes: ['image/png', 'image/gif'],
          ),
        ),
      );

      expect(configOf(tester).allowedMimeTypes, ['image/png', 'image/gif']);
    });

    testWidgets('inserted content is accepted like a paste', (tester) async {
      final pasted = <MREPastedImage>[];
      await _pump(
        tester,
        _field(MREImageCallbackPaste(onImagePasted: pasted.add)),
      );

      configOf(tester).onContentInserted(
        KeyboardInsertedContent(
          mimeType: 'image/png',
          uri: 'content://x',
          data: pngBytes,
        ),
      );

      expect(pasted, [png()]);
    });

    testWidgets('content without data is reported as unreadable', (
      tester,
    ) async {
      final rejected = <MREImageRejection>[];
      await _pump(
        tester,
        _field(
          MREImageCallbackPaste(
            onImagePasted: (_) {},
            onImageRejected: (reason, _) => rejected.add(reason),
          ),
        ),
      );

      configOf(tester).onContentInserted(
        const KeyboardInsertedContent(
          mimeType: 'image/gif',
          uri: 'content://x',
        ),
      );

      expect(rejected, [MREImageRejection.unreadable]);
    });
  });

  group('selection menu', () {
    testWidgets('offers "Paste image" when the clipboard holds an image', (
      tester,
    ) async {
      _setClipboardText(tester, null);
      final pasted = <MREPastedImage>[];
      await _pump(
        tester,
        _field(
          MREImageCallbackPaste(
            onImagePasted: pasted.add,
            reader: FakeClipboardImageReader(png()),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      tester.state<EditableTextState>(find.byType(EditableText)).showToolbar();
      await tester.pumpAndSettle();
      expect(find.text('Paste image'), findsOneWidget);

      await tester.tap(find.text('Paste image'));
      await tester.pumpAndSettle();

      expect(pasted, [png()]);
    });

    testWidgets('does not offer it when the clipboard has no image', (
      tester,
    ) async {
      _setClipboardText(tester, null);
      await _pump(
        tester,
        _field(
          MREImageCallbackPaste(
            onImagePasted: (_) {},
            reader: FakeClipboardImageReader(),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      tester.state<EditableTextState>(find.byType(EditableText)).showToolbar();
      await tester.pumpAndSettle();

      expect(find.text('Paste image'), findsNothing);
    });
  });

  group('layout', () {
    testWidgets('thumbnails are larger on expanded widths', (tester) async {
      Future<double> stripHeight(double width) async {
        _setClipboardText(tester, null);
        await _pump(
          tester,
          _field(
            MREImageAttachmentPaste(reader: FakeClipboardImageReader(png())),
          ),
          width: width,
        );
        await tester.showKeyboard(find.byType(EditableText));
        await _paste(tester);
        return tester.getSize(find.byType(MREAttachmentStrip)).height;
      }

      expect(await stripHeight(400), 96);
      expect(await stripHeight(1000), 120);
    });

    testWidgets('buttons keep a 40 px touch target', (tester) async {
      _setClipboardText(tester, null);
      await _pump(
        tester,
        _field(
          MREImageAttachmentPaste(reader: FakeClipboardImageReader(png())),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      await _paste(tester);

      for (final tooltip in ['Remove image', 'Replace image']) {
        final size = tester.getSize(
          find
              .ancestor(
                of: find.byTooltip(tooltip),
                matching: find.byType(IconButton),
              )
              .first,
        );
        expect(size.width, greaterThanOrEqualTo(40), reason: tooltip);
        expect(size.height, greaterThanOrEqualTo(40), reason: tooltip);
      }
    });

    for (final width in [320.0, 390.0, 1024.0]) {
      for (final ambient in TextDirection.values) {
        testWidgets(
          'has no overflow with many images at $width wide, ${ambient.name}',
          (tester) async {
            _setClipboardText(tester, null);
            final controller = MREAttachmentsController(
              images: [
                for (var i = 0; i < 8; i++)
                  png(Uint8List.fromList([...pngBytes, i])),
              ],
            );
            addTearDown(controller.dispose);
            await _pump(
              tester,
              Directionality(
                textDirection: ambient,
                child: MRETextField(
                  labelText: 'A long label for the field',
                  showClearButton: true,
                  imagePaste: MREImageAttachmentPaste(controller: controller),
                ),
              ),
              width: width,
              textScale: 1.3,
            );

            expect(tester.takeException(), isNull);
            expect(find.byType(MREAttachmentStrip), findsOneWidget);
          },
        );
      }
    }
  });

  group('MREImagePasteScope on a plain TextField', () {
    testWidgets('adds paste to any field', (tester) async {
      _setClipboardText(tester, null);
      final pasted = <MREPastedImage>[];
      await _pump(
        tester,
        MREImagePasteScope(
          behavior: MREImageCallbackPaste(
            onImagePasted: pasted.add,
            reader: FakeClipboardImageReader(png()),
          ),
          builder: (context, hooks) => TextField(
            contentInsertionConfiguration: hooks.contentInsertionConfiguration,
            contextMenuBuilder: hooks.contextMenuBuilder,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));

      await _paste(tester);

      expect(pasted, [png()]);
    });

    testWidgets('gives no hooks when the behaviour accepts nothing', (
      tester,
    ) async {
      MREImagePasteHooks? received;
      await _pump(
        tester,
        MREImagePasteScope(
          behavior: const MRENoImagePaste(),
          builder: (context, hooks) {
            received = hooks;
            return const TextField();
          },
        ),
      );

      expect(received, same(MREImagePasteHooks.none));
    });
  });
}
