# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `MREFieldsTheme` theme extension: field border radius, content padding (compact and expanded), window-size breakpoints, and `MREWindowSize` classification. Works without registration through `MREFieldsTheme.defaults`.
- `MREFieldsStrings`: one immutable set of user-visible texts with English defaults, so hosts can localize every field text.
- Project agent docs: `CLAUDE.md`, Cursor rules, and skills for porting fields from CashBook.
- Regression + field-size rules; Widget Preview harness + skills (no FVM — use PATH Flutter).
- `ROADMAP.md` — ordered steps 1–8 with a concrete plan per step.
- Extensibility rules: host theme colors, overridable params, small composable widgets/helpers.
- Skills: `add-example-app`, `publish-to-pub-dev`; CLAUDE sections for preview / pub.dev / opening the workspace.
- Responsive/adaptive rules for phone–desktop field layouts (constraints, not Platform).
