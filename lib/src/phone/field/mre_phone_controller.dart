import 'package:flutter/widgets.dart';

import '../../text/field/mre_safe_text_editing_controller.dart';
import '../model/mre_country.dart';
import '../model/mre_country_selection.dart';
import '../model/mre_phone_number.dart';

/// Holds the country and the national number of an `MREPhoneField`.
///
/// Pass one to read or set the number from your own code:
///
/// {@example /doc/snippets/phone.dart#controller}
///
/// The controller notifies when the **country** changes. The digits live in
/// [text], a normal [TextEditingController] you can listen to for typing.
///
/// Dispose a controller you create.
///
/// {@category Phone}
class MREPhoneController extends ChangeNotifier {
  /// Creates a controller, optionally with a [country] and [nationalNumber].
  MREPhoneController({MRECountry? country, String? nationalNumber})
    : _country = country,
      text = MRESafeTextEditingController(text: nationalNumber);

  /// The digits the user typed next to the country.
  final TextEditingController text;

  MRECountry? _country;
  String? _cachedText;
  MRECountry? _cachedCountry;
  MRECountrySelection? _cachedSelection;
  MREPhoneNumber? _cachedNumber;

  /// The chosen country, or null before one is chosen.
  MRECountry? get country => _country;

  set country(MRECountry? value) {
    if (value == _country) {
      return;
    }
    _country = value;
    notifyListeners();
  }

  /// The number as it stands, checked against [selection].
  MREPhoneNumber number([
    MRECountrySelection selection = const MRECountrySelection(),
  ]) {
    final digits = text.text;
    if (_cachedText == digits &&
        _cachedCountry == _country &&
        _cachedSelection == selection) {
      return _cachedNumber!;
    }
    final chosen = _country;
    final result =
        digits.startsWith('+') || digits.startsWith('00') || chosen == null
        ? MREPhoneNumber.parse(
            digits,
            defaultCountry: chosen,
            selection: selection,
          )
        : MREPhoneNumber.national(chosen, digits, selection: selection);
    _cachedText = digits;
    _cachedCountry = chosen;
    _cachedSelection = selection;
    return _cachedNumber = result;
  }

  /// Sets the number from [input]. A number with a dial code such as
  /// `+20 101 234 5678` also sets the country; any other number is read as a
  /// number of the current country.
  void setNumber(
    String input, {
    MRECountrySelection selection = const MRECountrySelection(),
  }) {
    final parsed = MREPhoneNumber.parse(
      input,
      defaultCountry: _country,
      selection: selection,
    );
    final found = parsed.country;
    if (found != null && parsed.error != MREPhoneError.unknownCountry) {
      country = found;
    }
    final digits = parsed.error == MREPhoneError.unknownCountry
        ? input
        : parsed.nationalNumber;
    text.value = TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }

  /// Empties the digits. The country stays.
  void clear() => text.clear();

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }
}
