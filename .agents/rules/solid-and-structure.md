---
description: SOLID, folder layering, reusable pieces — how lib/src is organized and what each file may depend on
globs: "lib/**/*.dart,test/**/*.dart"
alwaysApply: true
---
# SOLID and structure (ALWAYS)

`test/architecture_test.dart` enforces the layering below. Change the layering only together with that test and this rule.

## Layout

```text
lib/mre_fields.dart            barrel: the only public entry
lib/src/
  theme/                       tokens and texts            (imports nothing else)
  internal/                    helpers shared by features  (never exported)
  text/direction/              direction detection, Text helpers
  text/field/                  MRETextField and its pieces
  attachments/model/           value types and the controller
  attachments/paste/           behaviours, paste rules, platform hooks
  attachments/ui/              thumbnails and viewer
  previews/                    previews only; nothing imports them
```

Dependency direction, one way: `theme` ← `text/direction` ← `text/field` → `attachments/*`. `attachments` never imports `text`. `text/direction` never imports `text/field`. A new feature gets its own folder and its own entry in the architecture test.

## Single responsibility

- A class has one reason to change. Test it: say what it does without "and".
- Split by responsibility, not by size. Examples already done: text field = widget + `MREOwned` (lifecycle) + `MRETextFieldFlagsTracker` (what depends on the text) + `MRETextFieldSuggestions` + decoration resolver; image paste = behaviour (config) + `MREImagePasteHandler` (rules, no widgets) + action + menu + scope (wiring).
- Rules live in plain classes with no widgets so they test without pumping. Widgets only wire and draw.
- A file stays under 350 lines of code (blanks and comments excluded). A pass-through widget that mirrors `TextFormField`'s parameter list is the one reason to be near it.

## Open / closed

- Add behaviour by adding a class, not by adding a branch. `MREImagePasteBehavior` is extended by `MRENoImagePaste`, `MREImageCallbackPaste`, `MREImageAttachmentPaste`; hosts add their own.
- Variation is **data**, not a type check: a behaviour returns an `MREAttachmentsConfig` to keep images. The scope never writes `behavior is MREImageAttachmentPaste`.
- Constructor parameters beat flags: no `bool` that switches a method into a different job.

## Liskov

A subclass accepts everything its parent accepts and promises at least what the parent promises. Every behaviour passes the same `check` contract; `MRENoImagePaste` is never asked for images because `acceptsImages` is false.

## Interface segregation

Put only what every subtype uses on the base class. Optional capability goes behind one nullable member (`attachments`) or a small interface (`MREClipboardImageReader`), not a fat base with members most subtypes ignore.

## Dependency inversion

- High-level rules depend on small abstractions: `MREClipboardImageReader`, `MREImagePasteBehavior`. The `pasteboard` plugin and `package:web` sit behind them.
- Platform code goes behind a conditional import with one tiny function (`mreListenForPastedImages`); the stub does nothing.
- Pass dependencies in (constructor or parameter). No global state, no singletons, no static mutable config.

## Reusable pieces

- Every piece a host could want alone is public and exported: `MRESuggestionBar`, `MREFieldClearButton`, `MREAttachmentStrip`, `MREImageViewer`, `MREImagePasteScope`, `MRESafeTextEditingController`, the pure functions.
- A class used across files but not meant for hosts is `@internal` (from `package:meta`) and is **not** exported. The architecture test fails if an `@internal` file is exported.
- Public type names start with `MRE`; helper functions and constants start with `mre`.

## Composition

Prefer composition to inheritance. Inherit only to plug into a framework contract (`ThemeExtension`, `ContextAction`, `TextEditingController`) or to define an extension point (`MREImagePasteBehavior`).

## Before you add a file

1. Which folder owns it? If none, is it a new feature (new folder + architecture entry)?
2. Does its import list respect the direction above?
3. Is it public? Then export it and document it. Is it internal? Then `@internal`.
4. Is there a test at the same path under `test/`?
