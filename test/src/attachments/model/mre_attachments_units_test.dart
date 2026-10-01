import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

import '../../../support/images.dart';

Uint8List _bytes(List<int> start, [int length = 16]) {
  final bytes = Uint8List(length);
  bytes.setRange(0, start.length, start);
  return bytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('mreSniffImageMimeType', () {
    test('recognizes each supported type', () {
      expect(mreSniffImageMimeType(pngBytes), 'image/png');
      expect(
        mreSniffImageMimeType(_bytes([0xFF, 0xD8, 0xFF, 0xE0])),
        'image/jpeg',
      );
      expect(
        mreSniffImageMimeType(_bytes([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])),
        'image/gif',
      );
      expect(mreSniffImageMimeType(_bytes([0x42, 0x4D])), 'image/bmp');
      expect(
        mreSniffImageMimeType(_bytes([0x49, 0x49, 0x2A, 0x00])),
        'image/tiff',
      );
      expect(
        mreSniffImageMimeType(_bytes([0x4D, 0x4D, 0x00, 0x2A])),
        'image/tiff',
      );
    });

    test('recognizes WebP and HEIC by their inner markers', () {
      final webp = _bytes([
        0x52,
        0x49,
        0x46,
        0x46,
        0,
        0,
        0,
        0,
        0x57,
        0x45,
        0x42,
        0x50,
      ]);
      final heic = _bytes([
        0,
        0,
        0,
        0x18,
        0x66,
        0x74,
        0x79,
        0x70,
        0x68,
        0x65,
        0x69,
        0x63,
      ]);
      final wave = _bytes([
        0x52,
        0x49,
        0x46,
        0x46,
        0,
        0,
        0,
        0,
        0x57,
        0x41,
        0x56,
        0x45,
      ]);

      expect(mreSniffImageMimeType(webp), 'image/webp');
      expect(mreSniffImageMimeType(heic), 'image/heic');
      expect(
        mreSniffImageMimeType(wave),
        isNull,
        reason: 'RIFF alone is not WebP',
      );
    });

    test('returns null for other data and short data', () {
      expect(mreSniffImageMimeType(Uint8List(0)), isNull);
      expect(mreSniffImageMimeType(Uint8List.fromList([1, 2, 3])), isNull);
      expect(
        mreSniffImageMimeType(Uint8List.fromList('hello world'.codeUnits)),
        isNull,
      );
      expect(mreSniffImageMimeType(Uint8List.fromList([0x89, 0x50])), isNull);
    });
  });

  group('MREPastedImage', () {
    test('has the length of its bytes', () {
      expect(png().length, pngBytes.length);
    });

    test('is equal for the same bytes and metadata', () {
      expect(png(), png());
      expect(png().hashCode, png().hashCode);
      expect(png(), isNot(png(otherPngBytes())));
      expect(
        png(),
        isNot(MREPastedImage(bytes: pngBytes, mimeType: 'image/jpeg')),
      );
    });
  });

  group('MREAttachmentsController', () {
    test('adds, replaces, removes and clears, and notifies each time', () {
      final controller = MREAttachmentsController();
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.add(png());
      controller.add(png(otherPngBytes()));
      expect(controller.count, 2);

      controller.replaceAt(0, png(otherPngBytes()));
      controller.removeAt(1);
      expect(controller.images, hasLength(1));

      controller.clear();
      expect(controller.isEmpty, isTrue);
      expect(notifications, 5);
    });

    test('clearing an empty controller does not notify', () {
      final controller = MREAttachmentsController();
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.clear();

      expect(notifications, 0);
    });

    test('starts with the images it is given', () {
      final controller = MREAttachmentsController(images: [png()]);
      addTearDown(controller.dispose);

      expect(controller.count, 1);
    });

    test('hands out a list that cannot be changed', () {
      final controller = MREAttachmentsController(images: [png()]);
      addTearDown(controller.dispose);

      expect(() => controller.images.add(png()), throwsUnsupportedError);
    });
  });

  group('behaviours', () {
    test('MRENoImagePaste accepts nothing and keeps nothing', () {
      const behavior = MRENoImagePaste();

      expect(behavior.acceptsImages, isFalse);
      expect(behavior.attachments, isNull);
    });

    test('MREImageCallbackPaste accepts images and keeps nothing', () {
      final behavior = MREImageCallbackPaste(onImagePasted: (_) {});

      expect(behavior.acceptsImages, isTrue);
      expect(behavior.attachments, isNull);
    });

    test(
      'MREImageAttachmentPaste keeps images, and allows replace by default',
      () {
        const behavior = MREImageAttachmentPaste();

        expect(behavior.acceptsImages, isTrue);
        expect(behavior.attachments.allowReplace, isTrue);
        expect(behavior.attachments.controller, isNull);
        expect(
          const MREImageAttachmentPaste(
            allowReplace: false,
          ).attachments.allowReplace,
          isFalse,
        );
      },
    );

    test('MREImageAttachmentPaste passes its options to the configuration', () {
      final controller = MREAttachmentsController();
      addTearDown(controller.dispose);
      void changed(List<MREPastedImage> images) {}

      final config = MREImageAttachmentPaste(
        controller: controller,
        maxImages: 7,
        onImagesChanged: changed,
      ).attachments;

      expect(config.controller, same(controller));
      expect(config.maxImages, 7);
      expect(config.onChanged, same(changed));
    });

    test('the defaults are documented values', () {
      const behavior = MREImageAttachmentPaste();

      expect(behavior.attachments.maxImages, mreDefaultMaxImages);
      expect(behavior.maxBytes, mreDefaultMaxImageBytes);
      expect(behavior.allowedMimeTypes, mreDefaultImageMimeTypes);
      expect(behavior.reader, isA<MREPasteboardImageReader>());
    });

    test('check accepts a good image', () {
      expect(const MREImageAttachmentPaste().check(png(), count: 0), isNull);
    });

    test('check rejects an image that is too large', () {
      const behavior = MREImageAttachmentPaste(maxBytes: 10);

      expect(behavior.check(png(), count: 0), MREImageRejection.tooLarge);
    });

    test('check rejects a type that is not allowed', () {
      const behavior = MREImageAttachmentPaste(
        allowedMimeTypes: ['image/jpeg'],
      );

      expect(behavior.check(png(), count: 0), MREImageRejection.wrongType);
      expect(
        const MREImageAttachmentPaste().check(
          MREPastedImage(
            bytes: Uint8List(4),
            mimeType: 'application/octet-stream',
          ),
          count: 0,
        ),
        MREImageRejection.wrongType,
      );
    });

    test('check rejects more images than maxImages for attachments only', () {
      const attachments = MREImageAttachmentPaste(maxImages: 2);

      expect(attachments.check(png(), count: 1), isNull);
      expect(attachments.check(png(), count: 2), MREImageRejection.tooMany);
      expect(
        MREImageCallbackPaste(onImagePasted: (_) {}).check(png(), count: 99),
        isNull,
        reason: 'the callback behaviour holds no images',
      );
    });

    test('imageFromBytes trusts the bytes over the declared type', () {
      const behavior = MREImageAttachmentPaste();

      expect(
        behavior.imageFromBytes(pngBytes, 'image/jpeg').mimeType,
        'image/png',
      );
      expect(
        behavior.imageFromBytes(Uint8List(8), 'image/gif').mimeType,
        'image/gif',
      );
    });

    test('a subclass can keep images through its own configuration', () {
      final behavior = _KeepingBehavior();

      expect(behavior.check(png(), count: 1), MREImageRejection.tooMany);
      expect(behavior.check(png(), count: 0), isNull);
    });
  });

  group('MREPasteboardImageReader', () {
    // The plugin reads through this channel; its answer type depends on the OS.
    final supported = Platform.isMacOS || Platform.isLinux;

    void mockChannel(Object? result) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('pasteboard'), (
            call,
          ) async {
            return call.method == 'image' ? result : null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('pasteboard'), null);
      });
    }

    test('returns the clipboard image with its detected type', () async {
      mockChannel(pngBytes);

      final image = await const MREPasteboardImageReader().read();

      expect(image!.mimeType, 'image/png');
      expect(image.bytes, pngBytes);
    }, skip: !supported);

    test('returns null when the clipboard has no image', () async {
      mockChannel(null);

      expect(await const MREPasteboardImageReader().read(), isNull);
    }, skip: !supported);

    test('marks unknown data as a generic type', () async {
      mockChannel(Uint8List.fromList('not an image'.codeUnits));

      final image = await const MREPasteboardImageReader().read();

      expect(image!.mimeType, 'application/octet-stream');
    }, skip: !supported);
  });
}

class _KeepingBehavior extends MREImagePasteBehavior {
  @override
  bool get acceptsImages => true;

  @override
  MREAttachmentsConfig get attachments =>
      const MREAttachmentsConfig(maxImages: 1);
}
