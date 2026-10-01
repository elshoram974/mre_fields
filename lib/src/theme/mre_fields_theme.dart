import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'mre_fields_strings.dart';
import 'mre_window_size.dart';

/// Field-only tokens: corner radius, padding, breakpoints and texts.
///
/// Colors and fonts stay in your `ThemeData`. Register this extension on it:
///
/// {@example /doc/snippets/theme.dart#global}
///
/// Order of priority: a widget parameter, then this extension, then
/// [MREFieldsTheme.defaults] when nothing is registered.
///
/// Change one value and keep the rest with [copyWith]:
///
/// {@example /doc/snippets/theme.dart#copy_with}
///
/// See also:
///
///  * [MREFieldsStrings], the texts in [strings].
///  * [MREWindowSize], the sizes the breakpoints produce.
///
/// {@category Theme}
@immutable
class MREFieldsTheme extends ThemeExtension<MREFieldsTheme> {
  /// Creates field tokens. Omitted values keep their default.
  const MREFieldsTheme({
    this.fieldBorderRadius = defaultFieldBorderRadius,
    this.contentPadding = defaultContentPadding,
    this.expandedContentPadding = defaultExpandedContentPadding,
    this.compactBreakpoint = defaultCompactBreakpoint,
    this.expandedBreakpoint = defaultExpandedBreakpoint,
    this.strings = const MREFieldsStrings(),
  }) : assert(
         compactBreakpoint < expandedBreakpoint,
         'compactBreakpoint must be smaller than expandedBreakpoint.',
       );

  /// Default [fieldBorderRadius] in logical pixels.
  static const double defaultFieldBorderRadius = 12;

  /// Default [contentPadding].
  static const EdgeInsetsGeometry defaultContentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );

  /// Default [expandedContentPadding]. Slightly denser than the compact one.
  static const EdgeInsetsGeometry defaultExpandedContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// Default [compactBreakpoint] in logical pixels.
  static const double defaultCompactBreakpoint = 600;

  /// Default [expandedBreakpoint] in logical pixels.
  static const double defaultExpandedBreakpoint = 840;

  /// Tokens used when the host registers no [MREFieldsTheme].
  static const MREFieldsTheme defaults = MREFieldsTheme();

  /// Corner radius of the field border.
  final double fieldBorderRadius;

  /// Padding inside the field on [MREWindowSize.compact] and
  /// [MREWindowSize.medium].
  final EdgeInsetsGeometry contentPadding;

  /// Padding inside the field on [MREWindowSize.expanded].
  final EdgeInsetsGeometry expandedContentPadding;

  /// Width below which a field is [MREWindowSize.compact].
  final double compactBreakpoint;

  /// Width from which a field is [MREWindowSize.expanded].
  final double expandedBreakpoint;

  /// User-visible text of the fields.
  final MREFieldsStrings strings;

  /// Returns the tokens registered on the nearest [Theme], or [defaults].
  static MREFieldsTheme of(BuildContext context) {
    return Theme.of(context).extension<MREFieldsTheme>() ?? defaults;
  }

  /// Classifies [width] against [compactBreakpoint] and [expandedBreakpoint].
  ///
  /// Pass the width the widget really gets, from `LayoutBuilder`, not the
  /// screen width:
  ///
  /// {@example /doc/snippets/theme.dart#read_tokens}
  MREWindowSize windowSizeFor(double width) {
    if (width < compactBreakpoint) {
      return MREWindowSize.compact;
    }
    if (width < expandedBreakpoint) {
      return MREWindowSize.medium;
    }
    return MREWindowSize.expanded;
  }

  /// Returns the content padding that fits [size].
  EdgeInsetsGeometry contentPaddingFor(MREWindowSize size) {
    return size == MREWindowSize.expanded
        ? expandedContentPadding
        : contentPadding;
  }

  @override
  MREFieldsTheme copyWith({
    double? fieldBorderRadius,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? expandedContentPadding,
    double? compactBreakpoint,
    double? expandedBreakpoint,
    MREFieldsStrings? strings,
  }) {
    return MREFieldsTheme(
      fieldBorderRadius: fieldBorderRadius ?? this.fieldBorderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      expandedContentPadding:
          expandedContentPadding ?? this.expandedContentPadding,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      expandedBreakpoint: expandedBreakpoint ?? this.expandedBreakpoint,
      strings: strings ?? this.strings,
    );
  }

  /// Interpolates numbers and paddings. [strings] cannot be interpolated, so
  /// they switch to [other]'s at the halfway point.
  @override
  MREFieldsTheme lerp(ThemeExtension<MREFieldsTheme>? other, double t) {
    if (other is! MREFieldsTheme) {
      return this;
    }
    return MREFieldsTheme(
      fieldBorderRadius: lerpDouble(
        fieldBorderRadius,
        other.fieldBorderRadius,
        t,
      )!,
      contentPadding: EdgeInsetsGeometry.lerp(
        contentPadding,
        other.contentPadding,
        t,
      )!,
      expandedContentPadding: EdgeInsetsGeometry.lerp(
        expandedContentPadding,
        other.expandedContentPadding,
        t,
      )!,
      compactBreakpoint: lerpDouble(
        compactBreakpoint,
        other.compactBreakpoint,
        t,
      )!,
      expandedBreakpoint: lerpDouble(
        expandedBreakpoint,
        other.expandedBreakpoint,
        t,
      )!,
      strings: t < 0.5 ? strings : other.strings,
    );
  }
}
