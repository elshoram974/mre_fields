import 'package:flutter/widgets.dart';

import 'text_direction.dart';

/// A [TextEditingController] that cannot crash the text layout.
///
/// Some Android keyboards and pastes produce unpaired UTF-16 surrogates or a
/// composing range that cuts a surrogate pair. Flutter throws on both. This
/// controller replaces unpaired surrogates with U+FFFD as the text is set, and
/// drops a composing range that is not safe to draw.
///
/// [MRETextField] uses it when you pass no controller. Pass it yourself to keep
/// the same protection with your own controller.
///
/// {@category Fields}
class MRESafeTextEditingController extends TextEditingController {
  /// Creates a controller with the optional initial [text].
  MRESafeTextEditingController({String? text})
    : super(text: text == null ? null : safeDisplayText(text));

  @override
  set value(TextEditingValue newValue) {
    final safeText = safeDisplayText(newValue.text);
    if (safeText == newValue.text) {
      super.value = newValue;
      return;
    }

    // Unpaired surrogates collapse to one character each, so the text can get
    // shorter. Keep the selection inside it.
    final max = safeText.length;
    TextSelection clamp(TextSelection selection) {
      return TextSelection(
        baseOffset: selection.baseOffset.clamp(0, max),
        extentOffset: selection.extentOffset.clamp(0, max),
      );
    }

    super.value = TextEditingValue(
      text: safeText,
      selection: clamp(newValue.selection),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return super.buildTextSpan(
      context: context,
      style: style,
      withComposing: withComposing && _isComposingSafe(value),
    );
  }

  bool _isComposingSafe(TextEditingValue value) {
    final composing = value.composing;
    if (!composing.isValid || composing.isCollapsed) {
      return true;
    }
    final text = value.text;
    if (composing.start < 0 || composing.end > text.length) {
      return false;
    }
    return !_splitsPair(text, composing.start) &&
        !_splitsPair(text, composing.end);
  }

  /// Whether [offset] falls between the two halves of a surrogate pair.
  bool _splitsPair(String text, int offset) {
    if (offset <= 0 || offset >= text.length) {
      return false;
    }
    final before = text.codeUnitAt(offset - 1);
    final after = text.codeUnitAt(offset);
    return before >= 0xD800 &&
        before <= 0xDBFF &&
        after >= 0xDC00 &&
        after <= 0xDFFF;
  }
}
