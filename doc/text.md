Texts and fields support every Unicode writing system. Arabic and English are
examples alongside Hebrew, Persian, Urdu, Cyrillic, Greek, Indic, CJK and
supplementary-plane scripts. Font coverage remains the host application's job.

## How the direction is chosen

The first strong Unicode Bidi_Class character (L, R or AL) decides. The data is
pinned to Unicode 17.0.0, with no language allowlist. This detects direction,
not the language of a sentence.

- Weak/neutral characters do not decide: `،Hello` is LTR and `。שלום` is RTL.
- Combining marks and emoji are skipped; isolated content does not decide the
  outer direction. Some punctuation, such as Arabic `؟`, is strong in Unicode
  and retains its assigned direction.
- Mixed text follows its first strong character; an explicit direction wins.
- Without a strong character, widgets keep ambient direction; pure helpers use
  their explicit fallback (LTR by default).
- Only the first 256 UTF-16 code units are read, decoding complete pairs only.
  Letters beyond the cap are ignored. This is a bounded paragraph-direction
  heuristic; Flutter handles visual bidirectional layout.

<!-- snippet: detect -->
```dart
final arabic = detectTextDirection('مرحبا بالعالم'); // rtl
final english = detectTextDirection('Hello'); // ltr
final mixed = detectTextDirection('123 مرحبا'); // rtl, digits are skipped
final symbols = detectTextDirection('(#1) مرحبا'); // rtl, symbols are skipped
final none = detectTextDirection('12345', fallback: TextDirection.rtl); // rtl
```

## Show text in its own direction

`MREAutoText` takes every parameter of `Text`: style, lines, overflow, scaling
and the rest. Set `textDirection` to turn detection off.

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

## Style it like any Text

<!-- snippet: styled -->
```dart
final text = MREAutoText(
  'مرحبا بالعالم',
  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  autoAlign: true, // pins the text to the side its content starts on
);
```

`autoAlign` pins the text to the side its content starts on. Without it,
`TextAlign.start` already follows the detected direction.

## Use it on a Text you already have

`autoDirection()` and `autoAlign()` copy the `Text` with every property kept.
A value you set yourself is never replaced.

<!-- snippet: text_extension -->
```dart
final text = Text(
  name,
  style: const TextStyle(fontSize: 20),
).autoDirection().autoAlign();
```

## Get the direction or the alignment of a string

<!-- snippet: extension_getters -->
```dart
final isRtl = 'مرحبا'.isRtl; // true
final direction = '12345'.directionOr(TextDirection.rtl); // rtl
```

<!-- snippet: align_getter -->
```dart
final arabic = 'مرحبا'.autoTextAlign; // TextAlign.right
final english = 'Hello'.autoTextAlign; // TextAlign.left
final digits = '12345'.autoTextAlign; // TextAlign.start
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
