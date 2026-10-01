---
description: Performance budget for field widgets — rebuild scope, listeners, no state-management package
globs: "lib/**/*.dart"
alwaysApply: true
---
# Performance (ALWAYS)

Fields sit inside long forms and chat-style inputs. Every keystroke must stay cheap.

## Rebuild scope

- **No `setState` per keystroke on the whole field.** Listen to the controller with `ValueListenableBuilder` / `ListenableBuilder` scoped to the smallest subtree (clear button, direction, suggestion strip).
- Derive a small value (`bool hasText`, `TextDirection`) and **only notify when it changes** (`ValueNotifier` already dedupes equal values — keep it that way).
- Never `setState` from a listener inside a post-frame callback just to flip a value a notifier can hold.
- Read `MediaQuery` through aspect getters (`sizeOf`, `textScalerOf`), never `MediaQuery.of`.
- `const` constructors and `const` subtrees wherever possible; no helper methods returning widgets — use small `StatelessWidget`s.

## Per-keystroke work

- Direction detection is **first-strong-character, early exit**, capped (see `text-direction.mdc`). No full-string scans.
- Country / suggestion filtering: precompute lowercase search keys once; do not rebuild lists in `build`.
- Phone parse on text change runs only when the text starts with `+` or `00` (or on paste), never on every digit.

## Lifecycle

- Every `addListener` has a matching `removeListener` in `dispose`; own what you create (`_ownsController`, `_ownsFocusNode`) and dispose only that.
- No `Future.delayed` timers for focus/selection tricks — use `WidgetsBinding.instance.addPostFrameCallback` once, guarded by `mounted`.
- Images: decode with `cacheWidth`/`cacheHeight` for thumbnails; never hold full-size bytes in widget state longer than needed.

## State management

- **No Riverpod / Bloc / Provider / GetX inside the package.** Hosts bring their own. The package state is local (`State`, `ValueNotifier`, `ChangeNotifier`) and exposed through controllers + callbacks.
- If a dependency feels necessary, stop and ask — it must not leak into the public API.

## Verify

- Add a widget test that types 200 chars and asserts the outer `build` count stays flat (counting builder around the field).
- Profile in the example app (`flutter run --profile`) when touching text/direction/paste paths.
