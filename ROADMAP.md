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

## Step 1 — `MREFieldsTheme` `[x]`

### Goal
Host apps plug field tokens into **their existing** `ThemeData`. Colors come from
the host `colorScheme` / `inputDecorationTheme`; we only add radii/paddings/gaps.
Every later widget must honor: **param → theme → Material default**.

### Plan
1. Add `lib/src/theme/mre_fields_theme.dart` as a `ThemeExtension<MREFieldsTheme>`.
2. Start with a **small** token set only what `MRETextField` will need:
   - `borderRadius` (or `fieldBorderRadius`)
   - `contentPadding`
   - maybe suggestion chip spacing — **only if** step 3 uses it
3. Implement `copyWith`, `lerp`, and `MREFieldsTheme.of(context)` with a sensible
   **const default** when the extension is missing.
4. Optional factory `MREFieldsTheme.defaults` / derive from `ColorScheme` for
   tokens only — must not replace host colors.
5. Export from `lib/mre_fields.dart`.
6. Smoke: `of(context)` without extension; with extension returns host values.
7. Wire into `lib/src/previews/preview_harness.dart` using a normal `ThemeData`
   (prove we inherit `colorScheme`).
8. Document “register next to your theme” in README + dartdoc (extensibility).
9. `CHANGELOG` under Unreleased.

### Done when
- Analyze clean; theme resolves with/without host registration; README shows
  copy-paste with host `colorScheme` + `MREFieldsTheme` together.

### Result
Shipped: `MREFieldsTheme` (radius, two paddings, two breakpoints, `strings`), `MREWindowSize`, `MREFieldsStrings`. Suggestion-chip tokens wait for Step 3. 14 tests, analyze clean.

### Do not
- Ship a package color palette or mutable `initialize`.
- Name tokens after CashBook `AppSizes`.

---

## Step 2 — Text direction layer (BIDI + safe UTF-16) `[x]`

### Goal
Pure helpers the field needs, stripped of PDF / CashBook extras — and the same
detection reusable outside the field: `String` extensions, a `Text` helper and a
widget extension (see `.cursor/rules/text-direction.mdc`, skill
`add-text-direction-extensions`).

### Plan
1. Port from ledger `lib/core/utils/extensions/string_extension.dart`:
   - `uiTextDirection` / string `textDirection`
   - `safeDisplayText` (and any private UTF-16 helpers it needs)
2. Place under `lib/src/text/direction/text_direction.dart` (and split file if `safeDisplayText` is large).
   Re-implement detection as **first-strong-character with early exit** (ledger scans the whole string via `Bidi`).
2a. Add `String.textDirection` / `isRtl` / `autoTextAlign`, `MREAutoText` (Text helper) and `Widget.withTextDirection(sample)`.
3. **Do not** port `pdfReshaped` / arabic_reshaper.
4. Depend on `intl` only if needed for `Bidi` (add to `pubspec.yaml`).
5. Unit tests: empty string, Arabic → RTL, English → LTR, unpaired surrogates → U+FFFD.
6. Export helpers only if hosts need them; otherwise keep library-private and export later if CashBook asks.
7. `CHANGELOG`.

### Result
Shipped without `intl`: own first-strong detection (Closure ranges, Arabic-Indic digits and emoji neutral, 256-unit scan cap), `MRETextDirection` getters, `MREAutoText`, `withTextDirection`, `safeDisplayText`. Guide `doc/text.md`, previews via `@MREPreview()`.

### Done when
- Tests green for direction + safe text; no PDF imports; `rg pdfReshaped lib/` empty.

### Depends on
- Nothing (can run before or with step 1). Prefer **after** step 1 so theme exists for upcoming field work.

---

## Step 3 — `MRETextField` `[x]`

### Goal
Port CashBook `AppTextField` behaviour into a host-agnostic widget.

### Plan
1. Read ledger `lib/core/widgets/app_text_field.dart` end-to-end; list behaviours to keep:
   - live BIDI + alignment
   - clear button
   - select-on-focus
   - suggestion chips row
   - external/internal controller, `fieldKey`, validators, formatters, etc.
2. Create `lib/src/text/field/mre_text_field.dart` (`MRETextField`).
3. Strip: `AppSizes`, `AppDecorations`, `context.colors`, `.tr()`, any CashBook-only imports.
4. Style from `Theme.of(context).inputDecorationTheme` + `MREFieldsTheme` + optional constructor overrides.
5. All user-visible strings = constructor params (`hintText`, `labelText`, …).
6. Port `SafeTextController` only if still required (`lib/src/text/field/mre_safe_text_editing_controller.dart`).
7. Export `MRETextField` from barrel.
8. Replace placeholder in preview files with real `MRETextField` cards (empty, filled English, Arabic, dark).
9. Widget tests (skill `add-widget-test` + rule `test-field-sizes`):
   - type Arabic → RTL
   - clear button
   - suggestions on focus
   - explicit `textDirection` override
   - at least one wide / textScale case
