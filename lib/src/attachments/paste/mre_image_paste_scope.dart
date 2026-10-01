import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../internal/mre_owned.dart';
import '../../theme/mre_fields_theme.dart';
import '../ui/mre_attachment_strip.dart';
import '../model/mre_attachments_controller.dart';
import 'mre_image_paste_behavior.dart';
import 'mre_image_paste_handler.dart';
import 'mre_paste_image_action.dart';
import 'mre_paste_image_menu.dart';
import 'paste_events_stub.dart'
    if (dart.library.js_interop) 'paste_events_web.dart';

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
  MREOwned<MREAttachmentsController>? _own;

  /// Stops the web `paste` listener. Null while the field has no focus.
  VoidCallback? _stopPasteEvents;

  MREImagePasteBehavior get _behavior => widget.behavior;

  MREAttachmentsController? get _controller =>
      _behavior.attachments?.controller ?? _own?.value;

  MREImagePasteHandler get _handler => MREImagePasteHandler(
    behavior: _behavior,
    controller: _controller,
    isActive: () => mounted,
  );

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
    _stopPasteEvents?.call();
    _own?.dispose();
    super.dispose();
  }

  /// Keeps an own controller exactly while the behaviour shows attachments and
  /// brings no controller of its own.
  void _syncOwnController() {
    final config = _behavior.attachments;
    final needsOwn = config != null && config.controller == null;
    if (needsOwn && _own == null) {
      _own = MREOwned(null, MREAttachmentsController.new);
    } else if (!needsOwn && _own != null) {
      _own!.disposeAfterFrame();
      _own = null;
    }
  }

  /// On the web the browser handles the paste shortcut, so images arrive in a
  /// `paste` event. Listen for it only while the field has focus, so two fields
  /// never both take the same image.
  void _onFocusChange(bool hasFocus) {
    _stopPasteEvents?.call();
    _stopPasteEvents = null;
    if (hasFocus) {
      final handler = _handler;
      _stopPasteEvents = mreListenForPastedImages(
        (image) => handler.accept(
          handler.behavior.imageFromBytes(image.bytes, image.mimeType),
        ),
      );
    }
  }

  /// Reports focus entering and leaving the field. Only the web needs it.
  Widget _focusScope(Widget child) {
    if (!kIsWeb) {
      return child;
    }
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: _onFocusChange,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_behavior.acceptsImages) {
      return widget.builder(context, MREImagePasteHooks.none);
    }

    final handler = _handler;
    final strings = MREFieldsTheme.of(context).strings;
    final field = Actions(
      actions: {PasteTextIntent: MREPasteImageAction(handler)},
      child: _focusScope(
        widget.builder(
          context,
          MREImagePasteHooks(
            contentInsertionConfiguration: ContentInsertionConfiguration(
              allowedMimeTypes: _behavior.allowedMimeTypes,
              onContentInserted: handler.keyboardContent,
            ),
            contextMenuBuilder: (context, state) => MREPasteImageMenu(
              state: state,
              handler: handler,
              label: strings.pasteImageLabel,
            ),
          ),
        ),
      ),
    );

    final config = _behavior.attachments;
    final controller = _controller;
    if (config == null || controller == null) {
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
          onRemove: handler.remove,
          onReplace: config.allowReplace ? handler.replace : null,
        ),
      ],
    );
  }
}
