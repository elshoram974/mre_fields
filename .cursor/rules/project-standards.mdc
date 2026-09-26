---
description: Always-on standards for mre_fields — read CLAUDE.md first, report removals, keep touched code clean
globs: *
alwaysApply: true
---
# mre_fields — Project Standards (ALWAYS APPLY)

## 0. CLAUDE.md is the source of truth

`./CLAUDE.md` defines scope, what to port from CashBook, theming, public API, tests, and commits.

**Read it before you change anything.** Do not wait to be asked.

## 1. Never delete working behaviour silently ⚠️

Any change that removes lines which *did something* — method, branch, widget param, public export — MUST be reported under **⚠️ Removed**:

- **Replaced** — `old → new`, say if behaviour differs
- **Dropped** — what the consumer can no longer do, and why
- **Dead** — how you know nothing reached it (grep, superseded by X)

Unclassifiable → **do not delete — ask first.**

Flag public API removals explicitly (exported class, constructor param, theme token): say what host apps must change.

## 2. Leave the code you touch cleaner than you found it

- Split the god-method you just extended; name the magic number you walked past; brace multi-line `if`s; drop unused imports/params.
- Scope cleanup to the enclosing unit + its direct helpers — not a drive-by rewrite of the package.
- Structural leftover problem → fix what you touched, then **say at the end** what is still wrong and how to fix it.
- Before done: `flutter analyze` — new infos/warnings are regressions. `dart format` only on files you edited.
- UI/field changes also need the size + regression rules (`test-field-sizes`, `full-regression`).
- No FVM in this package — plain `flutter` / `dart` on PATH.

## 3. Package boundaries (hard)

- No CashBook imports (`app_sizes`, `context.colors`, `.tr()`, `go_router`, blocs, prefs).
- No `.tr()` / translation maps inside this package — hosts pass strings.
- Styling via `Theme` + `MreFieldsTheme`, not a mutable global `initialize`.
- Export only through `lib/mre_fields.dart`.
