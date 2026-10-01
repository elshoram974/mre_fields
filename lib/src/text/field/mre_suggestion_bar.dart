import 'package:flutter/material.dart';

/// Space between two suggestion chips.
const double _suggestionSpacing = 8;

/// Returns the suggestions in [all] that match [query], at most [limit].
///
/// A suggestion matches when it contains [query], ignoring case, and is not
/// equal to it. An empty [query] matches everything. The search stops as soon
/// as [limit] matches are found.
///
/// {@category Fields}
List<String> mreFilterSuggestions(
  List<String> all,
  String query, {
  int limit = 20,
}) {
  final needle = query.trim().toLowerCase();
  final matches = <String>[];

  for (final suggestion in all) {
    if (matches.length >= limit) {
      break;
    }
    final lower = suggestion.toLowerCase();
    if (needle.isEmpty || (lower.contains(needle) && lower != needle)) {
      matches.add(suggestion);
    }
  }
  return matches;
}

/// A row of tappable suggestions that scrolls sideways.
///
/// It sizes itself to the text, so it does not clip at large text scales.
/// [MRETextField] shows it under the field while the field has focus.
///
/// {@example /doc/snippets/text_field.dart#suggestion_bar}
///
/// {@category Fields}
class MRESuggestionBar extends StatelessWidget {
  /// Creates a suggestion bar.
  const MRESuggestionBar({
    super.key,
    required this.suggestions,
    required this.onSelected,
    this.itemBuilder,
  });

  /// The suggestions to show, in order.
  final List<String> suggestions;

  /// Called with the suggestion the user taps.
  final ValueChanged<String> onSelected;

  /// Builds one suggestion. Defaults to an [ActionChip]. Call `select` when the
  /// user picks it.
  final Widget Function(
    BuildContext context,
    String suggestion,
    VoidCallback select,
  )?
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: _suggestionSpacing,
        children: [
          for (final suggestion in suggestions)
            itemBuilder?.call(
                  context,
                  suggestion,
                  () => onSelected(suggestion),
                ) ??
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () => onSelected(suggestion),
                ),
        ],
      ),
    );
  }
}
