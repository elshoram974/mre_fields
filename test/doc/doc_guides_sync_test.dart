import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/sync_doc_snippets.dart';

void main() {
  // The guides, the README and the example page hold copies of the compiled
  // snippets. Run `dart run tool/sync_doc_snippets.dart` when this test fails.
  for (final MapEntry(key: path, value: topic) in syncedFiles.entries) {
    test('$path matches doc/snippets', () {
      final text = File(path).readAsStringSync();

      expect(syncMarkdown(text, defaultTopic: topic), text);
    });
  }

  test('an unqualified marker without a default topic is an error', () {
    expect(
      () => syncMarkdown(
        '<!-- snippet: basic -->\n```dart\n```',
        defaultTopic: null,
      ),
      throwsStateError,
    );
  });

  test('a qualified marker reads the named topic', () {
    const source = '// #region one\nfinal a = 1;\n// #endregion one\n';

    final result = syncMarkdown(
      '<!-- snippet: demo/one -->\n```dart\nstale\n```',
      defaultTopic: null,
      source: (topic) => topic == 'demo' ? source : throw StateError(topic),
    );

    expect(result, '<!-- snippet: demo/one -->\n```dart\nfinal a = 1;\n```');
  });
}
