# mre_fields — Implementation roadmap

Ordered plan. Finish a step (code + tests + `CHANGELOG` note) before starting the next unless a later step only needs a stub.

**Source of truth for rules:** [`CLAUDE.md`](./CLAUDE.md)  
**Port skill:** `.cursor/skills/port-field-from-ledger`  
**Ledger root:** `/Users/mohammedelshora/Desktop/Shora/projects/mrecode/ledger/`

---

## Status legend

| Mark | Meaning |
|---|---|
| `[ ]` | Not started |
| `[~]` | In progress |
| `[x]` | Done |

Update the boxes as you ship.

---

## Step 0 — Package skeleton `[x]`

Already done: package created, agent docs/rules/skills, preview harness placeholder, no FVM.

---

## Step 1 — `MreFieldsTheme` `[ ]`

### Goal
Host apps plug field tokens into **their existing** `ThemeData`. Colors come from
the host `colorScheme` / `inputDecorationTheme`; we only add radii/paddings/gaps.
Every later widget must honor: **param → theme → Material default**.

### Plan
1. Add `lib/src/theme/mre_fields_theme.dart` as a `ThemeExtension<MreFieldsTheme>`.
2. Start with a **small** token set only what `MreTextField` will need:
   - `borderRadius` (or `fieldBorderRadius`)
   - `contentPadding`
   - maybe suggestion chip spacing — **only if** step 3 uses it
3. Implement `copyWith`, `lerp`, and `MreFieldsTheme.of(context)` with a sensible
   **const default** when the extension is missing.
4. Optional factory `MreFieldsTheme.defaults` / derive from `ColorScheme` for
   tokens only — must not replace host colors.
5. Export from `lib/mre_fields.dart`.
6. Smoke: `of(context)` without extension; with extension returns host values.
7. Wire into `lib/src/previews/preview_harness.dart` using a normal `ThemeData`
   (prove we inherit `colorScheme`).
8. Document “register next to your theme” in README + dartdoc (extensibility).
9. `CHANGELOG` under Unreleased.

### Done when
- Analyze clean; theme resolves with/without host registration; README shows
  copy-paste with host `colorScheme` + `MreFieldsTheme` together.

### Do not
- Ship a package color palette or mutable `initialize`.
- Name tokens after CashBook `AppSizes`.

---

## Step 2 — Text helpers (BIDI + safe UTF-16) `[ ]`

### Goal
Pure helpers the field needs, stripped of PDF / CashBook extras.

### Plan
1. Port from ledger `lib/core/utils/extensions/string_extension.dart`:
   - `uiTextDirection` / string `textDirection`
   - `safeDisplayText` (and any private UTF-16 helpers it needs)
2. Place under `lib/src/text/text_direction.dart` (and split file if `safeDisplayText` is large).
3. **Do not** port `pdfReshaped` / arabic_reshaper.
4. Depend on `intl` only if needed for `Bidi` (add to `pubspec.yaml`).
5. Unit tests: empty string, Arabic → RTL, English → LTR, unpaired surrogates → U+FFFD.
6. Export helpers only if hosts need them; otherwise keep library-private and export later if CashBook asks.
7. `CHANGELOG`.

### Done when
- Tests green for direction + safe text; no PDF imports; `rg pdfReshaped lib/` empty.

### Depends on
- Nothing (can run before or with step 1). Prefer **after** step 1 so theme exists for upcoming field work.

---

## Step 3 — `MreTextField` `[ ]`

### Goal
Port CashBook `AppTextField` behaviour into a host-agnostic widget.

### Plan
1. Read ledger `lib/core/widgets/app_text_field.dart` end-to-end; list behaviours to keep:
   - live BIDI + alignment
   - clear button
   - select-on-focus
   - suggestion chips row
   - external/internal controller, `fieldKey`, validators, formatters, etc.
2. Create `lib/src/text/mre_text_field.dart` (`MreTextField`).
3. Strip: `AppSizes`, `AppDecorations`, `context.colors`, `.tr()`, any CashBook-only imports.
4. Style from `Theme.of(context).inputDecorationTheme` + `MreFieldsTheme` + optional constructor overrides.
5. All user-visible strings = constructor params (`hintText`, `labelText`, …).
6. Port `SafeTextController` only if still required (`lib/src/text/safe_text_controller.dart`).
7. Export `MreTextField` from barrel.
8. Replace placeholder in preview files with real `MreTextField` cards (empty, filled English, Arabic, dark).
9. Widget tests (skill `add-widget-test` + rule `test-field-sizes`):
   - type Arabic → RTL
   - clear button
   - suggestions on focus
   - explicit `textDirection` override
   - at least one wide / textScale case
10. `CHANGELOG`; bump toward `0.1.0` when this step is the first usable release.

### Done when
- Analyze + tests green; previews show the real field; no CashBook imports (`rg` gate in port skill).

### Depends on
- Steps 1 + 2.

---

## Step 4 — Phone parse + country data `[ ]`

### Goal
Pure phone dial/local parsing and country dial list — no UI yet.

