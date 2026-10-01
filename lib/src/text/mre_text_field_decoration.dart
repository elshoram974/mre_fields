import 'package:flutter/material.dart';

import '../theme/mre_fields_theme.dart';

/// Returns [border] with [radius] when it is an outline border; any other
/// border is returned unchanged.
InputBorder? _withRadius(InputBorder? border, BorderRadius radius) {
  return border is OutlineInputBorder
      ? border.copyWith(borderRadius: radius)
      : border;
}

/// Builds the [InputDecoration] of an `MRETextField`.
///
/// Priority for padding and radius: the widget parameter, then the
/// [MREFieldsTheme] the host registered, then the host's own
/// `InputDecorationTheme`, then the package default. Without a radius from the
/// parameter or a registered [MREFieldsTheme], borders stay as the host theme
/// defines them.
InputDecoration resolveMRETextFieldDecoration({
  required InputDecoration base,
  required ThemeData theme,
  required MREWindowSize size,
  double? borderRadius,
  EdgeInsetsGeometry? contentPadding,
}) {
  final host = theme.inputDecorationTheme;
  final registered = theme.extension<MREFieldsTheme>();
  final tokens = registered ?? MREFieldsTheme.defaults;

  final padding =
      contentPadding ??
      base.contentPadding ??
      registered?.contentPaddingFor(size) ??
      host.contentPadding ??
      tokens.contentPaddingFor(size);

  final radius = borderRadius ?? registered?.fieldBorderRadius;
  if (radius == null) {
    return base.copyWith(contentPadding: padding);
  }

  final corners = BorderRadius.circular(radius);
  return base.copyWith(
    contentPadding: padding,
    border: _withRadius(
      base.border ?? host.border ?? const OutlineInputBorder(),
      corners,
    ),
    enabledBorder: _withRadius(
      base.enabledBorder ?? host.enabledBorder,
      corners,
    ),
    focusedBorder: _withRadius(
      base.focusedBorder ?? host.focusedBorder,
      corners,
    ),
    errorBorder: _withRadius(base.errorBorder ?? host.errorBorder, corners),
    focusedErrorBorder: _withRadius(
      base.focusedErrorBorder ?? host.focusedErrorBorder,
      corners,
    ),
    disabledBorder: _withRadius(
      base.disabledBorder ?? host.disabledBorder,
      corners,
    ),
  );
}
