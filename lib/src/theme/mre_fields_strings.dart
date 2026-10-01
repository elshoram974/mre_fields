import 'package:flutter/foundation.dart';

/// Texts shown by the fields. English by default; the package has no
/// translations.
///
/// Replace the texts when the app locale changes:
///
/// {@example /doc/snippets/theme.dart#strings}
///
/// Order of priority: a widget parameter, then [MREFieldsTheme.strings], then
/// the English default.
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
    this.pasteImageLabel = 'Paste image',
    this.attachedImageLabel = 'Attached image',
    this.phoneEmpty = 'Enter a phone number',
    this.phoneTooShort = 'The phone number is too short',
    this.phoneTooLong = 'The phone number is too long',
    this.phoneInvalid = 'This is not a valid phone number',
    this.phoneUnknownCountry = 'Unknown country code',
    this.phoneCountryNotAllowed = 'Numbers from this country are not accepted',
    this.phoneMissingCountry = 'Choose a country',
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

  /// Label of the "paste image" item in the text selection menu.
  final String pasteImageLabel;

  /// Semantics label of an attached image thumbnail.
  final String attachedImageLabel;

  /// Error when no phone number was entered.
  final String phoneEmpty;

  /// Error when a phone number has too few digits.
  final String phoneTooShort;

  /// Error when a phone number has too many digits.
  final String phoneTooLong;

  /// Error when a phone number does not match the country's patterns.
  final String phoneInvalid;

  /// Error when the dial code belongs to no country.
  final String phoneUnknownCountry;

  /// Error when the number is from a country the field does not accept.
  final String phoneCountryNotAllowed;

  /// Error when no country was chosen.
  final String phoneMissingCountry;

  /// Returns a copy with the given values replaced.
  MREFieldsStrings copyWith({
    String? clearTooltip,
    String? countryPickerTitle,
    String? countrySearchHint,
    String? noCountriesFound,
    String? removeImageTooltip,
    String? replaceImageTooltip,
    String? closeViewerTooltip,
    String? pasteImageLabel,
    String? attachedImageLabel,
    String? phoneEmpty,
    String? phoneTooShort,
    String? phoneTooLong,
    String? phoneInvalid,
    String? phoneUnknownCountry,
    String? phoneCountryNotAllowed,
    String? phoneMissingCountry,
  }) {
    return MREFieldsStrings(
      clearTooltip: clearTooltip ?? this.clearTooltip,
      countryPickerTitle: countryPickerTitle ?? this.countryPickerTitle,
      countrySearchHint: countrySearchHint ?? this.countrySearchHint,
      noCountriesFound: noCountriesFound ?? this.noCountriesFound,
      removeImageTooltip: removeImageTooltip ?? this.removeImageTooltip,
      replaceImageTooltip: replaceImageTooltip ?? this.replaceImageTooltip,
      closeViewerTooltip: closeViewerTooltip ?? this.closeViewerTooltip,
      pasteImageLabel: pasteImageLabel ?? this.pasteImageLabel,
      attachedImageLabel: attachedImageLabel ?? this.attachedImageLabel,
      phoneEmpty: phoneEmpty ?? this.phoneEmpty,
      phoneTooShort: phoneTooShort ?? this.phoneTooShort,
      phoneTooLong: phoneTooLong ?? this.phoneTooLong,
      phoneInvalid: phoneInvalid ?? this.phoneInvalid,
      phoneUnknownCountry: phoneUnknownCountry ?? this.phoneUnknownCountry,
      phoneCountryNotAllowed:
          phoneCountryNotAllowed ?? this.phoneCountryNotAllowed,
      phoneMissingCountry: phoneMissingCountry ?? this.phoneMissingCountry,
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
        other.closeViewerTooltip == closeViewerTooltip &&
        other.pasteImageLabel == pasteImageLabel &&
        other.attachedImageLabel == attachedImageLabel &&
        other.phoneEmpty == phoneEmpty &&
        other.phoneTooShort == phoneTooShort &&
        other.phoneTooLong == phoneTooLong &&
        other.phoneInvalid == phoneInvalid &&
        other.phoneUnknownCountry == phoneUnknownCountry &&
        other.phoneCountryNotAllowed == phoneCountryNotAllowed &&
        other.phoneMissingCountry == phoneMissingCountry;
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
    pasteImageLabel,
    attachedImageLabel,
    phoneEmpty,
    phoneTooShort,
    phoneTooLong,
    phoneInvalid,
    phoneUnknownCountry,
    phoneCountryNotAllowed,
    phoneMissingCountry,
  );
}
