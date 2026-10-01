import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'mre_suggestion_bar.dart';

/// Space between the field and its suggestions.
const double _suggestionGap = 6;

/// The suggestions under a text field.
///
/// Shows the matches for the text while [focusNode] has focus, and nothing
/// otherwise. It rebuilds on text and focus changes only.
@internal
class MRETextFieldSuggestions extends StatelessWidget {
  /// Creates the suggestions for [controller].
  const MRETextFieldSuggestions({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.limit,
    required this.onSelected,
  });

  /// The text to match.
  final TextEditingController controller;

  /// The focus of the field. Suggestions show only while it has focus.
  final FocusNode focusNode;

  /// Every suggestion.
  final List<String> suggestions;

  /// The most matches to show.
  final int limit;

  /// Called with the suggestion the user picks.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        if (!focusNode.hasFocus) {
          return const SizedBox.shrink();
        }
        final matches = mreFilterSuggestions(
          suggestions,
          controller.text,
          limit: limit,
        );
        if (matches.isEmpty) {
          return const SizedBox.shrink();
        }
        // A tap on a suggestion is a tap inside the field. Without the tap
        // region it would count as a tap outside, unfocus the field, and hide
        // the suggestion before the tap ends.
        return TextFieldTapRegion(
          child: Padding(
            padding: const EdgeInsets.only(top: _suggestionGap),
            child: MRESuggestionBar(
              suggestions: matches,
              onSelected: onSelected,
            ),
          ),
        );
      },
    );
  }
}
