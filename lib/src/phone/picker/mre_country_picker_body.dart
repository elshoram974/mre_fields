import 'package:flutter/material.dart';

import '../../text/field/mre_text_field.dart';
import '../../theme/mre_fields_theme.dart';
import '../model/mre_country.dart';

/// Size of a flag emoji in the list.
const double _flagSize = 24;

/// One line of the list: a country, or the line between the favorites and the
/// rest.
sealed class _Row {
  const _Row();
}

final class _CountryRow extends _Row {
  const _CountryRow(this.country, this.name);

  final MRECountry country;
  final String name;
}

final class _DividerRow extends _Row {
  const _DividerRow();
}

/// A searchable list of countries: a title, a search field and the countries.
///
/// This is the content of the picker. Put it in your own sheet or page, or open
/// the ready-made one with [showMRECountryPicker].
///
/// Typing filters by name, ISO code and dial code, ignoring case. Favorites
/// show first while the search is empty.
///
/// {@category Phone}
class MRECountryPickerBody extends StatefulWidget {
  /// Creates the list for [countries].
  const MRECountryPickerBody({
    super.key,
    required this.countries,
    required this.onSelected,
    this.selected,
    this.favorites = const [],
    this.title,
    this.searchHint,
    this.emptyText,
    this.nameBuilder,
    this.showFlags = true,
    this.scrollController,
    this.autofocusSearch = false,
  });

  /// The countries to list.
  final List<MRECountry> countries;

  /// Called with the country the user taps.
  final ValueChanged<MRECountry> onSelected;

  /// The country shown as selected.
  final MRECountry? selected;

  /// Countries pinned at the top while the search is empty.
  final List<MRECountry> favorites;

  /// Title. Defaults to `MREFieldsStrings.countryPickerTitle`.
  final String? title;

  /// Hint of the search field. Defaults to `MREFieldsStrings.countrySearchHint`.
  final String? searchHint;

  /// Text when nothing matches. Defaults to `MREFieldsStrings.noCountriesFound`.
  final String? emptyText;

  /// The name to show for a country, in your language. Search matches it too.
  /// Defaults to the English name.
  final String Function(MRECountry country)? nameBuilder;

  /// Whether to show each country's flag.
  final bool showFlags;

  /// Scroll controller of the list, for a draggable sheet.
  final ScrollController? scrollController;

  /// Whether the search field takes focus when the list opens.
  final bool autofocusSearch;

  @override
  State<MRECountryPickerBody> createState() => _MRECountryPickerBodyState();
}

class _MRECountryPickerBodyState extends State<MRECountryPickerBody> {
  final _search = TextEditingController();
  late List<(_CountryRow, String)> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _buildEntries();
  }

  @override
  void didUpdateWidget(MRECountryPickerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.countries != oldWidget.countries ||
        widget.nameBuilder != oldWidget.nameBuilder) {
      _entries = _buildEntries();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Each country with its lowercase search text, built once.
  List<(_CountryRow, String)> _buildEntries() {
    return [
      for (final country in widget.countries)
        () {
          final name = widget.nameBuilder?.call(country) ?? country.name;
          final key = '$name ${country.isoCode} ${country.dialCodeWithPlus}'
              .toLowerCase();
          return (_CountryRow(country, name), key);
        }(),
    ];
  }

  List<_Row> _rows(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isNotEmpty) {
      return [
        for (final (row, key) in _entries)
          if (key.contains(needle)) row,
      ];
    }

    final pinned = {for (final country in widget.favorites) country};
    final top = [
      for (final (row, _) in _entries)
        if (pinned.contains(row.country)) row,
    ];
    final rest = [
      for (final (row, _) in _entries)
        if (!pinned.contains(row.country)) row,
    ];
    return [
      ...top,
      if (top.isNotEmpty && rest.isNotEmpty) const _DividerRow(),
      ...rest,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final strings = MREFieldsTheme.of(context).strings;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Text(
            widget.title ?? strings.countryPickerTitle,
            style: text.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MRETextField(
            controller: _search,
            hintText: widget.searchHint ?? strings.countrySearchHint,
            prefixIcon: const Icon(Icons.search),
            showClearButton: true,
            autofocus: widget.autofocusSearch,
            textInputAction: TextInputAction.search,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _search,
            builder: (context, value, _) {
              final rows = _rows(value.text);
              if (rows.isEmpty) {
                return Center(
                  child: Text(widget.emptyText ?? strings.noCountriesFound),
                );
              }
              return ListView.builder(
                controller: widget.scrollController,
                itemCount: rows.length,
                itemBuilder: (context, index) => switch (rows[index]) {
                  _DividerRow() => const Divider(height: 1),
                  _CountryRow row => _CountryTile(
                    row: row,
                    selected: row.country == widget.selected,
                    showFlag: widget.showFlags,
                    onTap: () => widget.onSelected(row.country),
                  ),
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.row,
    required this.selected,
    required this.showFlag,
    required this.onTap,
  });

  final _CountryRow row;
  final bool selected;
  final bool showFlag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      leading: showFlag
          ? Text(row.country.flag, style: const TextStyle(fontSize: _flagSize))
          : null,
      title: Text(row.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(row.country.dialCodeWithPlus),
      ),
      onTap: onTap,
    );
  }
}
