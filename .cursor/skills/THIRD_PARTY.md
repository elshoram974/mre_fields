# Third-party skills

Copied unmodified into this folder. Pin = commit at copy time (2026-10-01). Licenses in `_licenses/`. Update by re-copying from upstream and bumping the pin here.

| Skills | Upstream | License | Pin |
|---|---|---|---|
| `flutter-build-responsive-layout`, `flutter-fix-layout-issues`, `flutter-add-widget-test`, `flutter-add-widget-preview`, `dart-write-documentation`, `dart-use-doc-examples`, `dart-run-static-analysis`, `dart-add-unit-test`, `dart-use-pattern-matching`, `dart-resolve-package-conflicts` | https://github.com/flutter/skills | BSD-3-Clause | `0ef3972` |
| `adaptive-layout`, `i18n-rtl-l10n`, `accessibility-as-code`, `flutter-performance`, `widget-composition`, `forms-and-input`, `dartdoc-conventions`, `testing-strategy`, `widget-golden-and-a11y-testing`, `lint-and-style-config`, `dependency-hygiene`, `design-system-structure`, `async-safety`, `dart3-idioms-and-coding-standards`, `project-structure-and-packages` | https://github.com/zakariaf/Flutter-Skills | MIT | `e073e5e` |
| `clean-code`, `solid-principles`, `design-patterns`, `dry-kiss-yagni`, `architecture-principles`, `testing-principles` (+ rule `.cursor/rules/clean-principles-core.mdc`) | https://github.com/Khuirul-Huda/clean-principles | MIT (declared in `package.json`; the repo has no LICENSE file) | `846c4f0` |
| `software-design-principles` (SKILL.md + `references/`; the repo's `hooks/` are not copied) | https://github.com/gufettonerd-arch/software-design-principles | MIT | `1b69f45` |
| `caveman`, `caveman-review` | https://github.com/JuliusBrussee/caveman | Apache-2.0 | `f5d7294` |

Notes

- Language-agnostic design skills (SOLID, clean code, patterns) use Python/Java-style examples; read them for the principle, apply it in Dart through `.cursor/rules/solid-and-structure.mdc`, `clean-code.mdc` and `data-structures.mdc`, which win on conflicts.
- App-oriented skills in those repos (routing, persistence, Firebase, store shipping, Riverpod, monetization) are intentionally not copied; this package has no app layer and no state-management dependency.
- Bundled `scripts/*.sh` / `audit_deps.py` only read the tree (grep/find/`dart pub deps`); reviewed before copying.
- Our own skills (no upstream) are the rest of the folders here.
- `caveman` is applied to every chat reply through `.claude/reply-style.md` (imported by `CLAUDE.md`). `/caveman off` turns it off for a session.
