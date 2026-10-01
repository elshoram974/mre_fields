Colors, typography and input chrome come from your own `ThemeData`. This
package only adds the tokens Material does not model, and lets you change
them at three levels.

## Levels, highest priority first

1. **One field.** Pass the matching constructor parameter to that widget.
   Only that widget changes.
2. **Your whole app.** Register `MREFieldsTheme` on `ThemeData.extensions`.
   Every field below that theme changes.
3. **Package defaults.** Used when you register nothing. See
   `MREFieldsTheme.defaults`.

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: hostScheme,
    extensions: const [
      MREFieldsTheme(fieldBorderRadius: 16),
    ],
  ),
);
```

## Responsive tokens

Fields classify the width they really have (not the screen) with
`MREFieldsTheme.windowSizeFor` and pick spacing from it:

- below `MREFieldsTheme.compactBreakpoint`: `MREWindowSize.compact`
- up to `MREFieldsTheme.expandedBreakpoint`: `MREWindowSize.medium`
- from there: `MREWindowSize.expanded`, which uses
  `MREFieldsTheme.expandedContentPadding`

## Localization

Every text a field shows lives in `MREFieldsStrings`. Defaults are English.
Pass your translated values through `MREFieldsTheme.strings`.
