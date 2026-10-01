// Copies the compiled snippets in doc/snippets/<topic>.dart into the code
// blocks of doc/<topic>.md.
//
// Dartdoc does not expand {@example} inside guides, so the guides hold copies.
// Mark each block with `<!-- snippet: name -->` on the line above it, then run:
//
//   dart run tool/sync_doc_snippets.dart          rewrite the guides
//   dart run tool/sync_doc_snippets.dart --check  fail when a guide is stale
import 'dart:io';

/// Guides that carry snippet blocks.
const guideTopics = ['theme', 'text', 'text_field', 'attachments'];

/// Returns region [name] of [source], formatted like dartdoc's `{@example}`:
/// shared indentation removed and `#hide` lines dropped.
String regionOf(String source, String name) {
  final lines = source.split('\n');
  final start = lines.indexWhere((l) => l.contains('#region $name'));
  final end = lines.indexWhere((l) => l.contains('#endregion $name'));
  if (start == -1 || end == -1) {
    throw StateError('Region "$name" not found.');
  }

  final body = lines
      .sublist(start + 1, end)
      .where((l) => !l.contains('#hide'))
      .toList();
  final indent = body
      .where((l) => l.trim().isNotEmpty)
      .map((l) => l.length - l.trimLeft().length)
      .reduce((a, b) => a < b ? a : b);

  return body
      .map((l) => l.length >= indent ? l.substring(indent) : l.trimLeft())
      .join('\n')
      .trimRight();
}

/// Returns [guide] with every marked code block replaced by its region from
/// [snippets].
String syncGuide(String snippets, String guide) {
  final block = RegExp(
    r'<!-- snippet: (\w+) -->\n```dart\n.*?```',
    dotAll: true,
  );
  return guide.replaceAllMapped(block, (m) {
    final code = regionOf(snippets, m[1]!);
    return '<!-- snippet: ${m[1]} -->\n```dart\n$code\n```';
  });
}

void main(List<String> args) {
  final check = args.contains('--check');
  var stale = false;

  for (final topic in guideTopics) {
    final snippets = File('doc/snippets/$topic.dart').readAsStringSync();
    final guideFile = File('doc/$topic.md');
    final guide = guideFile.readAsStringSync();
    final synced = syncGuide(snippets, guide);

    if (synced == guide) {
      continue;
    }
    if (check) {
      stderr.writeln('doc/$topic.md is out of date.');
      stale = true;
    } else {
      guideFile.writeAsStringSync(synced);
      stdout.writeln('Updated doc/$topic.md');
    }
  }

  if (stale) {
    exitCode = 1;
  }
}
