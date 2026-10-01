import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';
import 'package:mre_fields/src/previews/mre_attachments_previews.dart';
import 'package:mre_fields/src/previews/mre_auto_text_previews.dart';
import 'package:mre_fields/src/previews/mre_text_field_previews.dart';
import 'package:mre_fields/src/previews/preview_harness.dart';

/// Builds [preview] the way the previewer does: its brightness, size, text
/// scale and wrapper around the widget under test.
///
/// A preview without a size gets unbounded width, as in the previewer, where a
/// card sizes itself to its content.
Widget _build(Preview preview, Widget widget) {
  final brightness = preview.brightness ?? Brightness.light;
  final size = preview.size;
  final wrapped = preview.wrapper?.call(widget) ?? widget;
  final card = size != null && size.width.isFinite
      ? SizedBox(width: size.width, child: wrapped)
      : SingleChildScrollView(scrollDirection: Axis.horizontal, child: wrapped);

  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        platformBrightness: brightness,
        textScaler: TextScaler.linear(preview.textScaleFactor ?? 1),
      ),
      child: Scaffold(body: card),
    ),
  );
}

void main() {
  final previews = const MREPreview().transform();

  test('MREPreview makes the six documented cards', () {
    expect(previews.map((p) => p.name), [
      'Light',
      'Dark',
      'RTL',
      'Text scale 1.3',
      'Narrow 390',
      'Wide 1024',
    ]);
  });

  // Every preview function, with a text that must be on screen.
  final functions = <String, (Widget Function(), String)>{
    'previewAutoText': (previewAutoText, 'Hello world'),
    'previewTextFieldEmpty': (previewTextFieldEmpty, 'Name'),
    'previewTextFieldEnglish': (previewTextFieldEnglish, 'Mohamed Ali'),
    'previewTextFieldArabic': (previewTextFieldArabic, 'محمد علي'),
    'previewTextFieldSuggestions': (previewTextFieldSuggestions, 'Cairo'),
    'previewTextFieldError': (previewTextFieldError, 'Enter a valid email'),
    'previewTextFieldMultiline': (previewTextFieldMultiline, 'Notes'),
    'previewTextFieldStates': (previewTextFieldStates, 'Read only'),
    'previewImagePasteAttachments': (previewImagePasteAttachments, 'Message'),
    'previewImagePasteCallback': (previewImagePasteCallback, 'Message'),
  };

  for (final MapEntry(key: name, value: (build, expected))
      in functions.entries) {
    for (final preview in previews) {
      testWidgets('$name renders in "${preview.name}"', (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_build(preview, build()));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text(expected), findsWidgets);

        final theme = Theme.of(tester.element(find.text(expected).first));
        expect(
          theme.brightness,
          preview.brightness ?? Brightness.light,
          reason: 'the previewer sets brightness through MediaQuery',
        );
        expect(theme.extension<MREFieldsTheme>(), isNotNull);
      });
    }
  }
}
