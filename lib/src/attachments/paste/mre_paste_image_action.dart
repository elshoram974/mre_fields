import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'mre_image_paste_handler.dart';

/// Replaces the paste action of the text field below it.
///
/// The field's own paste stays reachable as [callingAction]. It runs when the
/// clipboard has text or no image, so text paste is never lost.
@internal
class MREPasteImageAction extends ContextAction<PasteTextIntent> {
  /// Creates the action for [handler].
  MREPasteImageAction(this.handler);

  /// Decides what a paste does.
  final MREImagePasteHandler handler;

  @override
  Future<void> invoke(PasteTextIntent intent, [BuildContext? context]) {
    final textPaste = callingAction;
    return handler.pasteShortcut(() {
      if (textPaste != null && textPaste.isEnabled(intent)) {
        textPaste.invoke(intent);
      }
    });
  }
}
