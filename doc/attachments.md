A field can accept pasted images. By default it does not: a field with no
`imagePaste` pastes text only.

## Choose what happens

`MRETextField` takes an `imagePaste` behaviour.

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

// Images appear under the field.
const attachments = MRETextField(
  labelText: 'Message',
  imagePaste: MREImageAttachmentPaste(),
);
```

| Behaviour | Shows | Does |
|---|---|---|
| `MRENoImagePaste` | nothing | Ignores images. The default. |
| `MREImageCallbackPaste` | nothing | Calls `onImagePasted` with each image. |
| `MREImageAttachmentPaste` | thumbnails under the field | Keeps the images, and calls `onImagePasted` and `onImagesChanged`. |

## Keep images under the field

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
  behavior: MREImageAttachmentPaste(),
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
