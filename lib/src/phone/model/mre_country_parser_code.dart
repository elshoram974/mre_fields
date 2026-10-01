import 'package:meta/meta.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'mre_country.dart';

final Map<String, IsoCode> _byName = {
  for (final iso in IsoCode.values) iso.name: iso,
};

/// The phone parser's code for [country].
///
/// The public API does not expose the parser, so it can change.
@internal
IsoCode mreParserIsoCode(MRECountry country) => _byName[country.isoCode]!;
