import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/src/text/field/mre_text_field_flags.dart';

void main() {
  test('flags of a text', () {
    expect(mreTextFieldFlagsOf(''), (direction: null, hasText: false));
    expect(mreTextFieldFlagsOf('12'), (direction: null, hasText: true));
    expect(mreTextFieldFlagsOf('Hello'), (
      direction: TextDirection.ltr,
      hasText: true,
    ));
    expect(mreTextFieldFlagsOf('مرحبا'), (
      direction: TextDirection.rtl,
      hasText: true,
    ));
  });

  group('MRETextFieldFlagsTracker', () {
    test('starts with the flags of the current text', () {
      final controller = TextEditingController(text: 'مرحبا');
      addTearDown(controller.dispose);
      final tracker = MRETextFieldFlagsTracker(controller);
      addTearDown(tracker.dispose);

      expect(tracker.value, (direction: TextDirection.rtl, hasText: true));
    });

    test('notifies only when the flags change', () {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final tracker = MRETextFieldFlagsTracker(controller);
      addTearDown(tracker.dispose);
      var notifications = 0;
      tracker.addListener(() => notifications++);

      controller.text = 'H';
      controller.text = 'He';
      controller.text = 'Hel';
      controller.selection = const TextSelection.collapsed(offset: 1);
      expect(notifications, 1, reason: 'empty to ltr text, then no change');

      controller.text = 'مرحبا';
      expect(notifications, 2);

      controller.text = '';
      expect(notifications, 3);
    });

    test('follows another controller', () {
      final first = TextEditingController(text: 'Hello');
      final second = TextEditingController(text: 'مرحبا');
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      final tracker = MRETextFieldFlagsTracker(first);
      addTearDown(tracker.dispose);

      tracker.follow(second);
      expect(tracker.value.direction, TextDirection.rtl);

      first.text = 'changed';
      expect(
        tracker.value.direction,
        TextDirection.rtl,
        reason: 'first is no longer followed',
      );

      second.text = 'Hello';
      expect(tracker.value.direction, TextDirection.ltr);
    });

    test('stops following when disposed', () {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final tracker = MRETextFieldFlagsTracker(controller);

      tracker.dispose();

      expect(() => controller.text = 'x', returnsNormally);
    });
  });
}
