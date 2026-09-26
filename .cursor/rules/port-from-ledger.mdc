---
description: How to port field widgets from MRE CashBook (ledger) into mre_fields without dragging app coupling
globs: "lib/**/*.dart"
alwaysApply: false
---
# Port from CashBook (ledger)

Source app (sibling repo):

`/Users/mohammedelshora/Desktop/Shora/projects/mrecode/ledger/`

## Checklist every port

1. Open the ledger file listed in `CLAUDE.md` (Reference implementation table).
2. Copy **behaviour** (BIDI, clear, suggestions, phone parse) — not file structure blindly.
3. Rename `App*` → `Mre*`.
4. Strip imports: `app_sizes`, `app_decorations`, `context_extension` colors, `.tr()`, `go_router`, blocs, prefs, glass, adaptive overlays.
5. Strings that were `.tr()` keys → required/`String?` constructor params with English dartdoc describing the host's duty.
6. Theme: `MreFieldsTheme` + Material `Theme`.
7. Country sheet: Material modal/sheet owned here — not `AdaptiveOverlays.showAdaptiveModal`.
8. Leave in ledger (do **not** port): `pdfReshaped`, contact picker DB, `CustomFieldRegistry`, entry validators tied to books.
9. Add unit/widget tests that pin the behaviour you ported.
10. Export from `lib/mre_fields.dart` + `CHANGELOG.md` entry.

## Verification

- `rg "package:mre_cashbook|app_sizes|\\.tr\\(|go_router|AppColors" lib/` → must be empty.
- `flutter analyze` clean for new issues.
- `flutter test`.
