import 'package:flutter/foundation.dart';

/// User-visible text used by the field widgets.
///
/// Every value defaults to English. Replace any of them to localize the
/// fields; the package ships no translations of its own.
///
/// Register the strings next to the rest of your theme:
///
/// ```dart
/// ThemeData(
///   extensions: [
///     MREFieldsTheme(
///       strings: MREFieldsStrings(
///         clearTooltip: l10n.clear,
///         countrySearchHint: l10n.searchCountry,
///       ),
///     ),
///   ],
/// );
/// ```
///
/// A widget parameter always wins over these values, and these values win
/// over the English defaults.
///
/// See also [MREFieldsTheme.strings], where these values are registered.
///
/// {@category Theme}
@immutable
class MREFieldsStrings {
  /// Creates a set of field strings. Omitted values keep their English default.
  const MREFieldsStrings({
    this.clearTooltip = 'Clear',
    this.countryPickerTitle = 'Select country',
    this.countrySearchHint = 'Search country or code',
    this.noCountriesFound = 'No countries found',
    this.removeImageTooltip = 'Remove image',
    this.replaceImageTooltip = 'Replace image',
    this.closeViewerTooltip = 'Close',
  });

  /// Tooltip and semantics label of the clear button.
  final String clearTooltip;

  /// Title of the country picker.
  final String countryPickerTitle;

  /// Hint of the country picker search field.
  final String countrySearchHint;

  /// Text shown when the country search has no result.
  final String noCountriesFound;

  /// Tooltip and semantics label of the remove button on a pasted image.
  final String removeImageTooltip;

  /// Tooltip and semantics label of the replace button on a pasted image.
  final String replaceImageTooltip;

  /// Tooltip and semantics label of the close button in the image viewer.
  final String closeViewerTooltip;

  /// Returns a copy with the given values replaced.
  MREFieldsStrings copyWith({
    String? clearTooltip,
    String? countryPickerTitle,
    String? countrySearchHint,
    String? noCountriesFound,
    String? removeImageTooltip,
    String? replaceImageTooltip,
    String? closeViewerTooltip,
  }) {
    return MREFieldsStrings(
      clearTooltip: clearTooltip ?? this.clearTooltip,
      countryPickerTitle: countryPickerTitle ?? this.countryPickerTitle,
      countrySearchHint: countrySearchHint ?? this.countrySearchHint,
      noCountriesFound: noCountriesFound ?? this.noCountriesFound,
      removeImageTooltip: removeImageTooltip ?? this.removeImageTooltip,
      replaceImageTooltip: replaceImageTooltip ?? this.replaceImageTooltip,
      closeViewerTooltip: closeViewerTooltip ?? this.closeViewerTooltip,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MREFieldsStrings &&
        other.clearTooltip == clearTooltip &&
        other.countryPickerTitle == countryPickerTitle &&
        other.countrySearchHint == countrySearchHint &&
        other.noCountriesFound == noCountriesFound &&
        other.removeImageTooltip == removeImageTooltip &&
        other.replaceImageTooltip == replaceImageTooltip &&
        other.closeViewerTooltip == closeViewerTooltip;
  }

  @override
  int get hashCode => Object.hash(
    clearTooltip,
    countryPickerTitle,
    countrySearchHint,
    noCountriesFound,
    removeImageTooltip,
    replaceImageTooltip,
    closeViewerTooltip,
  );
}
