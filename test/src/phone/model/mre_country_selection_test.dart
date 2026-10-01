import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

List<String> _iso(Iterable<MRECountry> countries) =>
    countries.map((c) => c.isoCode).toList();

void main() {
  test('accepts every country by default', () {
    const selection = MRECountrySelection();

    expect(selection.countries, MRECountries.all);
    expect(selection.allows(MRECountries.byIsoCode('EG')!), isTrue);
  });

  test('include keeps only the given countries, sorted by name', () {
    const selection = MRECountrySelection(include: {'SA', 'EG', 'AE'});

    expect(_iso(selection.countries), ['EG', 'SA', 'AE']);
    expect(selection.allows(MRECountries.byIsoCode('US')!), isFalse);
  });

  test('exclude drops the given countries', () {
    const selection = MRECountrySelection(exclude: {'IL'});

    expect(selection.countries, hasLength(MRECountries.all.length - 1));
    expect(selection.allows(MRECountries.byIsoCode('IL')!), isFalse);
    expect(selection.allows(MRECountries.byIsoCode('EG')!), isTrue);
  });

  test('include and exclude together is an error', () {
    expect(
      () => MRECountrySelection(include: const {'EG'}, exclude: const {'IL'}),
      throwsAssertionError,
    );
  });

  test(
    'favorites keep their order and skip countries that are not accepted',
    () {
      const selection = MRECountrySelection(
        include: {'EG', 'SA', 'AE'},
        favorites: ['SA', 'US', 'EG'],
      );

      expect(_iso(selection.favoriteCountries), ['SA', 'EG']);
    },
  );

  group('initialCountry', () {
    test('is the initial country when it is accepted', () {
      const selection = MRECountrySelection(initial: 'SA', favorites: ['EG']);

      expect(selection.initialCountry!.isoCode, 'SA');
    });

    test(
      'falls back to the first favorite when the initial one is not accepted',
      () {
        const selection = MRECountrySelection(
          include: {'EG', 'SA'},
          initial: 'US',
          favorites: ['SA'],
        );

        expect(selection.initialCountry!.isoCode, 'SA');
      },
    );

    test('falls back to the first accepted country', () {
      const selection = MRECountrySelection(include: {'SA', 'EG'});

      expect(selection.initialCountry!.isoCode, 'EG');
    });

    test('is null when nothing is accepted', () {
      const selection = MRECountrySelection(include: {});

      expect(selection.initialCountry, isNull);
    });
  });

  test('equal selections compare equal whatever the order of their sets', () {
    const a = MRECountrySelection(include: {'EG', 'SA'}, favorites: ['EG']);
    const b = MRECountrySelection(include: {'SA', 'EG'}, favorites: ['EG']);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const MRECountrySelection(include: {'EG'})));
    expect(const MRECountrySelection(), const MRECountrySelection());
  });
}
