import 'package:flutter/foundation.dart';

import '../model/mre_attachments_controller.dart';
import '../model/mre_pasted_image.dart';
import 'mre_clipboard_image_reader.dart';

/// Largest image accepted by default: 10 MiB.
const int mreDefaultMaxImageBytes = 10 * 1024 * 1024;

/// Most images a field holds by default.
const int mreDefaultMaxImages = 4;

/// Image types accepted by default.
const List<String> mreDefaultImageMimeTypes = [
  'image/png',
  'image/jpeg',
  'image/gif',
  'image/webp',
  'image/bmp',
];

/// How a field keeps and shows the images it accepts.
///
/// A behaviour that returns one from [MREImagePasteBehavior.attachments] gets
/// thumbnails under the field. One that returns null keeps no images.
///
/// {@category Attachments}
@immutable
final class MREAttachmentsConfig {
  /// Creates a configuration.
  const MREAttachmentsConfig({
    this.controller,
    this.maxImages = mreDefaultMaxImages,
    this.allowReplace = true,
    this.onChanged,
  });

  /// Holds the images. The field keeps its own when null.
  final MREAttachmentsController? controller;

  /// The most images the field holds.
  final int maxImages;

  /// Whether each thumbnail has a replace button.
  final bool allowReplace;

  /// Called with a snapshot of the images after one is added, removed or
  /// replaced.
  final ValueChanged<List<MREPastedImage>>? onChanged;
}

/// What a field does when the user pastes an image.
///
/// A field takes one of three behaviours:
///
///  * [MRENoImagePaste]: nothing. This is the default.
///  * [MREImageCallbackPaste]: calls your function with the image and shows
///    nothing.
///  * [MREImageAttachmentPaste]: shows the images under the field, where the
///    user can open, remove and replace them.
///
/// {@example /doc/snippets/attachments.dart#behaviors}
///
/// Extend this class to add your own behaviour. Return an
/// [MREAttachmentsConfig] from [attachments] to keep and show images.
///
/// {@category Attachments}
abstract class MREImagePasteBehavior {
  /// Creates a behaviour with the shared limits and callbacks.
  const MREImagePasteBehavior({
    this.maxBytes = mreDefaultMaxImageBytes,
    this.allowedMimeTypes = mreDefaultImageMimeTypes,
    this.onImagePasted,
    this.onImageRejected,
    this.reader = const MREPasteboardImageReader(),
  });

  /// The largest image accepted, in bytes.
  final int maxBytes;

  /// The image types accepted, such as `image/png`.
  final List<String> allowedMimeTypes;

  /// Called with each accepted image.
  final ValueChanged<MREPastedImage>? onImagePasted;

  /// Called with the reason when an image is not accepted.
  final void Function(MREImageRejection reason, MREPastedImage? image)?
  onImageRejected;

  /// Reads images from the clipboard.
  final MREClipboardImageReader reader;

  /// Whether the field listens for images at all.
  bool get acceptsImages;

  /// How the field keeps and shows images, or null to keep none.
  MREAttachmentsConfig? get attachments => null;

  /// Returns why [image] is not accepted, or null when it is.
  ///
  /// [count] is how many images the field already holds.
  MREImageRejection? check(MREPastedImage image, {required int count}) {
    final maxImages = attachments?.maxImages;
    if (maxImages != null && count >= maxImages) {
      return MREImageRejection.tooMany;
    }
    if (image.length > maxBytes) {
      return MREImageRejection.tooLarge;
    }
    if (!allowedMimeTypes.contains(image.mimeType)) {
      return MREImageRejection.wrongType;
    }
    return null;
  }

  /// Makes an image from bytes that arrived with a [mimeType], for example from
  /// a keyboard. The bytes decide the type when they are recognized.
  MREPastedImage imageFromBytes(Uint8List bytes, String mimeType) {
    return MREPastedImage(
      bytes: bytes,
      mimeType: mreSniffImageMimeType(bytes) ?? mimeType,
    );
  }
}

/// Ignores images. A field with this behaviour pastes text only.
///
/// {@category Attachments}
class MRENoImagePaste extends MREImagePasteBehavior {
  /// Creates the behaviour.
  const MRENoImagePaste();

  @override
  bool get acceptsImages => false;
}

/// Gives each pasted image to [onImagePasted] and shows nothing.
///
/// Use it when you decide what to do with the image: upload it, send it, or
/// draw it yourself.
///
/// {@category Attachments}
class MREImageCallbackPaste extends MREImagePasteBehavior {
  /// Creates the behaviour. [onImagePasted] is required.
  const MREImageCallbackPaste({
    required ValueChanged<MREPastedImage> onImagePasted,
    super.maxBytes,
    super.allowedMimeTypes,
    super.onImageRejected,
    super.reader,
  }) : super(onImagePasted: onImagePasted);

  @override
  bool get acceptsImages => true;
}

/// Shows pasted images under the field.
///
/// The user can open an image full screen, remove it, and replace it with the
/// image on the clipboard. [onImagePasted] and [onImagesChanged] tell your code
/// what happened.
///
/// {@category Attachments}
class MREImageAttachmentPaste extends MREImagePasteBehavior {
  /// Creates the behaviour.
  const MREImageAttachmentPaste({
    this.controller,
    this.onImagesChanged,
    this.allowReplace = true,
    this.maxImages = mreDefaultMaxImages,
    super.maxBytes,
    super.allowedMimeTypes,
    super.onImagePasted,
    super.onImageRejected,
    super.reader,
  });

  /// Holds the images. The field keeps its own when null.
  final MREAttachmentsController? controller;

  /// Called with a snapshot of the images after one is added, removed or
  /// replaced.
  final ValueChanged<List<MREPastedImage>>? onImagesChanged;

  /// Whether each thumbnail has a replace button.
  final bool allowReplace;

  /// The most images the field holds.
  final int maxImages;

  @override
  bool get acceptsImages => true;

  @override
  MREAttachmentsConfig get attachments => MREAttachmentsConfig(
    controller: controller,
    maxImages: maxImages,
    allowReplace: allowReplace,
    onChanged: onImagesChanged,
  );
}
