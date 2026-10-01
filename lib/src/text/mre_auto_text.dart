import 'package:flutter/widgets.dart';

import 'mre_text_extensions.dart';

/// A [Text] whose direction follows its content.
///
/// Arabic text reads right to left and English text left to right, whatever the
/// app locale is. Text without a letter, such as digits only, keeps the
/// surrounding direction. It takes every parameter of [Text], so style, lines,
/// overflow and scaling work as usual.
///
/// {@example /doc/snippets/text.dart#auto_text}
///
/// Pass [textDirection] to turn detection off. Set [autoAlign] to also pin the
/// text to the side its content starts on.
///
/// See also:
///
///  * [MREAutoDirectionText], the same behaviour on an existing [Text].
///  * [detectTextDirection], the check this widget uses.
///
/// {@category Text}
class MREAutoText extends StatelessWidget {
  /// Creates a text with the given [data].
  const MREAutoText(
    String this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.autoAlign = false,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  /// Creates a text from an [InlineSpan] tree. The direction follows the plain
  /// text of [textSpan].
  const MREAutoText.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.autoAlign = false,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  /// The text to display. Null for [MREAutoText.rich].
  final String? data;

  /// The spans to display. Null for the default constructor.
  final InlineSpan? textSpan;

  /// See [Text.style].
  final TextStyle? style;

  /// See [Text.strutStyle].
  final StrutStyle? strutStyle;

  /// See [Text.textAlign]. Wins over [autoAlign] when set.
  final TextAlign? textAlign;

  /// Fixes the direction and turns detection off when set.
  final TextDirection? textDirection;

  /// Whether to align the text to the side its content starts on, right for
  /// Arabic and left for English. Off by default, because [TextAlign.start]
  /// already follows the detected direction.
  final bool autoAlign;

  /// See [Text.locale].
  final Locale? locale;

  /// See [Text.softWrap].
  final bool? softWrap;

  /// See [Text.overflow].
  final TextOverflow? overflow;

  /// See [Text.textScaler].
  final TextScaler? textScaler;

  /// See [Text.maxLines].
  final int? maxLines;

  /// See [Text.semanticsLabel].
  final String? semanticsLabel;

  /// See [Text.semanticsIdentifier].
  final String? semanticsIdentifier;

  /// See [Text.textWidthBasis].
  final TextWidthBasis? textWidthBasis;

  /// See [Text.textHeightBehavior].
  final TextHeightBehavior? textHeightBehavior;

  /// See [Text.selectionColor].
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final text = data;
    final base = text != null
        ? Text(
            text,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            overflow: overflow,
            textScaler: textScaler,
            maxLines: maxLines,
            semanticsLabel: semanticsLabel,
            semanticsIdentifier: semanticsIdentifier,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior,
            selectionColor: selectionColor,
          )
        : Text.rich(
            textSpan!,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            overflow: overflow,
            textScaler: textScaler,
            maxLines: maxLines,
            semanticsLabel: semanticsLabel,
            semanticsIdentifier: semanticsIdentifier,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior,
            selectionColor: selectionColor,
          );

    final directed = base.autoDirection();
    return autoAlign ? directed.autoAlign() : directed;
  }
}
