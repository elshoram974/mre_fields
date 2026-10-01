import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

final _egypt = MRECountries.byIsoCode('EG')!;
final _saudi = MRECountries.byIsoCode('SA')!;
final _uae = MRECountries.byIsoCode('AE')!;

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  Size size = const Size(400, 800),
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: direction, child: app!),
      ),
      home: Scaffold(body: child),
    ),
  );
}

Widget _body({
  List<MRECountry>? countries,
  List<MRECountry> favorites = const [],
  MRECountry? selected,
  ValueChanged<MRECountry>? onSelected,
  String Function(MRECountry)? nameBuilder,
}) {
  return MRECountryPickerBody(
    countries: countries ?? MRECountries.all,
    favorites: favorites,
    selected: selected,
    nameBuilder: nameBuilder,
    onSelected: onSelected ?? (_) {},
  );
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

void main() {
  group('MRECountryPickerBody', () {
    testWidgets('shows the title, the search field and a list', (tester) async {
      await _pump(tester, _body());

      expect(find.text('Select country'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Afghanistan'), findsOneWidget);
    });

    testWidgets('builds only the rows that are visible', (tester) async {
      await _pump(tester, _body());

      expect(find.byType(ListTile).evaluate().length, lessThan(30));
    });

    testWidgets('filters by name, ignoring case', (tester) async {
      await _pump(tester, _body());

      await _search(tester, 'EGY');

      expect(find.widgetWithText(ListTile, 'Egypt'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('filters by ISO code', (tester) async {
      await _pump(tester, _body(countries: [_egypt, _saudi, _uae]));

      await _search(tester, 'sa');

      expect(find.widgetWithText(ListTile, 'Saudi Arabia'), findsOneWidget);
    });

    testWidgets('filters by dial code, with or without the plus', (
      tester,
    ) async {
      await _pump(tester, _body(countries: [_egypt, _saudi, _uae]));

      await _search(tester, '+966');
      expect(find.widgetWithText(ListTile, 'Saudi Arabia'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      await _search(tester, '971');
      expect(
        find.widgetWithText(ListTile, 'United Arab Emirates'),
        findsOneWidget,
      );
    });

    testWidgets(
      'says when nothing matches and recovers when the search is cleared',
      (tester) async {
        await _pump(tester, _body());

        await _search(tester, 'zzzz');
        expect(find.text('No countries found'), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);

        await _search(tester, '');
        expect(find.byType(ListTile), findsWidgets);
      },
    );

    testWidgets('pins favorites above the rest with a divider', (tester) async {
      await _pump(
        tester,
        _body(countries: [_egypt, _saudi, _uae], favorites: [_uae]),
      );

      final tiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((t) => (t.title! as Text).data);
      expect(tiles, ['United Arab Emirates', 'Egypt', 'Saudi Arabia']);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('shows no divider without favorites', (tester) async {
      await _pump(tester, _body(countries: [_egypt, _saudi]));

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('ignores the favorites while searching', (tester) async {
      await _pump(
        tester,
        _body(countries: [_egypt, _saudi, _uae], favorites: [_uae]),
      );

      await _search(tester, 'a');

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('marks the selected country', (tester) async {
      await _pump(tester, _body(countries: [_egypt, _saudi], selected: _saudi));

      final selected = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .where((t) => t.selected)
          .map((t) => (t.title! as Text).data);
      expect(selected, ['Saudi Arabia']);
    });

    testWidgets('reports the tapped country', (tester) async {
      MRECountry? picked;
      await _pump(
        tester,
        _body(countries: [_egypt, _saudi], onSelected: (c) => picked = c),
      );

      await tester.tap(find.widgetWithText(ListTile, 'Saudi Arabia'));

      expect(picked, _saudi);
    });

    testWidgets('shows and searches names in your language', (tester) async {
      await _pump(
        tester,
        _body(
          countries: [_egypt, _saudi],
          nameBuilder: (c) => switch (c.isoCode) {
            'EG' => 'مصر',
            'SA' => 'السعودية',
            _ => c.name,
          },
        ),
      );

      expect(find.text('مصر'), findsOneWidget);
      expect(find.text('Egypt'), findsNothing);

      await _search(tester, 'سعود');
      expect(find.text('السعودية'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('takes its texts from MREFieldsStrings', (tester) async {
      await _pump(
        tester,
        _body(countries: [_egypt]),
        theme: ThemeData(
          extensions: const [
            MREFieldsTheme(
              strings: MREFieldsStrings(
                countryPickerTitle: 'اختر الدولة',
                countrySearchHint: 'ابحث',
                noCountriesFound: 'لا يوجد',
              ),
            ),
          ],
        ),
      );

      expect(find.text('اختر الدولة'), findsOneWidget);
      expect(find.text('ابحث'), findsOneWidget);

      await _search(tester, 'zzz');
      expect(find.text('لا يوجد'), findsOneWidget);
    });

    testWidgets('parameters win over the strings', (tester) async {
      await _pump(
        tester,
        MRECountryPickerBody(
          countries: [_egypt],
          onSelected: (_) {},
          title: 'Pick one',
          searchHint: 'Type here',
          emptyText: 'Nothing',
        ),
      );

      expect(find.text('Pick one'), findsOneWidget);
      expect(find.text('Type here'), findsOneWidget);
    });

    testWidgets('can hide the flags', (tester) async {
      await _pump(
        tester,
        MRECountryPickerBody(
          countries: [_egypt],
          onSelected: (_) {},
          showFlags: false,
        ),
      );

      expect(find.text(_egypt.flag), findsNothing);
    });

    testWidgets('follows a changed list of countries', (tester) async {
      await _pump(tester, _body(countries: [_egypt]));
      expect(find.byType(ListTile), findsOneWidget);

      await _pump(tester, _body(countries: [_egypt, _saudi]));

      expect(find.byType(ListTile), findsNWidgets(2));
    });

    for (final width in [320.0, 400.0, 1000.0]) {
      testWidgets(
        'has no overflow at $width wide, text scale 1.3, right to left',
        (tester) async {
          await _pump(
            tester,
            _body(favorites: [_egypt]),
            size: Size(width, 700),
            textScale: 1.3,
            direction: TextDirection.rtl,
          );

          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('showMRECountryPicker', () {
    late Future<MRECountry?> result;

    Widget opener() {
      return Builder(
        builder: (context) => TextButton(
          onPressed: () => result = showMRECountryPicker(
            context,
            countries: [_egypt, _saudi, _uae],
            selected: _egypt,
          ),
          child: const Text('open'),
        ),
      );
    }

    testWidgets('is a bottom sheet on a narrow window', (tester) async {
      await _pump(tester, opener(), size: const Size(400, 800));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('is a centered dialog with a maximum width on a wide window', (
      tester,
    ) async {
      await _pump(tester, opener(), size: const Size(1200, 800));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsNothing);
      expect(
        tester.getSize(find.byType(MRECountryPickerBody)).width,
        lessThanOrEqualTo(440),
      );
    });

    testWidgets('returns the chosen country from the sheet', (tester) async {
      await _pump(tester, opener());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Saudi Arabia'));
      await tester.pumpAndSettle();

      expect(await result, _saudi);
      expect(find.byType(DraggableScrollableSheet), findsNothing);
    });

    testWidgets('returns the chosen country from the dialog', (tester) async {
      await _pump(tester, opener(), size: const Size(1200, 800));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'United Arab Emirates'));
      await tester.pumpAndSettle();

      expect(await result, _uae);
    });

    testWidgets('returns null when dismissed', (tester) async {
      await _pump(tester, opener());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(200, 10));
      await tester.pumpAndSettle();

      expect(await result, isNull);
    });

    testWidgets('fits a short window', (tester) async {
      await _pump(tester, opener(), size: const Size(400, 300));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(DraggableScrollableSheet)).height,
        lessThanOrEqualTo(300),
      );
    });

    testWidgets('a short wide window keeps the dialog inside it', (
      tester,
    ) async {
      await _pump(tester, opener(), size: const Size(1000, 300));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(MRECountryPickerBody)).height,
        lessThanOrEqualTo(300),
      );
    });
  });
}
