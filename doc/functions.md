Every rule behind the widgets is also a plain function or class. Use them in a
view model, a report, a validator or a test, with no widget on screen.

## Everything you can call without a widget

| Name | Kind | Does |
|---|---|---|
| `detectTextDirection(text, fallback:)` | function | Direction of the first word with a letter, or the fallback |
| `detectStrongTextDirection(text)` | function | The same, but `null` when there is no letter |
| `String.textDirection`, `isRtl`, `directionOr`, `autoTextAlign` | extension | The same checks as getters |
| `safeDisplayText(text)` | function | Replaces unpaired surrogates that make Flutter throw |
| `mreFilterSuggestions(all, query, limit:)` | function | The suggestions that match a query, ignoring case |
| `mreSniffImageMimeType(bytes)` | function | The image type from the first bytes, or `null` |
| `MREPastedImage` | class | An image as bytes, type and name |
| `MREAttachmentsController` | class | Holds, adds, removes and replaces images, and notifies |
| `MREImagePasteBehavior` and its three subclasses | classes | The rules for limits and callbacks |
| `MREClipboardImageReader` | interface | Reads the clipboard; fake it in tests |
| `MREFieldsTheme`, `MREFieldsStrings`, `MREWindowSize` | classes | Tokens and texts; `windowSizeFor(width)` classifies a width |

## Text direction

<!-- snippet: direction_functions -->
```dart
final direction = detectTextDirection(name, fallback: TextDirection.ltr);
final strong = detectStrongTextDirection(name); // null when no letter
final side = name.autoTextAlign;
```

<!-- snippet: getters -->
```dart
final rtl = text.isRtl;
final fallback = text.directionOr(TextDirection.ltr);
```

## Clean text

<!-- snippet: sanitize -->
```dart
final clean = safeDisplayText(pasted); // lone surrogates become U+FFFD
```

## Filter suggestions

<!-- snippet: filter -->
```dart
const cities = ['Cairo', 'Alexandria', 'Giza', 'Luxor', 'Aswan'];
final matches = mreFilterSuggestions(cities, query, limit: 3);
```

## Check an image

<!-- snippet: sniff -->
```dart
final type = mreSniffImageMimeType(
  upload,
); // 'image/png', 'image/jpeg', ... or null
final isPng = type == 'image/png';
```

## Keep images without a widget

<!-- snippet: collect -->
```dart
final controller = MREAttachmentsController();
for (final image in pasted) {
  controller.add(image);
}
controller.addListener(() {
  // Runs on every add, remove and replace.
});
```
