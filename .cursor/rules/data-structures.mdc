---
description: Data structures — choosing collections and value types, immutability, complexity on hot paths
globs: "lib/**/*.dart"
alwaysApply: true
---
# Data structures (ALWAYS)

## Pick by the operation you do most

| Need | Use | Cost |
|---|---|---|
| Ordered items, index access, append | `List` | O(1) index and append |
| "Is it in there?" on more than ~20 items, no duplicates | `Set` | O(1) `contains` |
| Look up by key | `Map` | O(1) |
| Queue (add at the end, take from the front) | `ListQueue` | O(1) both ends; `list.removeAt(0)` is O(n) |
| Sorted by key with range queries | `SplayTreeMap` / `SplayTreeSet` | O(log n) |
| A fixed small group of named values | record `({A a, B b})` | no allocation of a class, structural `==` |
| One of several shapes | `sealed class` + exhaustive `switch` | compiler checks every case |
| A closed list of names | `enum` | |

- `List.contains` is O(n). Inside a loop it makes the loop O(n²): build a `Set` first.
- Never call `insert(0, x)` or `removeAt(0)` in a loop.
- Do not copy a collection to hand out a read-only view. Return `UnmodifiableListView(list)` (O(1)), as `MREAttachmentsController.images` does. Copy once with `List.of` only when a caller needs a snapshot.
- Lazy `Iterable`s (`map`, `where`) rerun on every pass. Call `.toList()` once when you will iterate twice.
- Stop early: search loops return at the first hit and respect a limit (`mreFilterSuggestions(limit:)`, the 256-unit scan in `detectStrongTextDirection`).

## Immutable values

- A value type has `final` fields, a `const` constructor, and value equality (`==` and `hashCode`) when it is compared or used as a key. Use a record when two fields are all it is.
- Never expose a mutable list a caller could change. Public lists are unmodifiable views or `const`.
- A `const` constructor and `const` default values cost nothing at runtime; use them everywhere (`const MREFieldsStrings()`, `const MRENoImagePaste()`).
- Mutable state has one owner. `ChangeNotifier`s a widget created are disposed by that widget; given ones are not (`MREOwned`).

## Hot paths (per keystroke, per frame)

- Do O(1) or O(k) work with small constant k. Read the first characters, not the whole text.
- Keep derived state small and comparable (`MRETextFieldFlags` record) so a `ValueNotifier` skips notifications when nothing changed.
- Decode images at thumbnail size (`cacheWidth`); build long lists lazily (`ListView.builder`).

## Before you add a collection field

1. Who owns it, and who may change it?
2. What is the most frequent operation, and what does it cost?
3. Could a `Set`, `Map`, record or enum say it better than a `List` and a convention?
