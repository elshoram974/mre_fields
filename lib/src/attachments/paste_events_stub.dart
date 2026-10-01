import 'package:flutter/foundation.dart';

import 'mre_pasted_image.dart';

/// Starts listening for images pasted into the page. Only the web has such an
/// event; everywhere else this does nothing.
///
/// Returns a function that stops listening.
VoidCallback mreListenForPastedImages(ValueChanged<MREPastedImage> onImage) {
  return () {};
}
