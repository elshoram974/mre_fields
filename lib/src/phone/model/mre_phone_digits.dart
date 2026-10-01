import 'package:flutter/services.dart';

/// Returns [input] reduced to what a phone number can hold: ASCII digits and a
/// plus at the very start.
///
/// Arabic-Indic (٠١٢٣), Persian (۰۱۲۳) and full-width (０１２３) digits become
/// ASCII digits. Spaces, dashes, brackets and dots are dropped, so a number
/// pasted as `+20 (10) 1234-5678` becomes `+201012345678`.
String mreNormalizePhoneInput(String input) {
  final out = StringBuffer();
  final trimmed = input.trimLeft();

  for (var i = 0; i < trimmed.length; i++) {
    final unit = trimmed.codeUnitAt(i);
    final digit = _asciiDigit(unit);
    if (digit != null) {
      out.writeCharCode(digit);
    } else if (unit == 0x2B && out.isEmpty) {
      out.write('+');
    }
  }
  return out.toString();
}

/// The ASCII code of the digit [unit] stands for, or null when it is no digit.
int? _asciiDigit(int unit) {
  if (unit >= 0x30 && unit <= 0x39) {
    return unit;
  }
  if (unit >= 0x0660 && unit <= 0x0669) {
    return 0x30 + unit - 0x0660;
  }
  if (unit >= 0x06F0 && unit <= 0x06F9) {
    return 0x30 + unit - 0x06F0;
  }
  if (unit >= 0xFF10 && unit <= 0xFF19) {
    return 0x30 + unit - 0xFF10;
  }
  return null;
}

/// Keeps a phone field to digits and a leading plus, whatever is typed or
/// pasted. See [mreNormalizePhoneInput].
///
/// {@category Phone}
class MREPhoneInputFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const MREPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = mreNormalizePhoneInput(newValue.text);
    if (text == newValue.text) {
      return newValue;
    }

    final cursor = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );
    final before = mreNormalizePhoneInput(newValue.text.substring(0, cursor));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: before.length),
    );
  }
}
