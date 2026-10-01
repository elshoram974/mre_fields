import 'package:flutter/foundation.dart';

/// An image the user pasted into a field.
///
/// It holds the bytes and the type, never a file, so it works the same on
/// mobile, desktop and web.
///
/// {@category Attachments}
@immutable
class MREPastedImage {
  /// Creates an image from its [bytes] and [mimeType], such as `image/png`.
  const MREPastedImage({
    required this.bytes,
    required this.mimeType,
    this.name,
  });

  /// The encoded image, for example PNG or JPEG data.
  final Uint8List bytes;

  /// The media type of [bytes], such as `image/png`.
  final String mimeType;

  /// A file name, when the source gave one.
  final String? name;

  /// The size of [bytes] in bytes.
  int get length => bytes.length;

  @override
  bool operator ==(Object other) {
    return other is MREPastedImage &&
        identical(other.bytes, bytes) &&
        other.mimeType == mimeType &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(identityHashCode(bytes), mimeType, name);
}

/// Why a pasted image was not accepted.
///
/// {@category Attachments}
enum MREImageRejection {
  /// The image is larger than the allowed size.
  tooLarge,

  /// The image type is not in the allowed list, or is not an image.
  wrongType,

  /// The field already holds the most images it allows.
  tooMany,

  /// The clipboard or the keyboard could not be read.
  unreadable,
}

/// Returns the media type of image [bytes], or null when they are not one of
/// PNG, JPEG, GIF, WebP, BMP, HEIC or TIFF.
///
/// It reads the first bytes only.
///
/// {@category Attachments}
String? mreSniffImageMimeType(Uint8List bytes) {
  bool startsWith(List<int> signature, [int offset = 0]) {
    if (bytes.length < offset + signature.length) {
      return false;
    }
    for (var i = 0; i < signature.length; i++) {
      if (bytes[offset + i] != signature[i]) {
        return false;
      }
    }
    return true;
  }

  if (startsWith(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'image/png';
  }
  if (startsWith(const [0xFF, 0xD8, 0xFF])) {
    return 'image/jpeg';
  }
  if (startsWith(const [0x47, 0x49, 0x46, 0x38])) {
    return 'image/gif';
  }
  if (startsWith(const [0x52, 0x49, 0x46, 0x46]) &&
      startsWith(const [0x57, 0x45, 0x42, 0x50], 8)) {
    return 'image/webp';
  }
  if (startsWith(const [0x42, 0x4D])) {
    return 'image/bmp';
  }
  if (startsWith(const [0x66, 0x74, 0x79, 0x70], 4) &&
      (startsWith(const [0x68, 0x65, 0x69, 0x63], 8) ||
          startsWith(const [0x68, 0x65, 0x69, 0x78], 8) ||
          startsWith(const [0x6D, 0x69, 0x66, 0x31], 8))) {
    return 'image/heic';
  }
  if (startsWith(const [0x49, 0x49, 0x2A, 0x00]) ||
      startsWith(const [0x4D, 0x4D, 0x00, 0x2A])) {
    return 'image/tiff';
  }
  return null;
}
