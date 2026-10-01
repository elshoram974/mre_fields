import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../theme/mre_fields_theme.dart';

/// Space around a previewed widget, like a form row.
const double _previewPadding = 16;

/// Width of the light, dark, right to left and text scale cards, and the
/// fallback width when the previewer gives none. A card without a width gets
/// unbounded width, and a field that stretches to its parent cannot lay out in
/// that.
const double _defaultPreviewWidth = 480;

/// Seed of the preview color scheme. Only previews use it; hosts bring their
/// own colors.
const Color _previewSeedColor = Color(0xFF005F73);

/// Wraps a previewed widget in a themed surface.
///
/// The previewer sets the card brightness through `MediaQuery`, not through a
/// theme, so this wrapper builds a Material theme for that brightness and
/// registers [MREFieldsTheme] on it. Use it as
/// `@Preview(wrapper: mrePreviewWrapper)`, or through [MREPreview], which
/// already does.
Widget mrePreviewWrapper(Widget child) {
  return Builder(
    builder: (context) {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _previewSeedColor,
          brightness: MediaQuery.platformBrightnessOf(context),
        ),
        extensions: const [MREFieldsTheme()],
      );
      return Theme(
        data: theme,
        child: Material(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(_previewPadding),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: _BoundedWidth(child: child),
            ),
          ),
        ),
      );
    },
  );
}

const Size _defaultSize = Size.fromWidth(_defaultPreviewWidth);

/// Gives [child] a finite width when the previewer offers none.
class _BoundedWidth extends StatelessWidget {
  const _BoundedWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedWidth) {
          return child;
        }
        return SizedBox(width: _defaultPreviewWidth, child: child);
      },
    );
  }
}

/// Like [mrePreviewWrapper], with right-to-left layout.
Widget mrePreviewRtlWrapper(Widget child) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: mrePreviewWrapper(child),
  );
}

/// Previews one widget in every state a field must survive.
///
/// Put it on any top-level function that takes no arguments and returns a
/// [Widget]:
///
/// ```dart
/// @MREPreview()
/// Widget previewMyField() => const MyField();
/// ```
///
/// The previewer shows six cards: light, dark, right to left, text scale 1.3,
/// a narrow window (390) and a wide window (1024).
final class MREPreview extends MultiPreview {
  /// Creates the annotation.
  const MREPreview({this.group = 'mre_fields'});

  /// The previewer group the cards appear in.
  final String group;

  @override
  List<Preview> get previews => [
    Preview(
      group: group,
      name: 'Light',
      size: _defaultSize,
      brightness: Brightness.light,
      wrapper: mrePreviewWrapper,
    ),
    Preview(
      group: group,
      name: 'Dark',
      size: _defaultSize,
      brightness: Brightness.dark,
      wrapper: mrePreviewWrapper,
    ),
    Preview(
      group: group,
      name: 'RTL',
      size: _defaultSize,
      wrapper: mrePreviewRtlWrapper,
    ),
    Preview(
      group: group,
      name: 'Text scale 1.3',
      size: _defaultSize,
      textScaleFactor: 1.3,
      wrapper: mrePreviewWrapper,
    ),
    Preview(
      group: group,
      name: 'Narrow 390',
      size: const Size.fromWidth(390),
      wrapper: mrePreviewWrapper,
    ),
    Preview(
      group: group,
      name: 'Wide 1024',
      size: const Size.fromWidth(1024),
      wrapper: mrePreviewWrapper,
    ),
  ];
}
