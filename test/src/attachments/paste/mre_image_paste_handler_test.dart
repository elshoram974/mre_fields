import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';
import 'package:mre_fields/src/attachments/paste/mre_image_paste_handler.dart';

import '../../../support/clipboard.dart';
import '../../../support/images.dart';

/// Records what a behaviour reports.
class _Log {
  final pasted = <MREPastedImage>[];
  final rejected = <(MREImageRejection, MREPastedImage?)>[];
  final changes = <List<MREPastedImage>>[];
}

MREImagePasteHandler _handler(
  _Log log, {
  MREAttachmentsController? controller,
  FakeClipboardImageReader? reader,
  int maxImages = 4,
  int maxBytes = mreDefaultMaxImageBytes,
  bool Function()? isActive,
}) {
  final MREImagePasteBehavior behavior = controller == null
      ? MREImageCallbackPaste(
          onImagePasted: log.pasted.add,
          onImageRejected: (reason, image) => log.rejected.add((reason, image)),
          maxBytes: maxBytes,
          reader: reader ?? FakeClipboardImageReader(),
        )
      : MREImageAttachmentPaste(
          controller: controller,
          maxImages: maxImages,
          maxBytes: maxBytes,
          onImagePasted: log.pasted.add,
          onImageRejected: (reason, image) => log.rejected.add((reason, image)),
          onImagesChanged: log.changes.add,
          reader: reader ?? FakeClipboardImageReader(),
        );
  return MREImagePasteHandler(
    behavior: behavior,
    controller: controller,
    isActive: isActive ?? () => true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MREAttachmentsController controller;

  setUp(() => controller = MREAttachmentsController());
  tearDown(() => controller.dispose());

  group('accept', () {
    test('keeps the image and tells the callbacks', () {
      final log = _Log();

      _handler(log, controller: controller).accept(png());

      expect(controller.images, [png()]);
      expect(log.pasted, [png()]);
      expect(log.changes, [
        [png()],
      ]);
      expect(log.rejected, isEmpty);
    });

    test('gives the change callback a snapshot, not the live list', () {
      final log = _Log();
      final handler = _handler(log, controller: controller);

      handler.accept(png());
      handler.accept(png(otherPngBytes()));

      expect(log.changes.first, hasLength(1));
      expect(log.changes.last, hasLength(2));
    });

    test('a behaviour without attachments only calls onImagePasted', () {
      final log = _Log();

      _handler(log).accept(png());

      expect(log.pasted, [png()]);
      expect(log.changes, isEmpty);
    });

    test('rejects an image over the limits and keeps nothing', () {
      final log = _Log();
      final handler = _handler(log, controller: controller, maxBytes: 10);

      handler.accept(png());

      expect(log.rejected, [(MREImageRejection.tooLarge, png())]);
      expect(controller.isEmpty, isTrue);
      expect(log.pasted, isEmpty);
    });

    test('rejects an image beyond maxImages', () {
      final log = _Log();
      final handler = _handler(log, controller: controller, maxImages: 1);

      handler.accept(png());
      handler.accept(png(otherPngBytes()));

      expect(log.rejected.single.$1, MREImageRejection.tooMany);
      expect(controller.count, 1);
    });

    test('replacing swaps the image and ignores the limit for it', () {
      final log = _Log();
      final handler = _handler(log, controller: controller, maxImages: 1);
      handler.accept(png());

      final other = png(otherPngBytes());
      handler.accept(other, replacing: 0);

      expect(controller.images, [other]);
      expect(log.rejected, isEmpty);
    });
  });

  test('remove deletes the image and reports the new list', () {
    final log = _Log();
    final handler = _handler(log, controller: controller);
    handler.accept(png());

    handler.remove(0);

    expect(controller.isEmpty, isTrue);
    expect(log.changes.last, isEmpty);
  });

  group('readClipboardImage', () {
    test('returns what the reader gives', () async {
      final reader = FakeClipboardImageReader(png());

      expect(
        await _handler(_Log(), reader: reader).readClipboardImage(),
        png(),
      );
    });

    test('reports a PlatformException as unreadable', () async {
      final log = _Log();
      final reader = FakeClipboardImageReader()
        ..error = PlatformException(code: 'x');

      expect(await _handler(log, reader: reader).readClipboardImage(), isNull);
      expect(log.rejected, [(MREImageRejection.unreadable, null)]);
    });

    test('reports a MissingPluginException as unreadable', () async {
      final log = _Log();
      final reader = FakeClipboardImageReader()
        ..error = MissingPluginException();

      expect(await _handler(log, reader: reader).readClipboardImage(), isNull);
      expect(log.rejected, [(MREImageRejection.unreadable, null)]);
    });

    test('lets other errors through', () async {
      final reader = FakeClipboardImageReader()..error = StateError('bug');

      expect(
        _handler(_Log(), reader: reader).readClipboardImage(),
        throwsStateError,
      );
    });
  });

  group('pasteShortcut', () {
    test('text wins and the image is never read', () async {
      mockClipboardText(null, 'hello');
      final reader = FakeClipboardImageReader(png());
      final log = _Log();
      var textPastes = 0;

      await _handler(log, reader: reader).pasteShortcut(() => textPastes++);

      expect(textPastes, 1);
      expect(reader.reads, 0);
      expect(log.pasted, isEmpty);
    });

    test('an image is accepted when there is no text', () async {
      mockClipboardText(null, null);
      final log = _Log();
      var textPastes = 0;

      await _handler(
        log,
        reader: FakeClipboardImageReader(png()),
      ).pasteShortcut(() => textPastes++);

      expect(log.pasted, [png()]);
      expect(textPastes, 0);
    });

    test('an empty text counts as no text', () async {
      mockClipboardText(null, '');
      final log = _Log();

      await _handler(
        log,
        reader: FakeClipboardImageReader(png()),
      ).pasteShortcut(() {});

      expect(log.pasted, [png()]);
    });

    test('falls back to text paste when there is no image either', () async {
      mockClipboardText(null, null);
      var textPastes = 0;

      await _handler(
        _Log(),
        reader: FakeClipboardImageReader(),
      ).pasteShortcut(() => textPastes++);

      expect(textPastes, 1);
    });

    test('does nothing once the owner is gone', () async {
      mockClipboardText(null, null);
      final log = _Log();
      var textPastes = 0;

      await _handler(
        log,
        reader: FakeClipboardImageReader(png()),
        isActive: () => false,
      ).pasteShortcut(() => textPastes++);

      expect(log.pasted, isEmpty);
      expect(textPastes, 0);
    });
  });

  group('replace', () {
    test('swaps in the clipboard image', () async {
      final log = _Log();
      final reader = FakeClipboardImageReader(png());
      final handler = _handler(log, controller: controller, reader: reader);
      handler.accept(png());

      final other = png(otherPngBytes());
      reader.image = other;
      await handler.replace(0);

      expect(controller.images, [other]);
    });

    test('reports an empty clipboard and keeps the image', () async {
      final log = _Log();
      final reader = FakeClipboardImageReader(png());
      final handler = _handler(log, controller: controller, reader: reader);
      handler.accept(png());

      reader.image = null;
      await handler.replace(0);

      expect(log.rejected, [(MREImageRejection.unreadable, null)]);
      expect(controller.images, [png()]);
    });
  });

  group('keyboardContent', () {
    test('accepts bytes and trusts them over the declared type', () {
      final log = _Log();

      _handler(log).keyboardContent(
        KeyboardInsertedContent(
          mimeType: 'image/gif',
          uri: 'content://x',
          data: pngBytes,
        ),
      );

      expect(log.pasted.single.mimeType, 'image/png');
    });

    test('reports content without bytes as unreadable', () {
      final log = _Log();

      _handler(log).keyboardContent(
        const KeyboardInsertedContent(
          mimeType: 'image/png',
          uri: 'content://x',
        ),
      );
      _handler(log).keyboardContent(
        KeyboardInsertedContent(
          mimeType: 'image/png',
          uri: 'content://x',
          data: Uint8List(0),
        ),
      );

      expect(log.rejected.map((r) => r.$1), [
        MREImageRejection.unreadable,
        MREImageRejection.unreadable,
      ]);
    });
  });
}