10. `CHANGELOG`; bump toward `0.1.0` when this step is the first usable release.

### Result
Shipped: `MRETextField` (about 45 pass-through parameters), `MRESuggestionBar`, `mreFilterSuggestions`, `MREFieldClearButton`, `MRESafeTextEditingController`. Rebuilds only when the direction or the empty state changes (tested). 7 preview cards, checked in the real previewer. Image paste moves to Step 3a.

Differences from ledger `AppTextField`:
- `isFilled` dropped: pass `decoration: InputDecoration(filled: true)`; fill and borders come from the host theme.
- `textCapitalization` defaults to `none` (ledger: `sentences`).
- `textAlign` defaults to `TextAlign.start`, which follows the detected direction (ledger set left/right by hand).
- Select-on-focus uses one post-frame callback instead of a 50 ms delay.
- Suggestions scroll sideways at their natural height (ledger: fixed 32 px list, clips at large text) and sit in a `TextFieldTapRegion`.
- No `try/catch (_)`; the safe controller checks the composing range instead.

### Fix while porting (found in review of ledger `AppTextField` and the mtgr `CustomTextFieldWidget`)
- `setState` on every controller tick and post-frame `setState` for direction → scoped `ValueNotifier` + `ValueListenableBuilder` (rule `performance.mdc`).
- Listeners added but not removed (mtgr `focusNode`) → symmetric add/remove, own only what we create.
- `try { … } catch (_) {}` around `Directionality.of` / controller reads → remove; handle lifecycle with `mounted`.
- `Future.delayed(50ms)` for select-on-focus → single post-frame callback.
- Hard-coded colors/sizes (`Color(0xFF202532)`, `Colors.red`, `AppSizes`) → `Theme` + `MREFieldsTheme`.
- Per-flag boolean soup (`isPassword`, `isAmount`, `showCodePicker`) → presets / small composable pieces; phone code picker is **not** part of `MRETextField`.
- Assets-as-strings for icons (`prefixIcon: String`) → `Widget? prefixIcon`.

### Done when
- Analyze + tests green; previews show the real field; no CashBook imports (`rg` gate in port skill).
- Build-count test proves typing does not rebuild the whole field.

### Depends on
- Steps 1 + 2.

---

## Step 3a — Image paste behaviours `[x]`

### Goal
Optional paste of images into the text field. Default: nothing changes. Skill `add-image-paste`, rule `image-paste.mdc`.

### Plan
1. Wire paste entry points (mobile keyboard insertion, desktop shortcut, context menu, web); keep the platform table in `doc/attachments.md`.
2. `MREPastedImage`, `MREImagePasteBehavior` (abstract) and three implementations:
   `MRENoImagePaste` (default) · `MREImageCallbackPaste` (callback only, no UI) · `MREImageAttachmentPaste` (thumbnail strip + open / remove / replace + callback).
3. New `MRETextField(imagePaste: …)` param, default `const MRENoImagePaste()`.
4. Clipboard reading behind `MREClipboardImageReader`, default implementation on `pasteboard` (checked on pub.dev: Android, iOS, macOS, Windows, Linux, web; `super_clipboard` needs a Rust toolchain and was last released 2025-06).
5. Limits + `onImageRejected`; viewer widget; semantics labels as params.
6. Tests: default ignores images, callback payload, limits, remove/replace, text paste unaffected, compact/expanded/RTL/textScale.
7. Previews + example page; `CHANGELOG`.

### Result
Shipped as planned, without the spike: the clipboard is read through the `pasteboard` plugin (all six platforms, 0.5.0, 2026-02) behind `MREClipboardImageReader`. Decision: a normal dependency, not an optional library, because pub packages cannot have optional dependencies; the plugin stays idle unless a behaviour accepts images. Shortcut, selection menu and Android keyboard all work through one accept path. About 60 tests with a fake clipboard; thumbnails checked in the real previewer. Found by testing in the real previewer: Flutter disables Ctrl/Cmd+V on the web, so the web path is a DOM `paste` listener instead (browser test + previewer check). Not yet tried on physical devices.

### Depends on
- Step 3.

---

## Step 4 — Phone parse, validation + country data `[ ]`

### Goal
Pure phone parsing, **validation for all countries**, and a country list hosts can narrow (include / exclude / favorites) — no UI yet. Skill `add-phone-validation`, rule `phone-countries.mdc`.

