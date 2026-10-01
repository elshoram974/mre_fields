import 'package:flutter/widgets.dart';

import 'paste_demo.dart';
import 'phone_demo.dart';
import 'text_demo.dart';

/// Returns the clean demo page named in the URL, such as `?demo=text`, or null.
///
/// The demo pages are the ones recorded for the package documentation. On
/// platforms without a URL query this is always null.
Widget? demoPageFromUrl() {
  return switch (Uri.base.queryParameters['demo']) {
    'text' => const TextDemo(),
    'paste' => const PasteDemo(),
    'phone' => const PhoneDemo(),
    _ => null,
  };
}
