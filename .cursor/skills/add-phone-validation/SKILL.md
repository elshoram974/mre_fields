---
name: add-phone-validation
description: >-
  Implements phone parsing/validation for all countries, the country list with
  include/exclude/favorite filters, and paste-to-detect-country in mre_fields.
  Use for phone number validation, dial code detection, or limiting which
  countries a field accepts.
---

# Phone parse, validate, country filters

Read `.cursor/rules/phone-countries.mdc`.

## Steps

1. **Pick the data source** (decision recorded in `ROADMAP.md` Step 4). Preferred: a maintained libphonenumber-derived Dart package wrapped behind `MREPhoneNumber` / `MRECountry`. Check `pub.dev` for latest version and publish date before adding; follow `dependency-hygiene` (caret range, no `any`).
2. **Model** `lib/src/phone/`: `MRECountry` (iso code, dial code, English name), `MRECountries.all`, `MRECountrySelection` (include / exclude / favorites, assert not both).
3. **Pure API**: `MREPhoneNumber.parse`, `isValid`, `isPossible`, `formatE164`, `formatNational`, plus `MREPhoneParseResult` with a failure reason enum. No silent catches.
4. **Filtering is shared**: one `MRECountrySelection` object feeds picker list, paste detection and validation.
5. **Paste/typing** in `MREPhoneField`: detect on `+`/`00`/paste only; longest dial match restricted to allowed countries; ISO code is the selection key, not the dial code.
6. **Validator**: `MREPhoneValidators.valid(...)` returns a `FormFieldValidator<String>`. It yields an `MREPhoneError` reason; text comes from `MREFieldsStrings` or a host `errorTextBuilder`, so hosts can localize every message. Country names use `countryNameBuilder` (English fallback shipped). Normalize Arabic-Indic digits before parsing.
7. **Data-driven test**: iterate every country, assert a sample valid number passes and a mangled one fails. Plus the cases in the rule.
8. Port from ledger only the behaviour (longest-dial-first, trunk strip), not its `intl_phone_field` dependency or its `firstWhere(dialCode)` lookup.
9. Export, example page ("Phone: all / include / exclude"), `CHANGELOG`.

## Check

```bash
flutter analyze && flutter test test/src/phone
```
