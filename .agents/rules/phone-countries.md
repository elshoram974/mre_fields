---
description: Phone numbers — dial codes, include/exclude countries, full validation for all countries, paste parsing
globs: "lib/src/phone/**/*.dart,test/src/phone/**/*.dart"
alwaysApply: true
---
# Phone & countries

## Data and validation

- Validation must cover **every country**, not a hand-typed subset. Do not hand-write per-country regexes. Use a maintained libphonenumber-derived dataset behind our own API (`MREPhoneNumber`, `MRECountry`) so the dependency can be swapped without breaking hosts. Decision on which package lives in `ROADMAP.md` (Step 4).
- Public pure API (no widgets): `parse(String, {defaultCountry})`, `isValid`, `formatE164`, `formatNational`, `isPossible`, `lookupByDialCode`.
- Failure is a value: return an invalid / empty result with a reason enum. **No `catch (_) {}`.**

## Country set

- `MRECountries.all` is the full list. Hosts narrow it with constructor params:
  - `countries` / `includeCountries` — only these ISO codes.
  - `excludeCountries` — everything except these.
  - `favoriteCountries` — pinned at the top of the picker.
  - `initialCountry`.
- Include and exclude together is an assert failure (clear message), not silent precedence.
- Filtering applies to **picker, paste-parse and validation** consistently: a pasted `+972…` with Israel excluded must not silently select it.
- A dial code is **not** a country key (`+1` US/CA/…, `+7` RU/KZ). Selection state stores the ISO code; the dial code is derived. (Ledger's `firstWhere(dialCode ==)` loses this.)
- Country names are localizable: `countryNameBuilder: String Function(MRECountry)` (and/or a `Map<String,String>` by ISO code). The package ships ISO code + dial code + English name as fallback only.

## Localization (hosts translate, package never does)

- All user-visible text lives in **one immutable value class**, `MREFieldsStrings` (search hint, empty state, picker title, validation messages, image viewer labels/tooltips). Defaults are English; hosts replace any field.
- Resolution order: widget param → `MREFieldsTheme.strings` → English default. No `.tr()`, no ARB, no bundled translation maps, no dependency on `flutter_localizations`.
- Validation returns a **reason enum** (`MREPhoneError.empty|tooShort|tooLong|invalidForCountry|countryNotAllowed|…`); message text comes from `MREFieldsStrings` or a host `errorTextBuilder: String Function(MREPhoneError)`.
- Hosts using gen-l10n pass `AppLocalizations` values into `MREFieldsStrings(...)` once, next to `MREFieldsTheme` in `ThemeData.extensions`.
- Numerals/RTL: normalize Arabic-Indic digits to ASCII before parsing; keep dial code and number LTR (see `i18n-rtl-l10n` skill).

## Paste / typing

- On paste or text starting with `+` or `00`: longest dial-code match, then national-number extraction, then strip the trunk prefix where the country uses one (not blindly every leading `0`).
- Update dial control + local text in one controller change, keep cursor at end, no layout jump.
- Digits only in the local field (`FilteringTextInputFormatter`); keep `+` handling in the paste path.
- Validation runs on change/blur according to a param; never blocks typing.

## Tests

`+20…`, `0020…`, leading `0` trunk, `+1` ambiguity, `+971` vs `+97`, excluded country paste, empty, letters, too long, too short, every country has ≥1 valid sample number (data-driven test).
