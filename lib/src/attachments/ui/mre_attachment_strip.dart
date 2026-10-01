import 'package:flutter/material.dart';

import '../../theme/mre_fields_theme.dart';
import '../../theme/mre_window_size.dart';
import '../model/mre_attachments_controller.dart';
import 'mre_image_viewer.dart';
import '../model/mre_pasted_image.dart';

/// Thumbnail edge on compact and medium widths. Two 40 px buttons fit in it
/// and leave room to tap the image.
const double _compactThumbnailSize = 96;

/// Thumbnail edge on expanded widths.
const double _expandedThumbnailSize = 120;

/// Space between thumbnails.
const double _thumbnailSpacing = 8;

/// Edge of the remove and replace buttons.
const double _thumbnailButtonSize = 40;

/// Inset of the buttons from the thumbnail edge.
const double _thumbnailButtonInset = 2;

/// Thumbnails of the images in a [MREAttachmentsController].
///
/// Tapping a thumbnail opens [MREImageViewer]. Each thumbnail has a remove
/// button and, when [onReplace] is set, a replace button. It lays out from the
/// width it gets and scrolls sideways when the images do not fit.
///
/// [MRETextField] shows it under the field with `MREImageAttachmentPaste`.
///
/// {@example /doc/snippets/attachments.dart#strip}
///
/// {@category Attachments}
class MREAttachmentStrip extends StatelessWidget {
  /// Creates a strip for [controller].
  const MREAttachmentStrip({
    super.key,
    required this.controller,
    this.onRemove,
    this.onReplace,
  });

  /// The images to show.
  final MREAttachmentsController controller;

  /// Called with the index of the image to remove. Defaults to
  /// [MREAttachmentsController.removeAt].
  final ValueChanged<int>? onRemove;

  /// Called with the index of the image to replace. The replace button is
  /// hidden when this is null.
  final ValueChanged<int>? onReplace;

  @override
  Widget build(BuildContext context) {
    final tokens = MREFieldsTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = tokens.windowSizeFor(constraints.maxWidth);
        final edge = size == MREWindowSize.expanded
            ? _expandedThumbnailSize
            : _compactThumbnailSize;

        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.isEmpty) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              height: edge,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.count,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: _thumbnailSpacing),
                itemBuilder: (context, index) => _Thumbnail(
                  image: controller.images[index],
                  edge: edge,
                  radius: tokens.fieldBorderRadius,
                  removeTooltip: tokens.strings.removeImageTooltip,
                  replaceTooltip: tokens.strings.replaceImageTooltip,
                  label: tokens.strings.attachedImageLabel,
                  onOpen: () => MREImageViewer.show(
                    context,
                    images: controller.images,
                    initialIndex: index,
                    closeTooltip: tokens.strings.closeViewerTooltip,
                  ),
                  onRemove: () => (onRemove ?? controller.removeAt)(index),
                  onReplace: onReplace == null ? null : () => onReplace!(index),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.image,
    required this.edge,
    required this.radius,
    required this.removeTooltip,
    required this.replaceTooltip,
    required this.label,
    required this.onOpen,
    required this.onRemove,
    required this.onReplace,
  });

  final MREPastedImage image;
  final double edge;
  final double radius;
  final String removeTooltip;
  final String replaceTooltip;
  final String label;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final pixels = (edge * MediaQuery.devicePixelRatioOf(context)).ceil();

    return SizedBox.square(
      dimension: edge,
      child: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              label: label,
              button: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: InkWell(
                  onTap: onOpen,
                  child: Image.memory(
                    image.bytes,
                    fit: BoxFit.cover,
                    cacheWidth: pixels,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stack) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: _thumbnailButtonInset,
            end: _thumbnailButtonInset,
            child: _ThumbnailButton(
              icon: Icons.close_rounded,
              tooltip: removeTooltip,
              onPressed: onRemove,
            ),
          ),
          if (onReplace != null)
            PositionedDirectional(
              bottom: _thumbnailButtonInset,
              end: _thumbnailButtonInset,
              child: _ThumbnailButton(
                icon: Icons.swap_horiz_rounded,
                tooltip: replaceTooltip,
                onPressed: onReplace!,
              ),
            ),
        ],
      ),
    );
  }
}

class _ThumbnailButton extends StatelessWidget {
  const _ThumbnailButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      // Without this the tap area grows to 48 px and covers the image.
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      constraints: const BoxConstraints.tightFor(
        width: _thumbnailButtonSize,
        height: _thumbnailButtonSize,
      ),
    );
  }
}
