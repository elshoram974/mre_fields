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

const double _attachmentsSpacing = 12;

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
    this.attachments,
  });

  /// Optional attachments, to place inside the host input decoration.
  final Widget? attachments;

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
/// image" item to the selection menu, and shows the attached images inside the
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
    this.enabled = true,
  });

  /// Whether user actions may change images. Existing images remain visible.
  final bool enabled;

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

  int _generation = 0;
  bool _hasFocus = false;

  /// Stops the web `paste` listener. Null while the field has no focus.
  VoidCallback? _stopPasteEvents;

  MREImagePasteBehavior get _behavior => widget.behavior;

  MREAttachmentsController? get _controller =>
      _behavior.attachments?.controller ?? _own?.value;

  MREImagePasteHandler get _handler {
    final generation = _generation;
    return MREImagePasteHandler(
      behavior: _behavior,
      controller: _controller,
      isActive: () =>
          mounted &&
          widget.enabled &&
          _behavior.acceptsImages &&
          generation == _generation,
    );
  }

  @override
  void initState() {
    super.initState();
    _syncOwnController();
  }

  @override
  void didUpdateWidget(MREImagePasteScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.behavior != widget.behavior ||
        oldWidget.enabled != widget.enabled) {
      _generation++;
      _syncOwnController();
      _onFocusChange(_hasFocus);
    }
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
    _hasFocus = hasFocus;
    _stopPasteEvents?.call();
    _stopPasteEvents = null;
    if (hasFocus && widget.enabled && _behavior.acceptsImages) {
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
    final config = _behavior.attachments;
    final controller = _controller;
    final attachments = config == null || controller == null
        ? null
        : ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.isEmpty &&
                  !config.showCounter &&
                  config.builder == null) {
                return const SizedBox.shrink();
              }
              final presentation = MREAttachmentsPresentation(
                controller: controller,
                maxImages: config.maxImages,
                onRemove: widget.enabled ? handler.remove : null,
                onReplace: widget.enabled && config.allowReplace
                    ? handler.replace
                    : null,
              );
              final content =
                  config.builder?.call(context, presentation) ??
                  MREAttachmentStrip(
                    controller: controller,
                    editable: widget.enabled,
                    onRemove: presentation.onRemove,
                    onReplace: presentation.onReplace,
                  );
              return Padding(
                padding: const EdgeInsets.only(bottom: _attachmentsSpacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!controller.isEmpty || config.builder != null) content,
                    if (config.showCounter)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          '${controller.images.length} / ${config.maxImages}',
                          textDirection: TextDirection.ltr,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
    final hooks = MREImagePasteHooks(
      attachments: attachments,
      contentInsertionConfiguration: widget.enabled
          ? ContentInsertionConfiguration(
              allowedMimeTypes: _behavior.allowedMimeTypes,
              onContentInserted: handler.keyboardContent,
            )
          : null,
      contextMenuBuilder: widget.enabled
          ? (context, state) => MREPasteImageMenu(
              state: state,
              handler: handler,
              label: strings.pasteImageLabel,
            )
          : null,
    );
    return TextFieldTapRegion(
      child: Actions(
        actions: {
          if (widget.enabled) PasteTextIntent: MREPasteImageAction(handler),
        },
        child: _focusScope(widget.builder(context, hooks)),
      ),
    );
  }
}
