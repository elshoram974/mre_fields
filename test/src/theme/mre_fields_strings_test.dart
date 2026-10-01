import 'package:flutter_test/flutter_test.dart';
import 'package:mre_fields/mre_fields.dart';

void main() {
  test('every default is a non-empty English text', () {
    const strings = MREFieldsStrings();
    final values = [
      strings.clearTooltip,
      strings.countryPickerTitle,
      strings.countrySearchHint,
      strings.noCountriesFound,
      strings.removeImageTooltip,
      strings.replaceImageTooltip,
      strings.closeViewerTooltip,
      strings.pasteImageLabel,
      strings.attachedImageLabel,
      strings.phoneEmpty,
      strings.phoneTooShort,
      strings.phoneTooLong,
      strings.phoneInvalid,
      strings.phoneUnknownCountry,
      strings.phoneCountryNotAllowed,
      strings.phoneMissingCountry,
    ];

    expect(values, everyElement(isNotEmpty));
    expect(values.toSet().length, values.length, reason: 'no duplicate texts');
  });

  test('copyWith replaces only the given value', () {
    const base = MREFieldsStrings();
    final copy = base.copyWith(clearTooltip: 'مسح');

    expect(copy.clearTooltip, 'مسح');
    expect(copy.countryPickerTitle, base.countryPickerTitle);
  });

  test('equal values compare equal and share a hash code', () {
    const a = MREFieldsStrings(clearTooltip: 'X');
    const b = MREFieldsStrings(clearTooltip: 'X');

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const MREFieldsStrings()));
  });
}
