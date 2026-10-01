import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

import 'demo_frame.dart';

/// Pasting images into a field. This page is recorded for the documentation.
class PasteDemo extends StatelessWidget {
  /// Creates the page.
  const PasteDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoFrame(
      title: 'Paste an image',
      child: MRETextField(
        labelText: 'Message',
        hintText: 'Copy an image, then paste it here',
        maxLines: 3,
        imagePaste: MREImageAttachmentPaste(),
      ),
    );
  }
}
