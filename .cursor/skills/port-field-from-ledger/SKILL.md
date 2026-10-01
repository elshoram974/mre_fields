---
name: port-field-from-ledger
description: >-
  Ports AppTextField, phone helpers, country picker, or BIDI helpers from MRE
  CashBook (ledger) into mre_fields. Use when the user asks to bring a field
  widget from ledger, migrate AppTextField, or extract phone/country/BIDI code
  into this package.
---

# Port a field from CashBook into mre_fields

## Before you start

1. Read `CLAUDE.md` (scope + reference table) and `.cursor/rules/port-from-ledger.mdc`.
2. Confirm the ledger path exists:
   `/Users/mohammedelshora/Desktop/Shora/projects/mrecode/ledger/`
3. Name the target: `MRETextField` / `MREPhoneField` / helpers only.

## Steps

1. **Read** the ledger source end-to-end (not just the class header).
2. **List behaviours** to keep (e.g. live BIDI, suggestion row, clear button, select-on-focus, phone parse longest-dial-first).
3. **List couplings to drop** (`.tr()`, `AppSizes`, `context.colors`, `AdaptiveOverlays`, glass, router, blocs).
4. **Create** files under `lib/src/...` with `MRE*` names.
5. **Wire theme** via `MREFieldsTheme` + Material `Theme`.
6. **Replace translated strings** with constructor `String` / `String?` params; document what the host should pass.
7. **Export** from `lib/mre_fields.dart`.
8. **Tests**: unit for pure helpers; widget tests for interaction.
9. **Verify**:
   ```bash
   rg "app_sizes|\\.tr\\(|go_router|AppColors|mre_cashbook" lib/ || true
   flutter analyze
   flutter test
   ```
10. **CHANGELOG.md** entry under `[Unreleased]` or the version being cut.
11. Reply with **⚠️ Removed** for any CashBook-only behaviour intentionally left behind (Dropped) or replaced.

## Phone / country specifics

- Port `PhoneNumberHelper` parse rules (longest dial match, strip trunk `0` after dial).
- Port country data needed for dial codes — trim to what the picker needs.
- Rebuild the picker sheet with Material (`showModalBottomSheet` / dialog). Pass search hint and title as params.
- Do **not** port `AppContactPicker` or device contacts.

## Do not

- Move `CustomFieldRegistry` or book field specs.
- Port `pdfReshaped` / Arabic PDF pipeline.
- Leave a dependency on the ledger package.
