import 'package:flutter/widgets.dart';
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
/// thumbnails inside the field. One that returns null keeps no images.
///
/// {@category Attachments}
@immutable
final class MREAttachmentsConfig {
  /// Creates a configuration.
  const MREAttachmentsConfig({
    this.controller,
    this.maxImages = mreDefaultMaxImages,
    this.showCounter = false,
    this.allowReplace = true,
    this.onChanged,
    this.builder,
  });

  /// Optional presentation. Receives guarded edit actions and the controller.
  /// The result appears inside the field above its text input.
  final MREAttachmentsBuilder? builder;

  /// Holds the images. The field keeps its own when null.
  final MREAttachmentsController? controller;

  /// The most images the field holds.
  final int maxImages;

  /// Shows the current image count and limit inside the field.
  final bool showCounter;

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
///  * [MREImageAttachmentPaste]: shows the images inside the field, where the
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

/// Shows pasted images inside the field.
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
    this.builder,
    this.allowReplace = true,
    this.maxImages = mreDefaultMaxImages,
    this.showCounter = false,
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

  /// Replaces the built-in thumbnails, including when the collection is empty.
  /// Return an empty widget to hide the presentation at zero images.
  /// Use callback-only paste to render
  /// images outside the field instead.
  final MREAttachmentsBuilder? builder;

  /// Whether each thumbnail has a replace button.
  final bool allowReplace;

  /// The most images the field holds.
  final int maxImages;

  /// Shows the current image count and limit inside the field.
  final bool showCounter;

  @override
  bool get acceptsImages => true;

  @override
  MREAttachmentsConfig get attachments => MREAttachmentsConfig(
    controller: controller,
    maxImages: maxImages,
    showCounter: showCounter,
    allowReplace: allowReplace,
    onChanged: onImagesChanged,
    builder: builder,
  );
}

/// Builds a custom presentation of the images inside a field.
///
/// Edit callbacks are null while the field is disabled or read-only.
/// {@category Attachments}
typedef MREAttachmentsBuilder =
    Widget Function(
      BuildContext context,
      MREAttachmentsPresentation presentation,
    );

/// Images and permitted actions given to an attachments builder.
/// {@category Attachments}
@immutable
class MREAttachmentsPresentation {
  /// Creates presentation data.
  const MREAttachmentsPresentation({
    required this.controller,
    this.maxImages = mreDefaultMaxImages,
    this.onRemove,
    this.onReplace,
  });

  /// Maximum number of images accepted by this field.
  final int maxImages;

  /// Whether the current images have reached the configured limit.
  bool get isAtLimit => controller.count >= maxImages;

  /// The images to display. Ownership stays with the field or host.
  final MREAttachmentsController controller;

  /// Removes an image; null when editing is unavailable.
  final ValueChanged<int>? onRemove;

  /// Replaces an image from the clipboard; null when unavailable.
  final ValueChanged<int>? onReplace;
}
