@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';
import 'package:mre_fields/src/attachments/paste/paste_events_web.dart';
import 'package:web/web.dart' as web;

import '../../../support/images.dart';

/// Fires a `paste` event like the browser does, with [text] and an image file.
web.ClipboardEvent _firePaste({String? text, bool withImage = true}) {
  final data = web.DataTransfer();
  if (text != null) {
    data.setData('text/plain', text);
  }
  if (withImage) {
    final file = web.File(
      [pngBytes.toJS].toJS,
      'pasted.png',
      web.FilePropertyBag(type: 'image/png'),
    );
    data.items.add(file);
  }
  final event = web.ClipboardEvent(
    'paste',
    web.ClipboardEventInit(
      clipboardData: data,
      bubbles: true,
      cancelable: true,
    ),
  );
  web.document.body!.dispatchEvent(event);
  return event;
}

void main() {
  test(
    'an image in the paste event reaches the listener and the browser default is stopped',
    () async {
      final received = Completer<MREPastedImage>();
      final stop = mreListenForPastedImages(received.complete);
      addTearDown(stop);

      final event = _firePaste();

      final image = await received.future.timeout(const Duration(seconds: 5));
      expect(image.mimeType, 'image/png');
      expect(image.name, 'pasted.png');
      expect(image.bytes, pngBytes);
      expect(event.defaultPrevented, isTrue);
    },
  );

  test('text on the clipboard wins: the event is left alone', () async {
    final received = <MREPastedImage>[];
    final stop = mreListenForPastedImages(received.add);
    addTearDown(stop);

    final event = _firePaste(text: 'hello');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(received, isEmpty);
    expect(event.defaultPrevented, isFalse);
  });

  test('a paste without files does nothing', () async {
    final received = <MREPastedImage>[];
    final stop = mreListenForPastedImages(received.add);
    addTearDown(stop);

    _firePaste(withImage: false);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(received, isEmpty);
  });

  test('stopping drops a file read already in flight', () async {
    final received = <MREPastedImage>[];
    final stop = mreListenForPastedImages(received.add);
    _firePaste();
    stop();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(received, isEmpty);
  });

  test('stopping removes the listener', () async {
    final received = <MREPastedImage>[];
    final stop = mreListenForPastedImages(received.add);
    stop();

    _firePaste();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(received, isEmpty);
  });
}
