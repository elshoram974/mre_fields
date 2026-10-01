---
description: Clean code for this Dart package — naming, small functions, no magic numbers, errors, comments
globs: "lib/**/*.dart,test/**/*.dart"
alwaysApply: true
---
# Clean code (ALWAYS)

Adapted from the third-party `clean-principles` rules (see `clean-principles-core.mdc`) to Dart and Flutter. Where they disagree, this file wins.

## Names

- Say what a thing is or does: `readClipboardImage`, `MRETextFieldFlagsTracker`. No `data`, `info`, `helper`, `manager`, `util`.
- Functions are verbs, classes are nouns, booleans read as questions (`hasText`, `acceptsImages`, `isCreated`).
- No abbreviations except `id`, `url`, `rtl`, `ltr`, `ui`.

## Functions and methods

- One job. A `build` method that needs a comment per section wants splitting into private widgets (`StatelessWidget`), not `Widget _buildX()` helpers that hide rebuild scope.
- Named parameters. A widget mirroring a Flutter widget may take many (`MRETextField` mirrors `TextFormField`); a plain function takes at most four, then a parameter object or record.
- No flag arguments that change what a function does. Two functions, or a typed option.
- Return early, keep nesting at three levels or fewer.
- Queries return values, commands return `void`. A method that does both gets split.

## Values

- No magic numbers or strings. A number gets a named `const` next to its use, or a token on `MREFieldsTheme`.
- No `null` for "nothing" in a collection result: return an empty list.
- Prefer records and sealed types for small immutable results over classes with hand-written `==`.

## Errors

- No `catch (_) {}`. Catch the specific exception the code can handle (`PlatformException`, `MissingPluginException`), turn it into a value or a reported reason, let everything else propagate.
- A failure that a caller must know about is part of the return type or a callback (`onImageRejected`), not a log line.
- No `print`. No `debugPrint` in `lib/`.

## Comments and docs

- Comments say **why**, never what. If a comment restates the code, delete it or rename the code.
- Every public member has `///` (lint `public_member_api_docs`). Internal members get a `///` when the reason is not obvious.
- No commented-out code, no `TODO` without a plan in `ROADMAP.md`.

## Tidy as you go

Leave the code you touch cleaner: delete dead code, drop unused imports and parameters, name the number you walked past. Report deleted behaviour under **⚠️ Removed**.

## Before you say done

`flutter analyze`, `flutter test`, `dart doc .` with 0 warnings, `dart run tool/sync_doc_snippets.dart --check`.