### Plan
1. Port `PhoneNumberHelper` → `lib/src/phone/phone_number.dart` (rename API to `MrePhoneNumber` / top-level functions as fits).
2. Port dial data from `lib/core/constants/countries.dart` → `lib/src/phone/countries.dart` (trim to what the picker needs: name, dial, code/flag if used).
3. Keep longest-dial-first match; strip trunk `0` after dial extraction.
4. Unit tests: `+20…`, `00…`, no dial, empty, edge countries with longer codes.
5. Export parse API if hosts need it; otherwise export with the phone field in step 6.
6. `CHANGELOG`.

### Done when
- Parse tests cover the CashBook cases you care about; no UI / no `.tr()`.

### Depends on
- Nothing hard; can parallelize after step 3 starts, but land after 3 if you want a clean first tag on text-only.

---

## Step 5 — `MreCountryCodePicker` `[ ]`

### Goal
Searchable dial-code sheet owned by the package (Material), no CashBook overlays/glass/router.

### Plan
2. Read ledger `app_country_code_picker.dart`; keep: search, list, select callback, optional custom builder.
3. Rewrite presentation:
   - **Compact:** Material bottom sheet
   - **Expanded / desktop:** centered dialog with max width — not a phone sheet on a large monitor
4. All copy as params: `title`, `searchHint`, empty state, etc.
5. Use `MreTextField` for search when ready.
6. Widget tests: filter, select, compact + expanded host size.
7. Preview both presentations if practical.
8. Export + `CHANGELOG`.

### Done when
- Picker works phone + tablet-ish size in tests/preview; no ledger UI deps.

### Depends on
- Step 4 (data). Step 3 preferred for search field.

---

## Step 6 — `MrePhoneField` `[ ]`

### Goal
One composed field: dial control + local number, using parse helpers + picker.

### Plan
1. `lib/src/phone/mre_phone_field.dart` composing `MreTextField` + dial affordance + `MreCountryCodePicker`.
3. **Compact vs expanded layout** for phone field and picker (see `responsive-adaptive.mdc`) —
   stack/tight row on narrow; single row / centered dialog on wide.
4. Constructor: initial dial/local or full E.164 string; `onChanged` with structured value (dial + local ± formatted).
5. Paste `+…` → parse and update dial/local without layout jump or overflow.
6. Theme tokens for density/padding if shared; else constructor.
7. Widget tests: paste, dial change, **compact + expanded** width, textScale 1.3.
8. Previews: empty, EG dial, compact card + expanded card, dark.
9. Export + `CHANGELOG`; consider version `0.2.0`.

### Done when
- Phone happy path + paste + size test green; documented in README Features.

### Depends on
- Steps 3–5.

---

## Step 7 — Consume from CashBook `[ ]`

### Goal
CashBook uses the package without a big-bang rewrite.

### Plan
1. In `ledger/pubspec.yaml`:
   ```yaml
   mre_fields:
     path: ../mre_fields
   ```
2. `flutter pub get` on ledger (FVM there is fine — package itself has no FVM).
3. Add `MreFieldsTheme` to CashBook `ThemeData.extensions` (map from `AppSizes` once).
4. Replace call sites gradually:
   - first non-critical screens / new code
   - then shared wrappers if you want `AppTextField` to forward to `MreTextField` temporarily
5. Do **not** move `CustomFieldRegistry` into the package; specs keep calling `MreTextField`.
6. Run CashBook analyze/tests for touched flows; manual QA on Arabic BIDI + phone entry.
7. Note integration in both changelogs if useful.

### Done when
- At least one real CashBook screen uses `MreTextField` (and phone when ready) in production paths; no duplicate divergent logic left undocumented.

### Depends on
- Step 3 minimum; step 6 for phone replacement.

---

## Step 8 — Harden, example app & pub.dev `[ ]`

### Goal
Package feels shippable: regression green, runnable example, optional pub.dev publish.

### Plan
1. Full regression: `flutter analyze` + `flutter test` + spot-check previews.
2. Size/RTL/dark pass on text + phone (`test-field-sizes`).
3. Create/update **`example/`** (skill `add-example-app`) — theme toggle, text, phone, overrides.
4. Trim public barrel to intentional exports; README matches API.
5. Fill `homepage` / `repository` in `pubspec.yaml`.
6. SemVer bump + `CHANGELOG`; `flutter pub publish --dry-run`.
7. Publish only when user asks (skill `publish-to-pub-dev`).
8. Optional: git tag `vX.Y.Z`; CashBook switches from path to `^version`.

### Done when
- Regression green; example runs; dry-run clean (publish optional).

---

## Suggested order (summary)

```text
0 skeleton [x]
    → 1 theme
    → 2 text helpers
    → 3 MreTextField (+ tests/previews)
    → 4 phone parse/data
    → 5 country picker
    → 6 MrePhoneField
    → 7 CashBook path + gradual replace
    → 8 harden / version
```

## Agent shortcuts per step

| Step | Skill / rule |
|---|---|
| 1–6 porting | `port-field-from-ledger`, `add-field-widget` |
| Tests | `add-widget-test`, `full-regression-test`, `test-field-sizes` |
| Previews | `add-widget-preview` |
| Version | `bump-package-version` |
