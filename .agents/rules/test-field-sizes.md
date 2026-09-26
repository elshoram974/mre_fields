---
description: Field widgets must be tested at multiple sizes, RTL, text scale, and brightness before done
globs: "lib/**/*.dart,test/**/*.dart"
alwaysApply: false
---
# Test field widgets at every size

A field change is **not done** when it looks right in one phone-width pump.

## Before you declare done

Pump (or preview) **all** of:

| Surface | Approx. size | What usually breaks |
|---|---|---|
| Phone | ~390×844 | Baseline — do not stop here |
| Tablet portrait | ~834×1112 | Wide fields stretch; prefix/suffix misalign |
| Landscape / desktop | ~1024×768+ | Row of dial + local overflows |
| Short / split | ~400×300 | Country sheet / keyboard overlap |

Also: **RTL**, **text scale ~1.3**, **light + dark**. A `RenderFlex overflowed` is a fail.

## Package-specific checks

- `MreTextField`: BIDI flip while typing Arabic/English; clear button; suggestion chips wrap / scroll without overflow.
- `MrePhoneField`: dial chip + local field on narrow width; pasted `+…` parses without layout jump.
- Country picker sheet: search field + list on phone and tablet; long country names ellipsize.

## Widget tests

Use `tester.view.physicalSize` / `devicePixelRatio` (and reset in `addTearDown`) for each size you claim. Prefer a shared harness under `test/helpers/`.

## Do not

- Ship from a single `tester.view` size or one preview card.
- Hard-code dialog height taller than a short window.
- Leave unbounded `Row` children without `Expanded` / `Flexible` on the growing text field.
