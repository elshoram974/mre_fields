Texts and fields follow the language of their content, not the app locale.
Arabic reads right to left, English left to right.

## Detect the direction

The first letter with a direction decides. Digits, spaces, punctuation and
emoji are skipped. Only the first 256 code units are read, so long text costs
the same as short text.

<!-- snippet: detect -->
```dart
final arabic = detectTextDirection('مرحبا بالعالم'); // rtl
final english = detectTextDirection('Hello'); // ltr
final mixed = detectTextDirection('123 مرحبا'); // rtl, digits are skipped
final none = detectTextDirection('12345', fallback: TextDirection.rtl); // rtl
```

## Show text in its own direction

`MREAutoText` takes the parameters of `Text`. Set `textDirection` to turn
detection off.

<!-- snippet: auto_text -->
```dart
final column = Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: const [
    MREAutoText('مرحبا بالعالم'), // reads right to left
    MREAutoText('Hello world'), // reads left to right
    MREAutoText('مرحبا', textDirection: TextDirection.ltr), // fixed
  ],
);
```

## Check a string

<!-- snippet: extension_getters -->
```dart
final isRtl = 'مرحبا'.isRtl; // true
final direction = '12345'.directionOr(TextDirection.rtl); // rtl
```

## Flip any widget

`withTextDirection` adds a `Directionality` only when the direction differs from
the surrounding one.

<!-- snippet: with_text_direction -->
```dart
final tile = ListTile(
  leading: const Icon(Icons.person),
  title: Text(name),
).withTextDirection(name);
```

## Remove broken characters

Some keyboards and pastes produce unpaired surrogates. Flutter throws on them
when it lays out the text. `safeDisplayText` replaces each one with U+FFFD and
keeps valid pairs such as emoji.

<!-- snippet: safe_text -->
```dart
final label = Text(safeDisplayText(pasted));
```
