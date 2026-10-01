import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/src/internal/mre_owned.dart';

class _Tracked extends ChangeNotifier {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

void main() {
  test('uses the notifier it is given and never disposes it', () {
    final given = _Tracked();
    final owned = MREOwned(given, _Tracked.new);

    owned.dispose();

    expect(owned.value, same(given));
    expect(owned.isCreated, isFalse);
    expect(given.disposed, isFalse);
    given.dispose();
  });

  test('creates one when none is given, and disposes it', () {
    final owned = MREOwned<_Tracked>(null, _Tracked.new);

    expect(owned.isCreated, isTrue);
    expect(owned.value.disposed, isFalse);

    owned.dispose();

    expect(owned.value.disposed, isTrue);
  });

  test('does not call create when a notifier is given', () {
    var created = 0;
    final given = _Tracked();
    addTearDown(given.dispose);

    MREOwned(given, () {
      created++;
      return _Tracked();
    });

    expect(created, 0);
  });

  testWidgets('disposeAfterFrame waits for the frame', (tester) async {
    final owned = MREOwned<_Tracked>(null, _Tracked.new);

    owned.disposeAfterFrame();
    expect(owned.value.disposed, isFalse);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(owned.value.disposed, isTrue);
  });

  testWidgets('disposeAfterFrame leaves a given notifier alone', (
    tester,
  ) async {
    final given = _Tracked();
    final owned = MREOwned(given, _Tracked.new);

    owned.disposeAfterFrame();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(given.disposed, isFalse);
    given.dispose();
  });
}
