import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/mre_fields_theme.dart';
import 'mre_attachment_strip.dart';
import 'mre_attachments_controller.dart';
import 'mre_image_paste_behavior.dart';
import 'mre_pasted_image.dart';

/// Space between the field and the attached images.
const double _stripGap = 8;

/// The text field parameters that carry image paste.
///
/// Pass them to the [TextField] or [TextFormField] built inside
/// [MREImagePasteScope].
///
/// {@category Attachments}
@immutable
class MREImagePasteHooks {
  /// Creates the hooks.
  const MREImagePasteHooks({
    this.contentInsertionConfiguration,
    this.contextMenuBuilder,
  });

  /// No hooks. Used when the behaviour accepts no images.
  static const MREImagePasteHooks none = MREImagePasteHooks();

  /// Receives images from the on-screen keyboard (stickers, GIFs, images).
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// A text selection menu with a "paste image" item.
  final EditableTextContextMenuBuilder? contextMenuBuilder;
}

/// Builds the field inside an [MREImagePasteScope].
typedef MREImagePasteBuilder =
    Widget Function(BuildContext context, MREImagePasteHooks hooks);

/// Adds image paste to a text field.
///
/// It handles the paste shortcut and the on-screen keyboard, adds a "paste
/// image" item to the selection menu, and shows the attached images under the
/// field when the [behavior] asks for it. A normal text paste is never
/// replaced: the shortcut pastes text when the clipboard holds text.
///
/// [MRETextField] uses it. Use it yourself to give your own field the same
/// behaviour:
///
/// {@example /doc/snippets/attachments.dart#scope}
///
/// With [MRENoImagePaste] it adds nothing around the field.
///
/// {@category Attachments}
class MREImagePasteScope extends StatefulWidget {
  /// Creates a scope for [behavior].
  const MREImagePasteScope({
    super.key,
    required this.behavior,
    required this.builder,
  });

  /// What to do with pasted images.
  final MREImagePasteBehavior behavior;

  /// Builds the field. Give it the [MREImagePasteHooks].
  final MREImagePasteBuilder builder;

  @override
  State<MREImagePasteScope> createState() => _MREImagePasteScopeState();
}

class _MREImagePasteScopeState extends State<MREImagePasteScope> {
  /// The controller the scope keeps when the behaviour gives none.
  MREAttachmentsController? _ownController;

  MREImagePasteBehavior get _behavior => widget.behavior;

  MREAttachmentsController? get _controller =>
      _behavior.controller ?? _ownController;

  @override
  void initState() {
    super.initState();
    _syncOwnController();
  }

