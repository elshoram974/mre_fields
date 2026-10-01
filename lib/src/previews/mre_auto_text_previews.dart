import 'package:flutter/material.dart';

import '../text/direction/mre_auto_text.dart';
import 'preview_harness.dart';

/// Arabic, English, mixed and digit-only text, each in its own direction.
@MREPreview()
Widget previewAutoText() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      MREAutoText('مرحبا بالعالم'),
      MREAutoText('Hello world'),
      MREAutoText('123 مرحبا'),
      MREAutoText('hello مرحبا'),
      MREAutoText('12345'),
      MREAutoText('مرحبا', textDirection: TextDirection.ltr),
      MREAutoText('مرحبا', autoAlign: true, style: TextStyle(fontSize: 20)),
      MREAutoText('Hello', autoAlign: true, style: TextStyle(fontSize: 20)),
    ],
  );
}
