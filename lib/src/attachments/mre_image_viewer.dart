import 'package:flutter/material.dart';

import '../theme/mre_fields_theme.dart';
import 'mre_pasted_image.dart';

/// Space between the screen edge and the close button.
const double _viewerButtonInset = 8;

/// Shows images full screen, with pinch to zoom and swipe between images.
///
/// Open it with [MREImageViewer.show]:
///
/// {@example /doc/snippets/attachments.dart#viewer}
///
/// {@category Attachments}
class MREImageViewer extends StatefulWidget {
  /// Creates the viewer content. Use [show] to open it in a dialog.
  const MREImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.closeTooltip,
  });

  /// The images to show.
  final List<MREPastedImage> images;

  /// The image to start on.
  final int initialIndex;

  /// Tooltip of the close button. Defaults to
  /// [MREFieldsStrings.closeViewerTooltip].
  final String? closeTooltip;

  /// Opens the viewer as a full-screen dialog.
  static Future<void> show(
    BuildContext context, {
    required List<MREPastedImage> images,
    int initialIndex = 0,
    String? closeTooltip,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: MREImageViewer(
          images: images,
          initialIndex: initialIndex,
          closeTooltip: closeTooltip,
        ),
      ),
    );
  }

  @override
  State<MREImageViewer> createState() => _MREImageViewerState();
}

class _MREImageViewerState extends State<MREImageViewer> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tooltip =
        widget.closeTooltip ??
        MREFieldsTheme.of(context).strings.closeViewerTooltip;

    return Stack(
      children: [
        PageView.builder(
          controller: _pages,
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return InteractiveViewer(
              child: Center(
                child: Image.memory(
                  widget.images[index].bytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            );
          },
        ),
        PositionedDirectional(
          top: _viewerButtonInset,
          end: _viewerButtonInset,
          child: SafeArea(
            child: IconButton.filledTonal(
              icon: const Icon(Icons.close_rounded),
              tooltip: tooltip,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }
}
