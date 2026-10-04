A field can accept pasted images. By default it does not: a field with no
`imagePaste` pastes text only.

## Choose what happens

`MRETextField` and `MRETextFormField` take an `imagePaste` behaviour.

<!-- snippet: behaviors -->
```dart
// Text only. This is the default.
const textOnly = MRETextField(labelText: 'Message');

// Your code gets each image. Nothing is shown.
final callback = MRETextField(
  labelText: 'Message',
  imagePaste: MREImageCallbackPaste(
    onImagePasted: (image) => upload(image.bytes),
  ),
);

// Images appear inside the field.
const attachments = MRETextField(
  labelText: 'Message',
  imagePaste: MREImageAttachmentPaste(),
);
```

| Behaviour | Shows | Does |
|---|---|---|
| `MRENoImagePaste` | nothing | Ignores images. The default. |
| `MREImageCallbackPaste` | nothing | Calls `onImagePasted` with each image. |
| `MREImageAttachmentPaste` | thumbnails inside the field | Keeps the images, and calls `onImagePasted` and `onImagesChanged`. |

## Keep images inside the field

The user can tap a thumbnail to open it full screen, remove it, or replace it
with the image on the clipboard. Limits apply before your callbacks run.

<!-- snippet: attachments -->
```dart
final field = MRETextField(
  labelText: 'Message',
  maxLines: 3,
  imagePaste: MREImageAttachmentPaste(
    maxImages: 4,
    maxBytes: 5 * 1024 * 1024,
    onImagesChanged: (images) => attached = images,
    onImageRejected: (reason, image) => showError(reason),
  ),
);
```

`onImageRejected` gets the reason: `tooLarge`, `wrongType`, `tooMany` or
`unreadable`. The package shows no message of its own.

## Where the image comes from

| Source | Where it works |
|---|---|
| Paste shortcut (Ctrl or Cmd + V) | Desktop, and web through the browser `paste` event |
| Selection menu, "Paste image" | Every platform, when the clipboard holds an image |
| On-screen keyboard: stickers, GIFs, images | Android |

On the web the browser handles Ctrl or Cmd + V itself and fires a `paste`
event. The field listens for it while it has focus, and reads the image from the
event, so no permission prompt appears.

Text on the clipboard always wins. Copying from a document puts text and a
picture on the clipboard, and the field pastes the text.

## Read and change the images from code

<!-- snippet: controller -->
```dart
// Create the controller in initState and dispose it in dispose.
final field = MRETextField(
  labelText: 'Message',
  imagePaste: MREImageAttachmentPaste(controller: controller),
);

// Later: controller.images, controller.removeAt(0), controller.clear().
```

## Open images full screen

<!-- snippet: viewer -->
```dart
final button = TextButton(
  onPressed: () => MREImageViewer.show(context, images: images),
  child: const Text('View images'),
);
```

## Use the pieces alone

The thumbnails work with any controller:

<!-- snippet: strip -->
```dart
final strip = MREAttachmentStrip(
  controller: controller,
  onReplace: (index) {
    // Pick another image, then: controller.replaceAt(index, image).
  },
);
```

And any text field can get image paste:

<!-- snippet: scope -->
```dart
final field = MREImagePasteScope(
  behavior: MREImageCallbackPaste(
    onImagePasted: (image) => upload(image.bytes),
  ),
  builder: (context, hooks) => TextField(
    contentInsertionConfiguration: hooks.contentInsertionConfiguration,
    contextMenuBuilder: hooks.contextMenuBuilder,
  ),
);
```

## Read the clipboard another way

The default reader uses the `pasteboard` plugin. Give a behaviour your own
`MREClipboardImageReader` as `reader` to change that, or to fake the clipboard
in tests.

## Choose your presentation

Attachment behavior places thumbnails above the text, inside the same border.
It inherits the field's focus, error and disabled appearance. Open remains
available in read-only mode; remove, replace and paste require editable input.

Supply a builder for in-field chips, a grid or your own thumbnails. It receives
nullable edit callbacks reflecting the current read-only/enabled state. A host
can still update its own controller programmatically.

<!-- snippet: custom -->
```dart
final field = MRETextField(
  labelText: 'Message',
  imagePaste: MREImageAttachmentPaste(
    controller: controller,
    builder: (context, presentation) => Wrap(
      spacing: 8,
      children: [
        for (var index = 0; index < presentation.controller.count; index++)
          InputChip(
            avatar: Image.memory(
              presentation.controller.images[index].bytes,
              width: 24,
              height: 24,
              cacheWidth: 96,
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.image_not_supported_outlined),
            ),
            label: Text(
              presentation.controller.images[index].name ?? 'Image',
            ),
            onDeleted: presentation.onRemove == null
                ? null
                : () => presentation.onRemove!(index),
          ),
      ],
    ),
  ),
);
```

Use `MREImageCallbackPaste` for uploads or presentation outside the input; it
retains no images and adds no attachment UI. `MREImagePasteScope` exposes
`hooks.attachments` to custom input builders, which decide where it belongs.

Set `showCounter: true` on `MREImageAttachmentPaste` to show the current count
and `maxImages` inside the field, including when empty. The counter is hidden
by default. A custom `builder` receives `controller.count`, `maxImages` and
`isAtLimit`, and runs for an empty collection too, so it can draw its own counter.
Leave `showCounter` false when your builder supplies the counter.
