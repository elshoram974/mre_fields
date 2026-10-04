import 'package:flutter/widgets.dart';

import 'mre_bidi_data.dart';

/// Number of UTF-16 code units [detectTextDirection] reads before it gives up
/// and returns the fallback. Keeps the cost constant for very long text.
const int mreDirectionScanLimit = 256;

/// Returns the direction of the first strongly directional character in [text],
/// or null when there is none.
///
/// Uses Unicode 17.0.0 Bidi_Class for every writing system, including
/// supplementary planes. Weak/neutral characters and nonspacing marks
/// do not decide the direction. This detects direction, not language. Only
/// the first [mreDirectionScanLimit] code units are read.
///
/// {@category Text}
TextDirection? detectStrongTextDirection(String text) {
  final end = text.length < mreDirectionScanLimit
      ? text.length
      : mreDirectionScanLimit;

  var isolateDepth = 0;
  for (var i = 0; i < end; i++) {
    var rune = text.codeUnitAt(i);
    if (rune >= 0xD800 && rune <= 0xDBFF && i + 1 < end) {
      final low = text.codeUnitAt(i + 1);
      if (low >= 0xDC00 && low <= 0xDFFF) {
        rune = 0x10000 + ((rune - 0xD800) << 10) + low - 0xDC00;
        i++;
      }
    }
    // UAX #9 P2: isolated content does not decide the outer direction.
    if (rune >= 0x2066 && rune <= 0x2068) {
      isolateDepth++;
      continue;
    }
    if (rune == 0x2069) {
      if (isolateDepth > 0) isolateDepth--;
      continue;
    }
    if (isolateDepth > 0) continue;
    switch (mreStrongBidiClass(rune)) {
      case 1:
        return TextDirection.ltr;
      case 2:
        return TextDirection.rtl;
    }
  }
  return null;
}

/// Returns the direction of the first strongly directional character in [text].
///
/// Uses the first L, R or AL character outside isolates. Weak and neutral
/// characters are skipped. When [text] has no strong character within
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

/// Direction checks on [String].
///
/// {@category Text}
extension MRETextDirection on String {
  /// The direction of the first strong character, or [TextDirection.ltr] when
  /// there is none. Same as [detectTextDirection].
  TextDirection get textDirection => detectTextDirection(this);

  /// Whether the first strong character reads right to left.
  bool get isRtl => textDirection == TextDirection.rtl;

  /// The direction of the first strong character, or [fallback] when there is
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
