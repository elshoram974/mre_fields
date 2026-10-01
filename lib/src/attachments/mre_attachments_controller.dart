import 'package:flutter/foundation.dart';

import 'mre_pasted_image.dart';

/// The images attached to a field.
///
/// Pass one to [MREImageAttachmentPaste] to read or change the images from
/// your code. Without one, the field keeps its own.
///
/// {@example /doc/snippets/attachments.dart#controller}
///
/// Dispose a controller you create.
///
/// {@category Attachments}
class MREAttachmentsController extends ChangeNotifier {
  /// Creates a controller, optionally with some [images] to start with.
  MREAttachmentsController({Iterable<MREPastedImage> images = const []})
    : _images = List.of(images);

  final List<MREPastedImage> _images;

  /// The attached images, in order. The list cannot be changed.
  List<MREPastedImage> get images => List.unmodifiable(_images);

  /// How many images are attached.
  int get count => _images.length;

  /// Whether no image is attached.
  bool get isEmpty => _images.isEmpty;

  /// Attaches [image] after the others.
  void add(MREPastedImage image) {
    _images.add(image);
    notifyListeners();
  }

  /// Removes the image at [index].
  void removeAt(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  /// Replaces the image at [index] with [image].
  void replaceAt(int index, MREPastedImage image) {
    _images[index] = image;
    notifyListeners();
  }

  /// Removes every image.
  void clear() {
    if (_images.isEmpty) {
      return;
    }
    _images.clear();
    notifyListeners();
  }
}
