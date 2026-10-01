import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../direction/text_direction.dart';

/// What a text field shows that depends on its text: the direction of the
/// first strong letter (null when there is none) and whether any text exists.
typedef MRETextFieldFlags = ({TextDirection? direction, bool hasText});

/// Returns the flags of [text].
@internal
MRETextFieldFlags mreTextFieldFlagsOf(String text) {
  return (direction: detectStrongTextDirection(text), hasText: text.isNotEmpty);
}

/// Follows a text controller and keeps the [MRETextFieldFlags] of its text.
///
/// The controller notifies on every keystroke and selection change, but the
/// flags change rarely. A listener of this notifier is called only when they
/// do, so a field that listens here rebuilds only then.
@internal
final class MRETextFieldFlagsTracker extends ValueNotifier<MRETextFieldFlags> {
  /// Starts following [controller].
  MRETextFieldFlagsTracker(TextEditingController controller)
    : _controller = controller,
      super(mreTextFieldFlagsOf(controller.text)) {
    controller.addListener(_update);
  }

  TextEditingController _controller;

  /// Follows [controller] instead of the one followed now.
  void follow(TextEditingController controller) {
    _controller.removeListener(_update);
    _controller = controller..addListener(_update);
    _update();
  }

  void _update() {
    value = mreTextFieldFlagsOf(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    super.dispose();
  }
}
