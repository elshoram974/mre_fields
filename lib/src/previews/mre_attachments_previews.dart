import 'package:flutter/material.dart';

import '../attachments/ui/mre_attachment_strip.dart';
import '../attachments/model/mre_attachments_controller.dart';
import '../attachments/paste/mre_image_paste_behavior.dart';
import '../text/field/mre_text_field.dart';
import 'preview_harness.dart';
import 'preview_images.dart';

/// A field that keeps pasted images under itself, with three images attached.
@MREPreview()
Widget previewImagePasteAttachments() {
  return _WithImages(
    builder: (controller) => MRETextField(
      labelText: 'Message',
      hintText: 'Paste an image',
      maxLines: 3,
      imagePaste: MREImageAttachmentPaste(controller: controller),
    ),
  );
}

/// A field that hands pasted images to the app and shows nothing.
@MREPreview()
Widget previewImagePasteCallback() {
  return MRETextField(
    labelText: 'Message',
    hintText: 'Paste an image; the app gets it',
    imagePaste: MREImageCallbackPaste(onImagePasted: (_) {}),
  );
}

/// The thumbnails on their own, with remove and replace buttons.
@MREPreview()
Widget previewAttachmentStrip() {
  return _WithImages(
    builder: (controller) =>
        MREAttachmentStrip(controller: controller, onReplace: (_) {}),
  );
}

/// Holds a controller filled with the preview images.
class _WithImages extends StatefulWidget {
  const _WithImages({required this.builder});

  final Widget Function(MREAttachmentsController controller) builder;

  @override
  State<_WithImages> createState() => _WithImagesState();
}

class _WithImagesState extends State<_WithImages> {
  late final MREAttachmentsController _controller = MREAttachmentsController(
    images: mrePreviewImages,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}
