import 'package:flutter/foundation.dart';

import 'mre_country.dart';

/// Which countries a phone field accepts, shows first, and starts with.
///
/// With no arguments every country is accepted. [include] keeps only the given
/// ISO codes; [exclude] drops them. Give one or the other, not both.
///
/// The same selection feeds the picker, the paste detection and the
/// validation, so a pasted number from an excluded country is never accepted.
///
/// {@example /doc/snippets/phone.dart#selection}
///
/// {@category Phone}
@immutable
final class MRECountrySelection {
  /// Creates a selection from ISO codes such as `{'EG', 'SA'}`.
  const MRECountrySelection({
    this.include,
    this.exclude,
    this.favorites = const [],
    this.initial,
  }) : assert(
         include == null || exclude == null,
         'Give include or exclude, not both.',
       );

  /// Accept only these ISO codes. Null accepts every country.
  final Set<String>? include;

  /// Accept every country except these ISO codes.
  final Set<String>? exclude;

  /// ISO codes pinned at the top of the picker, in this order.
  final List<String> favorites;

  /// ISO code of the country a new field starts with.
  final String? initial;

  /// Whether [country] is accepted.
  bool allows(MRECountry country) {
    final iso = country.isoCode;
    final included = include;
    if (included != null) {
      return included.contains(iso);
    }
    return !(exclude?.contains(iso) ?? false);
  }

  /// The accepted countries, sorted by English name.
  List<MRECountry> get countries {
    return [
      for (final country in MRECountries.all)
        if (allows(country)) country,
    ];
  }

  /// The accepted favorites, in the order given.
  List<MRECountry> get favoriteCountries {
    return [
      for (final iso in favorites)
        if (MRECountries.byIsoCode(iso) case final country?)
          if (allows(country)) country,
    ];
  }

  /// The country a new field starts with: [initial] when accepted, else the
  /// first favorite, else the first accepted country, else null.
  MRECountry? get initialCountry {
    final start = initial == null ? null : MRECountries.byIsoCode(initial!);
    if (start != null && allows(start)) {
      return start;
    }
    final pinned = favoriteCountries;
    if (pinned.isNotEmpty) {
      return pinned.first;
    }
    return countries.firstOrNull;
  }

  @override
  bool operator ==(Object other) {
    return other is MRECountrySelection &&
        setEquals(other.include, include) &&
        setEquals(other.exclude, exclude) &&
        listEquals(other.favorites, favorites) &&
        other.initial == initial;
  }

  @override
  int get hashCode => Object.hash(
    include == null ? null : Object.hashAllUnordered(include!),
    exclude == null ? null : Object.hashAllUnordered(exclude!),
    Object.hashAll(favorites),
    initial,
  );
}