### Decision (made)
Wrap `phone_numbers_parser` (pure Dart, libphonenumber metadata) behind `MREPhoneNumber`, hidden from the public API so it can be swapped. Localization: validation returns an `MREPhoneError` reason; messages and country names come from `MREFieldsStrings` / builders supplied by the host (see `phone-countries.mdc`).

### Plan
1. Port `PhoneNumberHelper` → `lib/src/phone/phone_number.dart` (rename API to `MREPhoneNumber` / top-level functions as fits).
2. Port dial data from `lib/core/constants/countries.dart` → `lib/src/phone/countries.dart` (trim to what the picker needs: name, dial, code/flag if used).
3. Keep longest-dial-first match; strip trunk `0` after dial extraction.
3a. `MRECountrySelection` (include / exclude / favorites / initial; both include+exclude is an assert). Selection key = ISO code, **not** dial code (`+1`, `+7` are shared).
3b. `MREPhoneValidators` returning `FormFieldValidator<String>`; error reason enum + `MREFieldsStrings` for localizable messages.
4. Unit tests: `+20…`, `00…`, no dial, empty, edge countries with longer codes, `+1` ambiguity, excluded-country paste, and a data-driven test over every country.
5. Export parse API if hosts need it; otherwise export with the phone field in step 6.
6. `CHANGELOG`.

### Done when
- Parse tests cover the CashBook cases you care about; no UI / no `.tr()`.

### Depends on
- Nothing hard; can parallelize after step 3 starts, but land after 3 if you want a clean first tag on text-only.

---

## Step 5 — `MRECountryCodePicker` `[ ]`

### Goal
Searchable dial-code sheet owned by the package (Material), no CashBook overlays/glass/router.

### Plan
1. Read ledger `app_country_code_picker.dart`; keep: search, list, select callback, optional custom builder.
2. Rewrite presentation:
   - **Compact:** Material bottom sheet
   - **Expanded / desktop:** centered dialog with max width — not a phone sheet on a large monitor
3. All copy as params: `title`, `searchHint`, empty state, etc.
4. Use `MRETextField` for search when ready.
5. Widget tests: filter, select, compact + expanded host size.
6. Preview both presentations if practical.
7. Export + `CHANGELOG`.

### Done when
- Picker works phone + tablet-ish size in tests/preview; no ledger UI deps.

### Depends on
- Step 4 (data). Step 3 preferred for search field.

---

## Step 6 — `MREPhoneField` `[ ]`

### Goal
One composed field: dial control + local number, using parse helpers + picker.

### Plan
1. `lib/src/phone/mre_phone_field.dart` composing `MRETextField` + dial affordance + `MRECountryCodePicker`.
2. **Compact vs expanded layout** for phone field and picker (see `responsive-adaptive.mdc`) —
   stack/tight row on narrow; single row / centered dialog on wide.
3. Constructor: initial dial/local or full E.164 string; `onChanged` with structured value (dial + local ± formatted).
4. Paste `+…` → parse and update dial/local without layout jump or overflow.
5. Theme tokens for density/padding if shared; else constructor.
6. Widget tests: paste, dial change, **compact + expanded** width, textScale 1.3.
7. Previews: empty, EG dial, compact card + expanded card, dark.
8. Export + `CHANGELOG`; consider version `0.2.0`.

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
3. Add `MREFieldsTheme` to CashBook `ThemeData.extensions` (map from `AppSizes` once).
4. Replace call sites gradually:
   - first non-critical screens / new code
   - then shared wrappers if you want `AppTextField` to forward to `MRETextField` temporarily
5. Do **not** move `CustomFieldRegistry` into the package; specs keep calling `MRETextField`.
6. Run CashBook analyze/tests for touched flows; manual QA on Arabic BIDI + phone entry.
7. Note integration in both changelogs if useful.

### Done when
- At least one real CashBook screen uses `MRETextField` (and phone when ready) in production paths; no duplicate divergent logic left undocumented.

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
    → 2 text direction layer (function + extensions)
    → 3 MRETextField (+ tests/previews)
    → 3a image paste behaviours
    → 4 phone parse / validation / country filters
    → 5 country picker
    → 6 MREPhoneField
    → 7 CashBook path + gradual replace
    → 8 harden / version
```

## Agent shortcuts per step

| Step | Skill / rule |
|---|---|
| 1–6 porting | `port-field-from-ledger`, `add-field-widget` |
| 2 direction | `add-text-direction-extensions` |
| 3a images | `add-image-paste` |
| 4 phone | `add-phone-validation` |
| Docs / examples | `write-package-docs`, `add-example-app` |
| Layout / perf | `adaptive-layout`, `flutter-performance`, `widget-composition` |
| Tests | `add-widget-test`, `full-regression-test`, `test-field-sizes` |
| Previews | `add-widget-preview` |
| Version | `bump-package-version` |
