import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// One Material input surface containing attachments followed by editable text.
@internal
class MRETextComposer extends StatelessWidget {
  /// Creates a composer using the host's input decoration.
  const MRETextComposer({
    super.key,
    required this.decoration,
    required this.focusNode,
    required this.attachments,
    required this.child,
    required this.expands,
  });

  /// The shared border, label, helper, error, prefix and suffix.
  final InputDecoration decoration;

  /// Focus of the text editor, which controls the shared border.
  final FocusNode focusNode;

  /// Images, or an empty widget when there are none.
  final Widget attachments;

  /// The undecorated text editor.
  final Widget child;

  /// Whether the editor fills bounded vertical space.
  final bool expands;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) => InputDecorator(
        decoration: decoration,
        isFocused: focusNode.hasFocus,
        // A composer label stays above its mixed content, including images.
        isEmpty: false,
        child: Column(
          mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            attachments,
            if (expands) Expanded(child: child) else child,
          ],
        ),
      ),
    );
  }
}
