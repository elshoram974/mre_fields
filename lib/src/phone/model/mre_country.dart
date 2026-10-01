import 'package:flutter/foundation.dart';
import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'mre_country_names.dart';

/// A country or region with a phone dial code.
///
/// Get one from [MRECountries]. Two countries are equal when their ISO codes
/// are: a dial code can belong to several countries (+1 is the United States,
/// Canada and others), so the ISO code is the key.
///
/// {@category Phone}
@immutable
final class MRECountry {
  MRECountry._(IsoCode iso)
    : isoCode = iso.name,
      dialCode = metadataByIsoCode[iso]!.countryCode,
      name = mreCountryNames[iso.name]!;

  /// The two-letter ISO 3166 code, such as `EG`.
  final String isoCode;

  /// The dial code without the plus, such as `20`.
  final String dialCode;

  /// The English name. Show your own language with a `nameBuilder`.
  final String name;

  /// The dial code with the plus, such as `+20`.
  String get dialCodeWithPlus => '+$dialCode';

  /// The flag as an emoji, built from the ISO code.
  ///
  /// Windows draws two letters instead of a flag.
  String get flag {
    return String.fromCharCodes(
      isoCode.codeUnits.map((unit) => 0x1F1E6 + unit - 0x41),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MRECountry && other.isoCode == isoCode;
  }

  @override
  int get hashCode => isoCode.hashCode;

  @override
  String toString() => 'MRECountry($isoCode, $dialCodeWithPlus, $name)';
}

/// Every country with a dial code, and lookups.
///
/// {@example /doc/snippets/phone.dart#countries}
///
/// {@category Phone}
abstract final class MRECountries {
  /// All countries, sorted by English name.
  static final List<MRECountry> all = _build();

  static final Map<String, MRECountry> _byIso = {
    for (final country in all) country.isoCode: country,
  };

  /// The country with [isoCode] (any case), or null.
  static MRECountry? byIsoCode(String isoCode) {
    return _byIso[isoCode.toUpperCase()];
  }

  /// The countries that use [dialCode], with or without the plus. More than one
  /// country can share a dial code.
  static List<MRECountry> byDialCode(String dialCode) {
    final digits = dialCode.startsWith('+') ? dialCode.substring(1) : dialCode;
    return [
      for (final country in all)
        if (country.dialCode == digits) country,
    ];
  }

  static List<MRECountry> _build() {
    final countries = [for (final iso in IsoCode.values) MRECountry._(iso)];
    countries.sort((a, b) => _sortKey(a.name).compareTo(_sortKey(b.name)));
    return List.unmodifiable(countries);
  }

  /// The name without accents, so "Åland" sorts with the A names.
  static String _sortKey(String name) {
    const accents = {
      'Å': 'A',
      'ç': 'c',
      'ô': 'o',
      'é': 'e',
      'í': 'i',
      'ã': 'a',
      'ü': 'u',
      '’': "'",
    };
    final folded = name.split('').map((c) => accents[c] ?? c).join();
    return folded.toLowerCase();
  }
}
