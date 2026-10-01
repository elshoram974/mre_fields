# Third-party skills

Copied unmodified into this folder. Pin = commit at copy time (2026-10-01). Licenses in `_licenses/`. Update by re-copying from upstream and bumping the pin here.

| Skills | Upstream | License | Pin |
|---|---|---|---|
| `flutter-build-responsive-layout`, `flutter-fix-layout-issues`, `flutter-add-widget-test`, `flutter-add-widget-preview`, `dart-write-documentation`, `dart-use-doc-examples`, `dart-run-static-analysis`, `dart-add-unit-test`, `dart-use-pattern-matching`, `dart-resolve-package-conflicts` | https://github.com/flutter/skills | BSD-3-Clause | `0ef3972` |
| `adaptive-layout`, `i18n-rtl-l10n`, `accessibility-as-code`, `flutter-performance`, `widget-composition`, `forms-and-input`, `dartdoc-conventions`, `testing-strategy`, `widget-golden-and-a11y-testing`, `lint-and-style-config`, `dependency-hygiene`, `design-system-structure`, `async-safety`, `dart3-idioms-and-coding-standards`, `project-structure-and-packages` | https://github.com/zakariaf/Flutter-Skills | MIT | `e073e5e` |
| `caveman`, `caveman-review` | https://github.com/JuliusBrussee/caveman | Apache-2.0 | `f5d7294` |

Notes

- App-oriented skills in those repos (routing, persistence, Firebase, store shipping, Riverpod, monetization) are intentionally not copied; this package has no app layer and no state-management dependency.
- Bundled `scripts/*.sh` / `audit_deps.py` only read the tree (grep/find/`dart pub deps`); reviewed before copying.
- Our own skills (no upstream) are the rest of the folders here.
- `caveman` only changes reply style when invoked (`/caveman`). It is not active by default.
