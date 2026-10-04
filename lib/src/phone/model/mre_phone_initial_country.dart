import 'package:meta/meta.dart';

import 'mre_country.dart';
import 'mre_country_selection.dart';

/// Resolves the initial country identically for ordinary and form inputs.
@internal
MRECountry? mreInitialPhoneCountry({
  required MRECountrySelection selection,
  MRECountry? preferred,
  String? deviceCountryCode,
}) {
  final candidates = [
    preferred,
    MRECountries.byIsoCode(selection.initial ?? ''),
    MRECountries.byIsoCode(deviceCountryCode ?? ''),
  ];
  for (final candidate in candidates) {
    if (candidate != null && selection.allows(candidate)) return candidate;
  }
  return selection.initialCountry;
}
