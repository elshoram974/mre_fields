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
