import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../doc/snippets/functions.dart';
import '../support/images.dart';

void main() {
  test(
    'direction_functions: Arabic aligns right, English left, digits stay',
    () {
      expect(reportAlignment('محمد'), TextAlign.right);
      expect(reportAlignment('Mohamed'), TextAlign.left);
      expect(reportAlignment('12345'), TextAlign.start);
    },
  );

  test('getters: tell right to left text', () {
    expect(startsRightToLeft('مرحبا'), isTrue);
    expect(startsRightToLeft('Hello'), isFalse);
    expect(startsRightToLeft('12345'), isFalse);
  });

  test('sanitize: replaces a broken surrogate', () {
    expect(cleanForDisplay('a\uD800b'), 'a�b');
    expect(cleanForDisplay('a😀b'), 'a😀b');
  });

  test('filter: matches ignoring case and stops at the limit', () {
    expect(matchingCities('A'), ['Cairo', 'Alexandria', 'Giza']);
    expect(matchingCities('lux'), ['Luxor']);
    expect(matchingCities('zzz'), isEmpty);
  });

  test('sniff: recognizes a PNG and rejects other data', () {
    expect(isPng(pngBytes), isTrue);
    expect(isPng(Uint8List.fromList('hello world'.codeUnits)), isFalse);
  });

  test('collect: holds the images and notifies', () {
    final controller = collectImages([png(), png(otherPngBytes())]);
    addTearDown(controller.dispose);

    expect(controller.count, 2);
  });
}
