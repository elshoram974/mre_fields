import 'package:flutter/widgets.dart';

/// Number of UTF-16 code units [detectTextDirection] reads before it gives up
/// and returns the fallback. Keeps the cost constant for very long text.
const int mreDirectionScanLimit = 256;

/// Returns the direction of the first strongly directional letter in [text],
/// or null when there is none.
///
/// Letters decide the direction. Digits, spaces, punctuation and emoji are
/// skipped, so the answer comes from the first word that has a letter. Only
/// the first [mreDirectionScanLimit] code units are read.
///
/// {@category Text}
TextDirection? detectStrongTextDirection(String text) {
  final end = text.length < mreDirectionScanLimit
      ? text.length
      : mreDirectionScanLimit;

  for (var i = 0; i < end; i++) {
    final unit = text.codeUnitAt(i);
    if (_isStrongRtl(unit)) {
      return TextDirection.rtl;
    }
    if (_isStrongLtr(unit)) {
      return TextDirection.ltr;
    }
  }
  return null;
}

/// Returns the direction of the first strongly directional letter in [text].
///
/// The first word that has a letter decides, not the whole text and not a
/// leading number or symbol. When [text] has no such letter within
/// [mreDirectionScanLimit] code units, [fallback] is returned.
///
/// {@example /doc/snippets/text.dart#detect}
///
/// See also:
///
///  * [detectStrongTextDirection], which returns null instead of a fallback.
///  * [MRETextDirection], the same check as getters on [String].
///
/// {@category Text}
TextDirection detectTextDirection(
  String text, {
  TextDirection fallback = TextDirection.ltr,
}) {
  return detectStrongTextDirection(text) ?? fallback;
}

// Ranges follow the Closure/intl heuristic, with the Arabic-Indic digits and
// the emoji planes treated as neutral.
bool _isStrongRtl(int unit) {
  return (unit >= 0x0591 &&
          unit <= 0x06EF &&
          !(unit >= 0x0660 && unit <= 0x0669)) ||
      (unit >= 0x06FA && unit <= 0x08FF) ||
      unit == 0x200F ||
      unit == 0x202B ||
      unit == 0x202E ||
      (unit >= 0xFB1D && unit <= 0xFDFF) ||
      (unit >= 0xFE70 && unit <= 0xFEFC) ||
      (unit >= 0xD802 && unit <= 0xD803) ||
      (unit >= 0xD83A && unit <= 0xD83B);
}

bool _isStrongLtr(int unit) {
  return (unit >= 0x41 && unit <= 0x5A) ||
      (unit >= 0x61 && unit <= 0x7A) ||
      (unit >= 0xC0 && unit <= 0xD6) ||
      (unit >= 0xD8 && unit <= 0xF6) ||
      (unit >= 0xF8 && unit <= 0x2B8) ||
      (unit >= 0x300 && unit <= 0x590) ||
      (unit >= 0x900 && unit <= 0x1FFF) ||
      unit == 0x200E ||
      (unit >= 0x2C00 && unit <= 0xD801) ||
      (unit >= 0xD804 && unit <= 0xD839) ||
      (unit >= 0xD840 && unit <= 0xDBFF) ||
      (unit >= 0xF900 && unit <= 0xFB1C) ||
      (unit >= 0xFE00 && unit <= 0xFE6F) ||
      (unit >= 0xFEFD && unit <= 0xFFFF);
}

/// Direction checks on [String].
///
/// {@category Text}
extension MRETextDirection on String {
  /// The direction of the first strong letter, or [TextDirection.ltr] when
  /// there is none. Same as [detectTextDirection].
  TextDirection get textDirection => detectTextDirection(this);

  /// Whether the first strong letter reads right to left.
  bool get isRtl => textDirection == TextDirection.rtl;

  /// The direction of the first strong letter, or [fallback] when there is
  /// none.
  TextDirection directionOr(TextDirection fallback) {
    return detectTextDirection(this, fallback: fallback);
  }

  /// The side the text starts on: [TextAlign.right] for right to left text,
  /// [TextAlign.left] for left to right text, and [TextAlign.start] when
  /// there is no strong letter.
  ///
  /// Unlike [TextAlign.start], this does not depend on the surrounding
  /// direction. Use it where only a [TextAlign] can be given.
  TextAlign get autoTextAlign {
    return switch (detectStrongTextDirection(this)) {
      TextDirection.rtl => TextAlign.right,
      TextDirection.ltr => TextAlign.left,
      null => TextAlign.start,
    };
  }
}

/// Returns [text] without unpaired UTF-16 surrogates.
///
/// Some keyboards, pastes and imports produce them, and Flutter's paragraph
/// builder throws "string is not well-formed UTF-16" on them. Each unpaired
/// surrogate becomes U+FFFD; valid pairs, such as emoji, stay.
///
/// {@example /doc/snippets/text.dart#safe_text}
///
/// {@category Text}
String safeDisplayText(String text) {
  if (text.isEmpty || _isWellFormed(text)) {
    return text;
  }

  final out = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final unit = text.codeUnitAt(i);
    if (_isHighSurrogate(unit)) {
      if (i + 1 < text.length && _isLowSurrogate(text.codeUnitAt(i + 1))) {
        out
          ..writeCharCode(unit)
          ..writeCharCode(text.codeUnitAt(i + 1));
        i++;
      } else {
        out.writeCharCode(0xFFFD);
      }
    } else if (_isLowSurrogate(unit)) {
      out.writeCharCode(0xFFFD);
    } else {
      out.writeCharCode(unit);
    }
  }
  return out.toString();
}

bool _isHighSurrogate(int unit) => unit >= 0xD800 && unit <= 0xDBFF;

bool _isLowSurrogate(int unit) => unit >= 0xDC00 && unit <= 0xDFFF;

bool _isWellFormed(String text) {
  for (var i = 0; i < text.length; i++) {
    final unit = text.codeUnitAt(i);
    if (_isHighSurrogate(unit)) {
      if (i + 1 >= text.length || !_isLowSurrogate(text.codeUnitAt(i + 1))) {
        return false;
      }
      i++;
    } else if (_isLowSurrogate(unit)) {
      return false;
    }
  }
  return true;
}

/// Gives a widget the direction of a sample text.
///
/// {@category Text}
extension MREDirectionalWidget on Widget {
  /// Wraps this widget in a [Directionality] that follows [sample].
  ///
  /// No wrapper is added when the direction already matches the surrounding
  /// one. Text without a strong letter keeps the surrounding direction.
  ///
  /// {@example /doc/snippets/text.dart#with_text_direction}
  Widget withTextDirection(String sample) {
    return Builder(
      builder: (context) {
        final ambient = Directionality.of(context);
        final direction = detectTextDirection(sample, fallback: ambient);
        if (direction == ambient) {
          return this;
        }
        return Directionality(textDirection: direction, child: this);
      },
    );
  }
}
