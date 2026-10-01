---
description: Full regression gate before claiming a field feature or release is done
globs: "*"
alwaysApply: true
---
# Full regression (mre_fields)

A feature or release is **not done** until this gate is green.

## Required commands

```bash
flutter pub get
flutter analyze
flutter test
```

Optional when UI changed:

```bash
flutter widget-preview start
# or IDE Flutter Widget Preview panel
```

## Coverage expectations

| Layer | Must cover |
|---|---|
| Unit | Phone parse/format, BIDI helpers, pure validators |
| Widget | Text field BIDI / clear / suggestions; phone dial+local; country search+select |
| Sizes | At least phone + one wide + RTL or textScale 1.3 on the touched widgets |

## Fail conditions

- New analyzer info/warning vs baseline
- Any test red
- Known `RenderFlex overflowed` in test output
- Public API change without `CHANGELOG.md` note

## Do not

- Skip tests because "it's only a theme token"
- Run `dart format` on the whole tree — only edited files
- Claim done after analyze alone
- Introduce FVM into this repo
