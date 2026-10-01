import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// A [ChangeNotifier] that a widget either received from its host or created
/// itself.
///
/// A widget disposes only what it created. Use one for each controller or focus
/// node a widget accepts as an optional parameter.
@internal
final class MREOwned<T extends ChangeNotifier> {
  /// Uses [given] when it is not null, otherwise calls [create].
  MREOwned(T? given, T Function() create)
    : value = given ?? create(),
      isCreated = given == null;

  /// The notifier to use.
  final T value;

  /// Whether this object created [value], and so must dispose it.
  final bool isCreated;

  /// Disposes [value] when this object created it.
  void dispose() {
    if (isCreated) {
      value.dispose();
    }
  }

  /// Disposes [value] after the current frame, when this object created it.
  ///
  /// Use it for a notifier that a widget below still listens to while the
  /// current frame builds.
  void disposeAfterFrame() {
    if (isCreated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => value.dispose());
    }
  }
}
