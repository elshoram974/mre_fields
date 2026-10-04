import 'package:flutter/material.dart';

import '../../internal/mre_owned.dart';
import '../../text/field/mre_text_field.dart';
import '../../theme/mre_fields_theme.dart';
import '../model/mre_country.dart';
import '../model/mre_country_selection.dart';
import '../model/mre_phone_digits.dart';
import '../model/mre_phone_number.dart';
import '../model/mre_phone_initial_country.dart';
import '../picker/mre_country_picker.dart';
import 'mre_dial_button.dart';
import 'mre_phone_controller.dart';

/// A phone number field: a country button with the dial code, and the number.
///
/// - Parses numbers for every country. Use `MREPhoneFormField` for form
///   validation, saving and resetting.
/// - Paste `+20 101 234 5678` and the country changes to Egypt and the number
///   fills in. Digits in Arabic or Persian are accepted too.
/// - Accepts only the countries of [selection], and shows its favorites first.
/// - Opens a searchable country picker: a sheet on narrow windows, a dialog on
///   wide ones.
///
/// {@example /doc/snippets/phone.dart#basic}
///
/// Read the number with [onChanged], or with a [controller]. The value is an
/// [MREPhoneNumber]; use `e164` to store or send it.
///
/// See also:
///
///  * [MREPhoneValidators], the same validation for any form field.
///  * [showMRECountryPicker], the picker on its own.
///
/// {@category Phone}
class MREPhoneField extends StatefulWidget {
  /// Creates a phone field.
  const MREPhoneField({
    super.key,
    this.controller,
    this.initialValue,
    this.initialCountry,
    this.selection = const MRECountrySelection(),
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.decoration,
    this.onChanged,
    this.onCountryChanged,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.style,
    this.borderRadius,
    this.contentPadding,
    this.showClearButton = false,
    this.showFlags = true,
    this.countryNameBuilder,
    this.pickerTitle,
    this.pickerSearchHint,
    this.pickerEmptyText,
    this.autofillHints = const [AutofillHints.telephoneNumberNational],
  });

  /// Holds the country and the number. The field keeps its own when null.
  final MREPhoneController? controller;

  /// Number to start with, such as `+201012345678` or `01012345678`. Used only
  /// when the field keeps its own [controller].
  final String? initialValue;

  /// Country to start with. See [selection] for the order of fallbacks.
  final MRECountry? initialCountry;

  /// Which countries are accepted, shown first, and started with.
  final MRECountrySelection selection;

  /// Label above the field.
  final String? labelText;

  /// Hint shown while the number is empty.
  final String? hintText;

  /// Text under the field.
  final String? helperText;

  /// Error under the field. Wins over validation messages.
  final String? errorText;

  /// The host's decoration, with the country button added as its prefix.
  final InputDecoration? decoration;

  /// Called on every change, also when the country changes.
  final ValueChanged<MREPhoneNumber>? onChanged;

  /// Called when the country changes through the picker, typing or paste.
  final ValueChanged<MRECountry>? onCountryChanged;

  /// Whether the user can change the number and the country.
  final bool enabled;

  /// Whether the number can be read and copied but not changed.
  final bool readOnly;

  /// Whether to take focus when first built.
  final bool autofocus;

  /// The focus node of the number. The field keeps its own when null.
  final FocusNode? focusNode;

  /// The keyboard action button.
  final TextInputAction? textInputAction;

  /// Called when the user submits the field.
  final ValueChanged<MREPhoneNumber>? onFieldSubmitted;

  /// Style of the typed number.
  final TextStyle? style;

  /// Corner radius of the border.
  final double? borderRadius;

  /// Padding inside the border.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether to show a clear button while there are digits.
  final bool showClearButton;

  /// Whether to show flags in the button and in the picker.
  final bool showFlags;

  /// A country's name in your language, for the picker and its search.
  final String Function(MRECountry country)? countryNameBuilder;

  /// Title of the picker. Defaults to `MREFieldsStrings.countryPickerTitle`.
  final String? pickerTitle;

  /// Search hint of the picker.
  final String? pickerSearchHint;

  /// Text of the picker when nothing matches.
  final String? pickerEmptyText;

  /// Hints for the platform autofill service.
  final Iterable<String> autofillHints;

  @override
  State<MREPhoneField> createState() => _MREPhoneFieldState();
}

class _MREPhoneFieldState extends State<MREPhoneField> {
  late MREOwned<MREPhoneController> _controller;
  late List<MRECountry> _countries;
  late List<MRECountry> _favorites;
  String _previousText = '';
  bool _converting = false;

  MREPhoneController get _phone => _controller.value;

  @override
  void initState() {
    super.initState();
    _controller = MREOwned(widget.controller, MREPhoneController.new);
    _useSelection();
    _applyStart();
    _phone.text.addListener(_onTextChanged);
    _previousText = _phone.text.text;
  }

