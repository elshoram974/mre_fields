import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'preview_harness.dart';

/// Placeholder until [MRETextField] is ported — proves Widget Previewer works.
@Preview(
  name: 'Harness / light',
  group: 'mre_fields',
  brightness: Brightness.light,
)
Widget previewHarnessLight() {
  return mreFieldsPreviewScaffold(
    const TextField(
      decoration: InputDecoration(
        labelText: 'Preview harness',
        hintText: 'Replace with MRETextField',
        border: OutlineInputBorder(),
      ),
    ),
  );
}

/// Dark counterpart of [previewHarnessLight].
@Preview(
  name: 'Harness / dark',
  group: 'mre_fields',
  brightness: Brightness.dark,
)
Widget previewHarnessDark() {
  return mreFieldsPreviewScaffold(
    const TextField(
      decoration: InputDecoration(
        labelText: 'Preview harness',
        hintText: 'Replace with MRETextField',
        border: OutlineInputBorder(),
      ),
    ),
  );
}
