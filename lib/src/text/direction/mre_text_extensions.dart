import 'package:flutter/widgets.dart';

import 'text_direction.dart';

/// Direction and alignment from content, on an existing [Text].
///
/// Both methods return a copy that keeps every other property, including the
/// key, the style and the spans of [Text.rich]. A value you set yourself is
/// never replaced.
///
/// {@example /doc/snippets/text.dart#text_extension}
///
/// See also [MREAutoText], the widget version.
///
/// {@category Text}
extension MREAutoDirectionText on Text {
  /// Sets [Text.textDirection] from the content.
  ///
  /// Returns this [Text] when a direction is already set or the content has no
  /// strong letter.
  Text autoDirection() {
    if (textDirection != null) {
      return this;
    }
    final direction = detectStrongTextDirection(_plainText);
    return direction == null ? this : _copy(textDirection: direction);
  }

  /// Sets [Text.textAlign] to the side the content starts on.
  ///
  /// Arabic text aligns right and English text aligns left, whatever the
  /// surrounding direction is. Returns this [Text] when an alignment is already
  /// set or the content has no strong letter.
  Text autoAlign() {
    if (textAlign != null) {
      return this;
    }
    final align = _plainText.autoTextAlign;
    return align == TextAlign.start ? this : _copy(textAlign: align);
  }

  String get _plainText {
    return data ?? textSpan!.toPlainText(includeSemanticsLabels: false);
  }

  Text _copy({TextDirection? textDirection, TextAlign? textAlign}) {
    final text = data;
    final direction = textDirection ?? this.textDirection;
    final align = textAlign ?? this.textAlign;

    if (text != null) {
      return Text(
        text,
        key: key,
        style: style,
        strutStyle: strutStyle,
        textAlign: align,
        textDirection: direction,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        // ignore: deprecated_member_use
        textScaleFactor: textScaleFactor,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        semanticsIdentifier: semanticsIdentifier,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return Text.rich(
      textSpan!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: align,
      textDirection: direction,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      // ignore: deprecated_member_use
      textScaleFactor: textScaleFactor,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
