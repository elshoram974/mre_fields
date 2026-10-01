import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../model/mre_country.dart';

/// Size of the flag.
const double _flagSize = 20;

/// The button inside a phone field that shows the country and opens the
/// picker: flag, dial code and an arrow. It always lays out left to right.
@internal
class MREDialButton extends StatelessWidget {
  /// Creates the button for [country].
  const MREDialButton({
    super.key,
    required this.country,
    required this.name,
    required this.showFlag,
    required this.onPressed,
  });

  /// The chosen country, or null.
  final MRECountry? country;

  /// The country's name in the host's language. Used as the screen reader label.
  final String name;

  /// Whether to show the flag.
  final bool showFlag;

  /// Called to open the picker, or null when the field is disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final current = country;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Semantics(
        button: true,
        label: current == null ? name : '$name ${current.dialCodeWithPlus}',
        excludeSemantics: true,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  if (showFlag && current != null)
                    Text(
                      current.flag,
                      style: const TextStyle(fontSize: _flagSize),
                    ),
                  Text(current?.dialCodeWithPlus ?? '+'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