  @override
  void didUpdateWidget(MREPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _phone.text.removeListener(_onTextChanged);
      final old = _controller;
      _controller = MREOwned(widget.controller, MREPhoneController.new);
      _useSelection();
      _applyStart();
      _phone.text.addListener(_onTextChanged);
      _previousText = _phone.text.text;
      old.disposeAfterFrame();
    } else if (widget.selection != oldWidget.selection) {
      _useSelection();
      final country = _phone.country;
      if (country == null || !widget.selection.allows(country)) {
        _phone.country = _defaultCountry();
      }
    }
  }

  @override
  void dispose() {
    _phone.text.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _useSelection() {
    _countries = widget.selection.countries;
    _favorites = widget.selection.favoriteCountries;
  }

  /// Sets the country, then the initial number, when the field owns its
  /// controller or the controller has no country yet.
  void _applyStart() {
    final country = _phone.country;
    if (country == null || !widget.selection.allows(country)) {
      _phone.country = _defaultCountry();
    }
    final initial = widget.initialValue;
    if (_controller.isCreated && initial != null) {
      _phone.setNumber(initial, selection: widget.selection);
    }
  }

  /// The country a new field starts with: the parameter, the selection's
  /// initial country, the device's country, then the selection's first choice.
  MRECountry? _defaultCountry() {
    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;
    return mreInitialPhoneCountry(
      selection: widget.selection,
      preferred: widget.initialCountry,
      deviceCountryCode: deviceCode,
    );
  }

  MREPhoneNumber _number() => _phone.number(widget.selection);

  void _onTextChanged() {
    if (_converting) {
      return;
    }
    final text = _phone.text.text;
    if (text == _previousText) {
      return; // only the cursor moved
    }
    final grew = text.length - _previousText.length;
    _previousText = text;

    if (text.startsWith('+') || text.startsWith('00')) {
      _readInternational(text, pasted: grew > 1);
    }
    widget.onChanged?.call(_number());
  }

  /// Country detection is independent of number validity. Keep a typed
  /// international prefix until the number is valid, so shared dial codes
  /// can be refined as more digits arrive. Pasted numbers normalize at once.
  void _readInternational(String text, {required bool pasted}) {
    final number = _number();
    final country = number.country;
    final unusable =
        number.error == MREPhoneError.unknownCountry ||
        number.error == MREPhoneError.countryNotAllowed;
    final digits = text.startsWith('+') ? text.substring(1) : text.substring(2);
    if (country == null || unusable || !digits.startsWith(country.dialCode)) {
      return;
    }

    final changed = _phone.country != country;
    _converting = true;
    _phone.country = country;
    if (pasted || number.isValid) {
      _phone.text.value = TextEditingValue(
        text: number.nationalNumber,
        selection: TextSelection.collapsed(
          offset: number.nationalNumber.length,
        ),
      );
      _previousText = number.nationalNumber;
    }
    _converting = false;
    if (changed) widget.onCountryChanged?.call(country);
  }

  Future<void> _pickCountry() async {
    if (!widget.enabled || widget.readOnly) return;
    final picked = await showMRECountryPicker(
      context,
      countries: _countries,
      selected: _phone.country,
      favorites: _favorites,
      title: widget.pickerTitle,
      searchHint: widget.pickerSearchHint,
      emptyText: widget.pickerEmptyText,
      nameBuilder: widget.countryNameBuilder,
      showFlags: widget.showFlags,
    );
    if (!mounted ||
        picked == null ||
        picked == _phone.country ||
        !widget.enabled ||
        widget.readOnly ||
        !widget.selection.allows(picked)) {
      return;
    }
    _phone.country = picked;
    widget.onCountryChanged?.call(picked);
    widget.onChanged?.call(_number());
  }

  @override
  Widget build(BuildContext context) {
    final strings = MREFieldsTheme.of(context).strings;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return MRETextField(
      controller: _phone.text,
      focusNode: widget.focusNode,
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      decoration: widget.decoration,
      prefixIcon: ListenableBuilder(
        listenable: _phone,
        builder: (context, _) {
          final country = _phone.country;
          return MREDialButton(
            country: country,
            name: country == null
                ? strings.countryPickerTitle
                : widget.countryNameBuilder?.call(country) ?? country.name,
            showFlag: widget.showFlags,
            onPressed: widget.enabled && !widget.readOnly ? _pickCountry : null,
          );
        },
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: const [MREPhoneInputFormatter()],
      textDirection: TextDirection.ltr,
      textAlign: rtl ? TextAlign.right : TextAlign.left,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(_number()),
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      style: widget.style,
      borderRadius: widget.borderRadius,
      contentPadding: widget.contentPadding,
      showClearButton: widget.showClearButton,
    );
  }
}
