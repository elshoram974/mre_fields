// Snippets embedded in the functions guide. They are analyzed and run in
// test/doc/functions_snippets_test.dart, so each example is correct.
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:mre_fields/mre_fields.dart';

/// Picks the side to align a name on in a report, without any widget.
TextAlign reportAlignment(String name) {
  // #region direction_functions
  final direction = detectTextDirection(name, fallback: TextDirection.ltr);
  final strong = detectStrongTextDirection(name); // null when no letter
  final side = name.autoTextAlign;
  // #endregion direction_functions

  return strong == null
      ? TextAlign.start
      : (direction == TextDirection.rtl ? TextAlign.right : side);
}

/// Cleans text from a keyboard or an import before it reaches the screen.
String cleanForDisplay(String pasted) {
  // #region sanitize
  final clean = safeDisplayText(pasted); // lone surrogates become U+FFFD
  // #endregion sanitize

  return clean;
}

/// Finds the cities that match what the user typed.
List<String> matchingCities(String query) {
  // #region filter
  const cities = ['Cairo', 'Alexandria', 'Giza', 'Luxor', 'Aswan'];
  final matches = mreFilterSuggestions(cities, query, limit: 3);
  // #endregion filter

  return matches;
}

/// Checks that an upload really is an image, from its first bytes.
bool isPng(Uint8List upload) {
  // #region sniff
  final type = mreSniffImageMimeType(
    upload,
  ); // 'image/png', 'image/jpeg', ... or null
  final isPng = type == 'image/png';
  // #endregion sniff

  return isPng;
}

/// Keeps pasted images in a view model, with no widget.
MREAttachmentsController collectImages(List<MREPastedImage> pasted) {
  // #region collect
  final controller = MREAttachmentsController();
  for (final image in pasted) {
    controller.add(image);
  }
  controller.addListener(() {
    // Runs on every add, remove and replace.
  });
  // #endregion collect

  return controller;
}

/// Reads the direction of a string with getters.
bool startsRightToLeft(String text) {
  // #region getters
  final rtl = text.isRtl;
  final fallback = text.directionOr(TextDirection.ltr);
  // #endregion getters

  return rtl && fallback == TextDirection.rtl;
}
