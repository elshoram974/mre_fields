import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../model/mre_pasted_image.dart';
import 'mre_image_paste_handler.dart';

/// The text selection menu, with a "paste image" item when the clipboard holds
/// an image.
///
/// The clipboard is read once, when the menu opens.
@internal
class MREPasteImageMenu extends StatefulWidget {
  /// Creates the menu for the text field [state].
  const MREPasteImageMenu({
    super.key,
    required this.state,
    required this.handler,
    required this.label,
  });

  /// The text field the menu belongs to.
  final EditableTextState state;

  /// Reads the clipboard and keeps the image.
  final MREImagePasteHandler handler;

  /// Text of the "paste image" item.
  final String label;

  @override
  State<MREPasteImageMenu> createState() => _MREPasteImageMenuState();
}

class _MREPasteImageMenuState extends State<MREPasteImageMenu> {
  late final Future<MREPastedImage?> _image = widget.handler
      .readClipboardImage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MREPastedImage?>(
      future: _image,
      builder: (context, snapshot) {
        final image = snapshot.data;
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: widget.state.contextMenuAnchors,
          buttonItems: [
            ...widget.state.contextMenuButtonItems,
            if (image != null)
              ContextMenuButtonItem(
                label: widget.label,
                onPressed: () {
                  ContextMenuController.removeAny();
                  widget.handler.accept(image);
                },
              ),
          ],
        );
      },
    );
  }
}
