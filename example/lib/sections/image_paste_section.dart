import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

import 'section_card.dart';

/// Pasting images: kept inside the field, or handed to the app.
class ImagePasteSection extends StatefulWidget {
  /// Creates the section.
  const ImagePasteSection({super.key});

  @override
  State<ImagePasteSection> createState() => _ImagePasteSectionState();
}

class _ImagePasteSectionState extends State<ImagePasteSection> {
  final _customImages = MREAttachmentsController();

  @override
  void dispose() {
    _customImages.dispose();
    super.dispose();
  }

  String _received = 'Nothing received yet';

  void _onImage(MREPastedImage image) {
    final kilobytes = (image.length / 1024).toStringAsFixed(1);
    setState(() => _received = 'Received ${image.mimeType}, $kilobytes KB');
  }

  void _onRejected(MREImageRejection reason, MREPastedImage? image) {
    setState(() => _received = 'Rejected: ${reason.name}');
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Image paste',
      subtitle:
          'Copy an image, click a field, then paste: Ctrl or Cmd + V on '
          'desktop and web, the selection menu on any device.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          MRETextField(
            labelText: 'Keeps the images inside the field',
            maxLines: 3,
            imagePaste: MREImageAttachmentPaste(
              showCounter: true,
              onImageRejected: _onRejected,
            ),
          ),
          MRETextField(
            labelText: 'Hands the image to the app',
            imagePaste: MREImageCallbackPaste(
              onImagePasted: _onImage,
              onImageRejected: _onRejected,
            ),
          ),
          MRETextField(
            labelText: 'Your own image layout',
            imagePaste: MREImageAttachmentPaste(
              controller: _customImages,
              builder: (context, presentation) => Wrap(
                spacing: 8,
                children: [
                  for (
                    var index = 0;
                    index < presentation.controller.count;
                    index++
                  )
                    InputChip(
                      avatar: const Icon(Icons.image_outlined),
                      label: Text(
                        presentation.controller.images[index].name ?? 'Image',
                      ),
                      onDeleted: presentation.onRemove == null
                          ? null
                          : () => presentation.onRemove!(index),
                    ),
                ],
              ),
            ),
          ),
          Text(_received),
        ],
      ),
    );
  }
}
