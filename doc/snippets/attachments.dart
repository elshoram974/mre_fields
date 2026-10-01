// Snippets embedded in the API docs and the attachments guide. They are
// analyzed and run in test/doc/attachments_snippets_test.dart, so each example
// is correct.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

/// Stand-in for sending the image to a server.
void upload(Uint8List bytes) {}

/// Stand-in for showing a message to the user.
void showError(MREImageRejection reason) {}

/// The images the last field reported.
List<MREPastedImage> attached = const [];

/// The three behaviours side by side.
Widget behaviorsExample() {
  // #region behaviors
  // Text only. This is the default.
  const textOnly = MRETextField(labelText: 'Message');

  // Your code gets each image. Nothing is shown.
  final callback = MRETextField(
    labelText: 'Message',
    imagePaste: MREImageCallbackPaste(
      onImagePasted: (image) => upload(image.bytes),
    ),
  );

  // Images appear under the field.
  const attachments = MRETextField(
    labelText: 'Message',
    imagePaste: MREImageAttachmentPaste(),
  );
  // #endregion behaviors

  return Column(children: [textOnly, callback, attachments]);
}

/// A field that keeps up to four images under itself.
Widget attachmentsField() {
  // #region attachments
  final field = MRETextField(
    labelText: 'Message',
    maxLines: 3,
    imagePaste: MREImageAttachmentPaste(
      maxImages: 4,
      maxBytes: 5 * 1024 * 1024,
      onImagesChanged: (images) => attached = images,
      onImageRejected: (reason, image) => showError(reason),
    ),
  );
  // #endregion attachments

  return field;
}

/// A field whose images your code can read and change.
Widget withAttachmentsController(MREAttachmentsController controller) {
  // #region controller
  // Create the controller in initState and dispose it in dispose.
  final field = MRETextField(
    labelText: 'Message',
    imagePaste: MREImageAttachmentPaste(controller: controller),
  );

  // Later: controller.images, controller.removeAt(0), controller.clear().
  // #endregion controller

  return field;
}

/// A button that opens the images full screen.
Widget viewerButton(List<MREPastedImage> images) {
  return Builder(
    builder: (context) {
      // #region viewer
      final button = TextButton(
        onPressed: () => MREImageViewer.show(context, images: images),
        child: const Text('View images'),
      );
      // #endregion viewer

      return button;
    },
  );
}

/// The thumbnails on their own.
Widget stripAlone(MREAttachmentsController controller) {
  // #region strip
  final strip = MREAttachmentStrip(
    controller: controller,
    onReplace: (index) {
      // Pick another image, then: controller.replaceAt(index, image).
    },
  );
  // #endregion strip

  return strip;
}

/// Image paste on a plain [TextField].
Widget scopeOnPlainField() {
  // #region scope
  final field = MREImagePasteScope(
    behavior: MREImageAttachmentPaste(),
    builder: (context, hooks) => TextField(
      contentInsertionConfiguration: hooks.contentInsertionConfiguration,
      contextMenuBuilder: hooks.contextMenuBuilder,
    ),
  );
  // #endregion scope

  return field;
}
