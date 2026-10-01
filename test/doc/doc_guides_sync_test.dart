import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/sync_doc_snippets.dart';

void main() {
  // Guides in doc/*.md hold copies of the compiled snippets. Run
  // `dart run tool/sync_doc_snippets.dart` when this test fails.
  for (final topic in guideTopics) {
    test('doc/$topic.md matches doc/snippets/$topic.dart', () {
      final snippets = File('doc/snippets/$topic.dart').readAsStringSync();
      final guide = File('doc/$topic.md').readAsStringSync();

      expect(syncGuide(snippets, guide), guide);
    });
  }
}
