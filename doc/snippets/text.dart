// Snippets embedded in the API docs and the text guide. They are analyzed and
// run in test/doc/text_snippets_test.dart, so each example is correct.
import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

/// Shows texts in two languages, each in its own direction.
Widget autoText() {
  // #region auto_text
  final column = Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: const [
      MREAutoText('مرحبا بالعالم'), // reads right to left
      MREAutoText('Hello world'), // reads left to right
      MREAutoText('مرحبا', textDirection: TextDirection.ltr), // fixed
    ],
  );
  // #endregion auto_text

  return column;
}

/// Styles an auto text like any [Text].
Widget styledAutoText() {
  // #region styled
  final text = MREAutoText(
    'مرحبا بالعالم',
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    autoAlign: true, // pins the text to the side its content starts on
  );
  // #endregion styled

  return text;
}

/// Adds direction and alignment to a [Text] that already exists.
Widget textExtension(String name) {
  // #region text_extension
  final text = Text(
    name,
    style: const TextStyle(fontSize: 20),
  ).autoDirection().autoAlign();
  // #endregion text_extension

  return text;
}

/// Reads the alignment of a string.
List<TextAlign> alignExamples() {
  // #region align_getter
  final arabic = 'مرحبا'.autoTextAlign; // TextAlign.right
  final english = 'Hello'.autoTextAlign; // TextAlign.left
  final digits = '12345'.autoTextAlign; // TextAlign.start
  // #endregion align_getter

  return [arabic, english, digits];
}

/// Detects the direction of four texts.
List<TextDirection> detectExamples() {
  // #region detect
  final arabic = detectTextDirection('مرحبا بالعالم'); // rtl
  final english = detectTextDirection('Hello'); // ltr
  final mixed = detectTextDirection('123 مرحبا'); // rtl, digits are skipped
  final symbols = detectTextDirection('(#1) مرحبا'); // rtl, symbols are skipped
  final none = detectTextDirection('12345', fallback: TextDirection.rtl); // rtl
  // #endregion detect

  return [arabic, english, mixed, symbols, none];
}

/// Reads the direction of a string with getters.
List<Object> extensionGetters() {
  // #region extension_getters
  final isRtl = 'مرحبا'.isRtl; // true
  final direction = '12345'.directionOr(TextDirection.rtl); // rtl
  // #endregion extension_getters

  return [isRtl, direction];
}

/// Gives a whole list tile the direction of the name it shows.
Widget nameTile(String name) {
  // #region with_text_direction
  final tile = ListTile(
    leading: const Icon(Icons.person),
    title: Text(name),
  ).withTextDirection(name);
  // #endregion with_text_direction

  return tile;
}

/// Shows pasted text that may hold broken characters.
Widget pastedLabel(String pasted) {
  // #region safe_text
  final label = Text(safeDisplayText(pasted));
  // #endregion safe_text

  return label;
}
