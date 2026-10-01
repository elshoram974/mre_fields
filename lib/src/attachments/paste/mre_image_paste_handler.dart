import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/mre_attachments_controller.dart';
import '../model/mre_pasted_image.dart';
import 'mre_image_paste_behavior.dart';

/// The rules of image paste, without any widget.
///
/// It reads the clipboard, checks an image against the behaviour's limits,
/// keeps it in the controller, and tells the behaviour's callbacks. Widgets only
/// call it, so the rules can be tested alone.
@internal
final class MREImagePasteHandler {
  /// Creates a handler.
  ///
  /// [controller] is where images are kept; null when the behaviour keeps none.
  /// [isActive] says whether the widget that owns the handler is still alive,
  /// and is checked after every wait.
  const MREImagePasteHandler({
    required this.behavior,
    required this.controller,
    required this.isActive,
  });

  /// What to do with images.
  final MREImagePasteBehavior behavior;

  /// Where images are kept, or null.
  final MREAttachmentsController? controller;

  /// Whether the owning widget is still alive.
  final bool Function() isActive;

  /// Checks [image] and keeps it, or reports why not.
  ///
  /// With [replacing] the image takes the place of the one at that index, which
  /// does not count against the limit.
  void accept(MREPastedImage image, {int? replacing}) {
    final images = controller;
    final held = (images?.count ?? 0) - (replacing == null ? 0 : 1);
    final reason = behavior.check(image, count: held);
    if (reason != null) {
      behavior.onImageRejected?.call(reason, image);
      return;
    }

    if (images != null) {
      if (replacing == null) {
        images.add(image);
      } else {
        images.replaceAt(replacing, image);
      }
      _notifyChanged(images);
    }
    behavior.onImagePasted?.call(image);
  }

  /// Removes the image at [index].
  void remove(int index) {
    final images = controller!;
    images.removeAt(index);
    _notifyChanged(images);
  }

  /// Reads the image on the clipboard.
  ///
  /// A platform that cannot be read is reported as
  /// [MREImageRejection.unreadable] and gives null.
  Future<MREPastedImage?> readClipboardImage() async {
    try {
      return await behavior.reader.read();
    } on PlatformException {
      behavior.onImageRejected?.call(MREImageRejection.unreadable, null);
    } on MissingPluginException {
      behavior.onImageRejected?.call(MREImageRejection.unreadable, null);
    }
    return null;
  }

  /// Handles the paste shortcut.
  ///
  /// Text on the clipboard always wins, so a copy from a document, which holds
  /// text and a picture, pastes as text. [pasteText] runs when the clipboard
  /// has text or no image.
  Future<void> pasteShortcut(VoidCallback pasteText) async {
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    if (!isActive()) {
      return;
    }
    if (text?.text?.isNotEmpty ?? false) {
      pasteText();
      return;
    }

    final image = await readClipboardImage();
    if (!isActive()) {
      return;
    }
    if (image == null) {
      pasteText();
      return;
    }
    accept(image);
  }

  /// Replaces the image at [index] with the one on the clipboard.
  Future<void> replace(int index) async {
    final image = await readClipboardImage();
    if (!isActive()) {
      return;
    }
    if (image == null) {
      behavior.onImageRejected?.call(MREImageRejection.unreadable, null);
      return;
    }
    accept(image, replacing: index);
  }

  /// Handles content an on-screen keyboard inserted.
  void keyboardContent(KeyboardInsertedContent content) {
    final data = content.data;
    if (data == null || data.isEmpty) {
      behavior.onImageRejected?.call(MREImageRejection.unreadable, null);
      return;
    }
    accept(behavior.imageFromBytes(data, content.mimeType));
  }

  void _notifyChanged(MREAttachmentsController images) {
    behavior.attachments?.onChanged?.call(List.unmodifiable(images.images));
  }
}
