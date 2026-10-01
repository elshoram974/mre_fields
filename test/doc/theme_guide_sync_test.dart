import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Returns the code of region [name], formatted like dartdoc's `{@example}`:
/// shared indentation removed and `#hide` lines dropped.
String _region(List<String> lines, String name) {
  final start = lines.indexWhere((l) => l.contains('#region $name'));
  final end = lines.indexWhere((l) => l.contains('#endregion $name'));
  final body = lines
      .sublist(start + 1, end)
      .where((l) => !l.contains('#hide'))
      .toList();
  final indent = body
      .where((l) => l.trim().isNotEmpty)
      .map((l) => l.length - l.trimLeft().length)
      .reduce((a, b) => a < b ? a : b);
  return body
      .map((l) => l.length >= indent ? l.substring(indent) : l)
      .join('\n')
      .trimRight();
}

void main() {
  // doc/theme.md is a dartdoc category page, where {@example} is not
  // expanded, so its code blocks are copies. This test keeps them identical
  // to the compiled snippets.
  test('doc/theme.md code blocks match doc/snippets/theme.dart', () {
    final snippet = File('doc/snippets/theme.dart').readAsLinesSync();
    final guide = File('doc/theme.md').readAsStringSync();
    final regions = RegExp(
      r'#region (\w+)',
    ).allMatches(snippet.join('\n')).map((m) => m.group(1)!).toList();

    expect(regions, isNotEmpty);
    for (final name in regions) {
      expect(
        guide,
        contains(_region(snippet, name)),
        reason: 'doc/theme.md is out of date for region "$name"',
      );
    }
  });
}
