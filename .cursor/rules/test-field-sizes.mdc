---
description: Field widgets must be tested at multiple sizes, RTL, text scale, brightness, and desktop widths
globs: "lib/**/*.dart,test/**/*.dart"
alwaysApply: true
---
# Test field widgets at every size

See **responsive-adaptive.mdc** for how to build. This rule is the **verification** gate.

A field change is **not done** when it looks right in one phone-width pump.

## Before you declare done

Pump (or preview) **all** of:

| Surface | Approx. size | What usually breaks |
|---|---|---|
| Phone | ~390×844 | Baseline — do not stop here |
| Tablet portrait | ~834×1112 | Wide stretch; prefix/suffix misalign |
| Desktop / landscape | ~1024×768+ | Phone sheet on huge window; dial+local overflow |
| Short / split | ~400×300 | Sheet taller than window; keyboard overlap |

Also: **RTL**, **text scale ~1.3**, **light + dark**. A `RenderFlex overflowed` is a fail.

## Package-specific checks

- `MRETextField`: BIDI; clear; suggestions wrap/scroll; no clip at 1.3 scale.
- `MREPhoneField`: compact vs expanded dial/local layout; paste `+…` without jump.
- Country UI: sheet on compact, **dialog (max width)** on expanded; long names ellipsize.

## Widget tests

Use `tester.view.physicalSize` / `devicePixelRatio` (reset in `addTearDown`). Shared harness under `test/helpers/`. Include at least one expanded-width test for phone field / picker when those exist.

## Do not

- Ship from a single `tester.view` size or one preview card.
- Hard-code dialog/sheet height taller than a short window.
- Leave unbounded `Row` children without `Expanded` / `Flexible` on the growing text.