  @override
  void didUpdateWidget(MREImagePasteScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOwnController();
  }

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  /// Keeps an own controller exactly while the behaviour shows attachments and
  /// brings no controller of its own.
  void _syncOwnController() {
    final needsOwn = _behavior.showsAttachments && _behavior.controller == null;
    if (needsOwn && _ownController == null) {
      _ownController = MREAttachmentsController();
    } else if (!needsOwn && _ownController != null) {
      final old = _ownController!;
      _ownController = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  /// Checks [image] against the limits and keeps it, or reports why not.
  void _accept(MREPastedImage image, {int? replacing}) {
    final controller = _controller;
    final held = (controller?.count ?? 0) - (replacing == null ? 0 : 1);
    final reason = _behavior.check(image, count: held);
    if (reason != null) {
      _behavior.onImageRejected?.call(reason, image);
      return;
    }

    if (controller != null) {
      if (replacing == null) {
        controller.add(image);
      } else {
        controller.replaceAt(replacing, image);
      }
      _behavior.imagesChanged(controller.images);
    }
    _behavior.onImagePasted?.call(image);
  }

  /// Reads the clipboard image. A platform that cannot be read is reported as
  /// [MREImageRejection.unreadable].
  Future<MREPastedImage?> _readClipboardImage() async {
    try {
      return await _behavior.reader.read();
    } on PlatformException {
      _behavior.onImageRejected?.call(MREImageRejection.unreadable, null);
    } on MissingPluginException {
      _behavior.onImageRejected?.call(MREImageRejection.unreadable, null);
    }
    return null;
  }

  /// The paste shortcut. Text on the clipboard always wins, so a copy from a
  /// document, which holds text and a picture, pastes as text.
  Future<void> _paste(VoidCallback pasteText) async {
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) {
      return;
    }
    if (text?.text?.isNotEmpty ?? false) {
      pasteText();
      return;
    }

    final image = await _readClipboardImage();
    if (!mounted) {
      return;
    }
    if (image == null) {
      pasteText();
      return;
    }
    _accept(image);
  }

  void _onKeyboardContent(KeyboardInsertedContent content) {
    final data = content.data;
    if (data == null || data.isEmpty) {
      _behavior.onImageRejected?.call(MREImageRejection.unreadable, null);
      return;
    }
    _accept(_behavior.imageFromBytes(data, content.mimeType));
  }

  Future<void> _replace(int index) async {
    final image = await _readClipboardImage();
    if (!mounted) {
      return;
    }
    if (image == null) {
      _behavior.onImageRejected?.call(MREImageRejection.unreadable, null);
      return;
    }
    _accept(image, replacing: index);
  }

  void _remove(int index) {
    final controller = _controller!;
    controller.removeAt(index);
    _behavior.imagesChanged(controller.images);
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState state) {
    return _PasteImageMenu(
      state: state,
      read: _readClipboardImage,
      label: MREFieldsTheme.of(context).strings.pasteImageLabel,
      onPaste: _accept,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_behavior.acceptsImages) {
      return widget.builder(context, MREImagePasteHooks.none);
    }

    final field = Actions(
      actions: {PasteTextIntent: _PasteImageAction(_paste)},
      child: widget.builder(
        context,
        MREImagePasteHooks(
          contentInsertionConfiguration: ContentInsertionConfiguration(
            allowedMimeTypes: _behavior.allowedMimeTypes,
            onContentInserted: _onKeyboardContent,
          ),
          contextMenuBuilder: _buildContextMenu,
        ),
      ),
    );

    final controller = _controller;
    if (!_behavior.showsAttachments || controller == null) {
      return field;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        field,
        const SizedBox(height: _stripGap),
        MREAttachmentStrip(
          controller: controller,
          onRemove: _remove,
          onReplace: _behavior.allowsReplace ? _replace : null,
        ),
      ],
    );
  }
}

/// Replaces the paste action of the text field below it. Falls back to the
/// field's own text paste when there is no image.
class _PasteImageAction extends ContextAction<PasteTextIntent> {
  _PasteImageAction(this._paste);

  final Future<void> Function(VoidCallback pasteText) _paste;

  @override
  Future<void> invoke(PasteTextIntent intent, [BuildContext? context]) {
    final textPaste = callingAction;
    return _paste(() {
      if (textPaste != null && textPaste.isEnabled(intent)) {
        textPaste.invoke(intent);
      }
    });
  }
}

/// The selection menu with a "paste image" item when the clipboard holds one.
class _PasteImageMenu extends StatefulWidget {
  const _PasteImageMenu({
    required this.state,
    required this.read,
    required this.label,
    required this.onPaste,
  });

  final EditableTextState state;
  final Future<MREPastedImage?> Function() read;
  final String label;
  final ValueChanged<MREPastedImage> onPaste;

  @override
  State<_PasteImageMenu> createState() => _PasteImageMenuState();
}

class _PasteImageMenuState extends State<_PasteImageMenu> {
  late final Future<MREPastedImage?> _image = widget.read();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MREPastedImage?>(
      future: _image,
      builder: (context, snapshot) {
        final image = snapshot.data;
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: widget.state.contextMenuAnchors,
          buttonItems: [
            ...widget.state.contextMenuButtonItems,
            if (image != null)
              ContextMenuButtonItem(
                label: widget.label,
                onPressed: () {
                  ContextMenuController.removeAny();
                  widget.onPaste(image);
                },
              ),
          ],
        );
      },
    );
  }
}
