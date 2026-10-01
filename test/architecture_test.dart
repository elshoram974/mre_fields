// Fitness tests for the structure of lib/src: which folder may depend on which,
// what the public barrel exports, and how big a file may grow. They fail when a
// change breaks the layering the package relies on.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// For each folder, the folders (and itself) it may import from. A folder not
/// listed here, such as previews, may import anything.
const _allowed = <String, Set<String>>{
  'theme': {'theme'},
  'internal': {'internal'},
  'text/direction': {'text/direction', 'theme', 'internal'},
  'text/field': {
    'text/field',
    'text/direction',
    'theme',
    'internal',
    'attachments/model',
    'attachments/paste',
  },
  'attachments/model': {'attachments/model'},
  'attachments/paste': {
    'attachments/paste',
    'attachments/ui',
    'attachments/model',
    'theme',
    'internal',
  },
  'attachments/ui': {'attachments/ui', 'attachments/model', 'theme'},
};

/// Most lines of code (no blanks, no comments) in one file.
const _maxCodeLines = 350;

final _directive = RegExp(
  r'''^\s*(?:import|export)\s+'([^']+)'(?:\s+if\s*\([^)]*\)\s+'([^']+)')?''',
  multiLine: true,
);

List<File> _libFiles() => Directory('lib/src')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// The folder under lib/src that holds [path], such as `text/field`.
String _folderOf(String path) {
  final relative = p.relative(p.dirname(path), from: 'lib/src');
  return relative.replaceAll(r'\', '/');
}

/// Every lib/src file [file] imports or exports, resolved to a path.
Iterable<String> _localTargets(File file) sync* {
  for (final match in _directive.allMatches(file.readAsStringSync())) {
    for (final uri in [match.group(1), match.group(2)].whereType<String>()) {
      if (uri.startsWith('dart:') || uri.startsWith('package:')) {
        continue;
      }
      yield p.normalize(p.join(p.dirname(file.path), uri));
    }
  }
}

int _codeLines(File file) {
  return file
      .readAsLinesSync()
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith('//'))
      .length;
}

void main() {
  test('each folder imports only the folders it may', () {
    final violations = <String>[];
    for (final file in _libFiles()) {
      final folder = _folderOf(file.path);
      final allowed = _allowed[folder];
      if (allowed == null) {
        continue;
      }
      for (final target in _localTargets(file)) {
        final targetFolder = _folderOf(target);
        if (!allowed.contains(targetFolder)) {
          violations.add(
            '${file.path} imports $target ($folder may not use $targetFolder)',
          );
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('no library file imports the package by name', () {
    final violations = [
      for (final file in _libFiles())
        if (file.readAsStringSync().contains("package:mre_fields/")) file.path,
    ];
    expect(
      violations,
      isEmpty,
      reason: 'use relative imports inside lib: $violations',
    );
  });

  test('nothing outside previews imports a preview file', () {
    final violations = [
      for (final file in _libFiles())
        if (!file.path.contains('/previews/'))
          for (final target in _localTargets(file))
            if (target.contains('/previews/')) '${file.path} -> $target',
    ];
    expect(violations, isEmpty);
  });

  group('the public barrel', () {
    final barrel = File('lib/mre_fields.dart').readAsStringSync();
    final exported = RegExp(r"export '([^']+)'")
        .allMatches(barrel)
        .map((m) => p.normalize(p.join('lib', m.group(1)!)))
        .toList();

    test('exports files that exist', () {
      expect(exported, isNotEmpty);
      for (final path in exported) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });

    test('exports no file that holds an @internal declaration', () {
      final leaked = [
        for (final path in exported)
          if (File(path).readAsStringSync().contains('@internal')) path,
      ];
      expect(
        leaked,
        isEmpty,
        reason: 'internal code in the public API: $leaked',
      );
    });

    test('exports nothing from internal or previews', () {
      final leaked = exported.where(
        (e) => e.contains('/internal/') || e.contains('/previews/'),
      );
      expect(leaked, isEmpty);
    });

    test('exports every file that declares a public MRE type or function', () {
      final internal = <String>{
        for (final file in _libFiles())
          if (file.readAsStringSync().contains('@internal') ||
              file.path.contains('/internal/') ||
              file.path.contains('/previews/') ||
              file.path.contains('paste_events_'))
            file.path,
      };
      final missing = [
        for (final file in _libFiles())
          if (!internal.contains(file.path) && !exported.contains(file.path))
            file.path,
      ];
      expect(
        missing,
        isEmpty,
        reason: 'public files missing from the barrel: $missing',
      );
    });
  });

  test('every file stays under $_maxCodeLines lines of code', () {
    final tooBig = {
      for (final file in _libFiles())
        if (_codeLines(file) > _maxCodeLines) file.path: _codeLines(file),
    };
    expect(
      tooBig,
      isEmpty,
      reason: 'split these files by responsibility: $tooBig',
    );
  });
}
