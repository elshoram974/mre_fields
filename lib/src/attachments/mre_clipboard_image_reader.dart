import 'package:pasteboard/pasteboard.dart';

import 'mre_pasted_image.dart';

/// Reads an image from the system clipboard.
///
/// Implement it to read the clipboard another way, or to fake it in tests.
///
/// {@category Attachments}
abstract interface class MREClipboardImageReader {
  /// Returns the image on the clipboard, or null when there is none.
  ///
  /// May throw a `PlatformException` or `MissingPluginException` when the
  /// platform cannot be read.
  Future<MREPastedImage?> read();
}

/// Reads the clipboard through the `pasteboard` plugin.
///
/// This is the default reader. It works on Android, iOS, macOS, Windows, Linux
/// and web.
///
/// {@category Attachments}
class MREPasteboardImageReader implements MREClipboardImageReader {
  /// Creates the reader.
  const MREPasteboardImageReader();

  @override
  Future<MREPastedImage?> read() async {
    final bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    return MREPastedImage(
      bytes: bytes,
      mimeType: mreSniffImageMimeType(bytes) ?? 'application/octet-stream',
    );
  }
}
