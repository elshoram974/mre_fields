import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../theme/mre_fields_theme.dart';

/// Space around a previewed widget, like a form row.
const double _previewPadding = 16;

/// Wraps a previewed widget in a themed surface.
///
/// Keeps the color scheme and brightness the previewer chose and registers
/// [MREFieldsTheme] on it, so a preview shows what a host app would see.
/// Use it as `@Preview(wrapper: mrePreviewWrapper)`, or through
/// [MREPreview], which already does.
Widget mrePreviewWrapper(Widget child) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Theme(
        data: theme.copyWith(
          extensions: [
            ...theme.extensions.values.where((e) => e is! MREFieldsTheme),
            MREFieldsTheme.of(context),
          ],
        ),
        child: Material(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(_previewPadding),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: child,
            ),
          ),
        ),
      );
    },
  );
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
      brightness: Brightness.light,
      wrapper: mrePreviewWrapper,
    ),
    Preview(
      group: group,
      name: 'Dark',
      brightness: Brightness.dark,
      wrapper: mrePreviewWrapper,
    ),
    Preview(group: group, name: 'RTL', wrapper: mrePreviewRtlWrapper),
    Preview(
      group: group,
      name: 'Text scale 1.3',
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
