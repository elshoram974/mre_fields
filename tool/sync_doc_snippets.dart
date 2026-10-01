// Copies the compiled snippets in doc/snippets/<topic>.dart into the code
// blocks of the guides, the README and the example page.
//
// Dartdoc does not expand {@example} inside markdown files, so those files hold
// copies. Mark each block with a comment on the line above it:
//
//   <!-- snippet: region -->          region of the guide's own topic file
//   <!-- snippet: topic/region -->    region of doc/snippets/<topic>.dart
//
// Then run:
//
//   dart run tool/sync_doc_snippets.dart          rewrite the files
//   dart run tool/sync_doc_snippets.dart --check  fail when a file is stale
import 'dart:io';

/// Markdown files that carry snippet blocks, with the topic their unqualified
/// markers use. A null topic means every marker must name its topic.
const syncedFiles = <String, String?>{
  'doc/theme.md': 'theme',
  'doc/text.md': 'text',
  'doc/text_field.md': 'text_field',
  'doc/attachments.md': 'attachments',
  'doc/functions.md': 'functions',
  'README.md': null,
  'example/example.md': null,
};

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

/// Returns the text of doc/snippets/[topic].dart.
String snippetSource(String topic) {
  return File('doc/snippets/$topic.dart').readAsStringSync();
}

/// Returns [markdown] with every marked code block replaced by its region.
///
/// [defaultTopic] resolves markers without a topic. [source] returns the text
/// of a snippet file, and defaults to reading it from disk.
String syncMarkdown(
  String markdown, {
  required String? defaultTopic,
  String Function(String topic) source = snippetSource,
}) {
  final block = RegExp(
    r'<!-- snippet: ([\w]+(?:/[\w]+)?) -->\n```dart\n.*?```',
    dotAll: true,
  );
  return markdown.replaceAllMapped(block, (m) {
    final marker = m[1]!;
    final parts = marker.split('/');
    final topic = parts.length == 2 ? parts[0] : defaultTopic;
    if (topic == null) {
      throw StateError('Marker "$marker" needs a topic: topic/region.');
    }
    final code = regionOf(source(topic), parts.last);
    return '<!-- snippet: $marker -->\n```dart\n$code\n```';
  });
}

void main(List<String> args) {
  final check = args.contains('--check');
  var stale = false;

  for (final MapEntry(key: path, value: topic) in syncedFiles.entries) {
    final file = File(path);
    final text = file.readAsStringSync();
    final synced = syncMarkdown(text, defaultTopic: topic);

    if (synced == text) {
      continue;
    }
    if (check) {
      stderr.writeln('$path is out of date.');
      stale = true;
    } else {
      file.writeAsStringSync(synced);
      stdout.writeln('Updated $path');
    }
  }

  if (stale) {
    exitCode = 1;
  }
}
