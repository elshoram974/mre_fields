import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'mre_pasted_image.dart';

/// Starts listening for images pasted into the page.
///
/// A browser handles Ctrl or Cmd + V itself, so Flutter never sees a paste
/// shortcut on the web. The browser fires a `paste` event instead, and its
/// `clipboardData` holds the image without any permission prompt.
///
/// Text on the clipboard always wins: the event is left alone, so the browser
/// pastes the text.
///
/// Returns a function that stops listening.
VoidCallback mreListenForPastedImages(ValueChanged<MREPastedImage> onImage) {
  void handle(web.Event event) {
    final data = (event as web.ClipboardEvent).clipboardData;
    if (data == null || data.getData('text/plain').isNotEmpty) {
      return;
    }

    final files = data.files;
    for (var i = 0; i < files.length; i++) {
      final file = files.item(i);
      if (file == null || !file.type.startsWith('image/')) {
        continue;
      }
      event.preventDefault();
      file.arrayBuffer().toDart.then((buffer) {
        onImage(
          MREPastedImage(
            bytes: buffer.toDart.asUint8List(),
            mimeType: file.type,
            name: file.name,
          ),
        );
      });
    }
  }

  final listener = handle.toJS;
  web.document.addEventListener('paste', listener);
  return () => web.document.removeEventListener('paste', listener);
}
