import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Makes the system clipboard hold [text] (or nothing, when null) for the rest
/// of the test.
void mockClipboardText(WidgetTester? tester, String? text) {
  final messenger = tester != null
      ? tester.binding.defaultBinaryMessenger
      : TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.getData') {
      return text == null ? null : {'text': text};
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
}
