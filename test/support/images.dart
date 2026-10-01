import 'dart:convert';
import 'dart:typed_data';

import 'package:mre_fields/mre_fields.dart';

/// A valid 1x1 PNG.
final Uint8List pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// A second PNG with other bytes, to tell two images apart.
Uint8List otherPngBytes() => Uint8List.fromList([...pngBytes, 0]);

/// A PNG image.
MREPastedImage png([Uint8List? bytes]) =>
    MREPastedImage(bytes: bytes ?? pngBytes, mimeType: 'image/png');

/// A clipboard that returns what the test sets.
class FakeClipboardImageReader implements MREClipboardImageReader {
  FakeClipboardImageReader([this.image]);

  MREPastedImage? image;
  Object? error;
  int reads = 0;

  @override
  Future<MREPastedImage?> read() async {
    reads++;
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return image;
  }
}
