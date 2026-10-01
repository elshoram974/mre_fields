import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'mre_fields_strings.dart';

/// Width class of the space a field has available.
///
/// Fields choose layout and density from this value, never from the platform.
/// See [MREFieldsTheme.windowSizeFor].
///
/// {@category Theme}
enum MREWindowSize {
  /// Narrow space, such as a phone in portrait.
  compact,

  /// Mid-width space, such as a large phone or a small tablet.
  medium,

  /// Wide space, such as a tablet in landscape or a desktop window.
  expanded,
}

/// Field-level tokens that sit next to the host theme.
///
/// Colors, typography and input chrome come from the host [ThemeData]
/// (`colorScheme`, `textTheme`, `inputDecorationTheme`). This extension only
/// adds what Material does not model: radius, padding, breakpoints and
/// [strings].
///
/// Register it on the same [ThemeData] the app already builds:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     colorScheme: hostScheme,
///     extensions: const [
///       MREFieldsTheme(
///         fieldBorderRadius: 16,
///         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
///       ),
///     ],
///   ),
/// );
/// ```
///
/// Precedence, highest first: a widget parameter, this extension, the
/// defaults below. Without a registered extension every widget uses
/// [MREFieldsTheme.defaults], so previews and quick demos work unthemed.
///
/// See also:
///
///  * [MREFieldsStrings], the texts carried in [strings].
///  * [MREWindowSize], the classes the breakpoints produce.
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
  /// Pass the width a field really has, for example
  /// `LayoutBuilder` constraints, not the screen width.
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
