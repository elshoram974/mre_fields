import 'package:flutter/widgets.dart';

import 'text_direction.dart';

/// Gives a widget the direction of a sample text.
///
/// {@category Text}
extension MREDirectionalWidget on Widget {
  /// Wraps this widget in a [Directionality] that follows [sample].
  ///
  /// No wrapper is added when the direction already matches the surrounding
  /// one. Text without a strong letter keeps the surrounding direction.
  ///
  /// {@example /doc/snippets/text.dart#with_text_direction}
  Widget withTextDirection(String sample) {
    return Builder(
      builder: (context) {
        final ambient = Directionality.of(context);
        final direction = detectTextDirection(sample, fallback: ambient);
        if (direction == ambient) {
          return this;
        }
        return Directionality(textDirection: direction, child: this);
      },
    );
  }
}
