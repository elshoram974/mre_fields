import 'package:flutter/material.dart';

/// Size of the clear icon.
const double _clearIconSize = 20;

/// The small "x" button that empties a field.
///
/// [MRETextField] shows it when `showClearButton` is on. Use it on its own to
/// build a different field:
///
/// {@example /doc/snippets/text_field.dart#clear_button}
///
/// {@category Fields}
class MREFieldClearButton extends StatelessWidget {
  /// Creates a clear button.
  const MREFieldClearButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.icon = Icons.close_rounded,
  });

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// Tooltip and screen reader label. Pass your translated text.
  final String? tooltip;

  /// The icon to show.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: _clearIconSize),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
